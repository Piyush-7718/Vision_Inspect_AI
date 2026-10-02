#!/bin/bash
# ==============================================================================
# 🔬 VisionInspect AI — AWS EC2 One-Click Setup & Deployment Script
# Target OS: Ubuntu 22.04 / 24.04 LTS (AWS Free Tier t2.micro / t3.micro compatible)
# ==============================================================================

set -e

echo "======================================================="
echo "   VisionInspect AI — Starting EC2 Setup & Deploy      "
echo "======================================================="

# 1. Update system packages
echo "[1/7] Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y curl git build-essential nginx python3-pip python3-venv libgl1 libglib2.0-0 libgomp1

# 2. Configure 2GB Swap Memory (Prevents Out-Of-Memory on t2.micro/t3.micro)
if [ ! -f /swapfile ]; then
    echo "[2/7] Creating 2GB Swap space for stable AI inference..."
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
else
    echo "[2/7] Swapfile already exists. Skipping."
fi

# 3. Install Node.js 20 LTS & PM2
echo "[3/7] Installing Node.js 20 LTS & PM2 process manager..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi
sudo npm install -g pm2

# 4. Setup Python Virtual Environment & Dependencies
echo "[4/7] Setting up Python FastAPI AI engine..."
cd backend_python
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
deactivate
cd ..

# 5. Setup Node.js Backend & Build Frontend
echo "[5/7] Installing Node.js backend & building frontend..."
cd backend
npm install
cd ../frontend
npm install
npm run build
cd ..

# 6. Configure Nginx Web Server & Reverse Proxy
echo "[6/7] Configuring Nginx reverse proxy..."
APP_DIR=$(pwd)

sudo tee /etc/nginx/sites-available/visioninspect > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    client_max_body_size 50M;

    # Frontend Static Build
    location / {
        root ${APP_DIR}/frontend/dist;
        index index.html;
        try_files \$uri \$uri/ /index.html;
    }

    # Node.js Auth & tRPC API
    location /api/ {
        proxy_pass http://127.0.0.1:3000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Python FastAPI AI Engine
    location /pyapi/ {
        proxy_pass http://127.0.0.1:8000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 300s;
    }

    # Uploaded image assets & heatmaps
    location /static/ {
        proxy_pass http://127.0.0.1:8000/static/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/visioninspect /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx

# 7. Start Services via PM2
echo "[7/7] Launching background services with PM2..."
pm2 delete all || true

# Start Node.js backend
cd backend
pm2 start "npm run dev" --name "visioninspect-node"
cd ..

# Start Python FastAPI AI backend
cd backend_python
pm2 start "venv/bin/python -m uvicorn app.main:app --host 0.0.0.0 --port 8000" --name "visioninspect-python"
cd ..

# Save PM2 startup list
pm2 save
pm2 startup | tail -n 1 | sudo bash || true

echo "======================================================="
echo " 🎉 VisionInspect AI successfully deployed!"
echo " Access your app at: http://$(curl -s http://checkip.amazonaws.com || echo '<YOUR_EC2_PUBLIC_IP>')"
echo "======================================================="
