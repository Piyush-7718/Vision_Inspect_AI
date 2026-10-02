# 🚀 VisionInspect AI — AWS EC2 Deployment Guide

Deploy the entire VisionInspect AI stack (React frontend, Node.js auth BFF, Python FastAPI AI engine) on a **single AWS EC2 instance** while keeping your **MongoDB Atlas** database intact.

```
┌─────────────────────────────────────────────────────────────────┐
│                      AWS EC2 Single Instance                    │
│                                                                 │
│  ┌────────────────────────┐         ┌────────────────────────┐  │
│  │     React Frontend     │         │   Node.js Auth Backend │  │
│  │   (Vite Static Build)  │         │   Express + tRPC (3000)│  │
│  └───────────┬────────────┘         └───────────┬────────────┘  │
│              │                                  │               │
│              ▼                                  ▼               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                Nginx Reverse Proxy (Port 80)              │  │
│  └───────────────────────────┬───────────────────────────────┘  │
│                              │                                  │
│                              ▼                                  │
│                 ┌──────────────────────────┐                    │
│                 │ Python FastAPI AI Engine │                    │
│                 │ PyTorch + YOLOv8 (8000)  │                    │
│                 └────────────┬─────────────┘                    │
└──────────────────────────────┼──────────────────────────────────┘
                               │
                               ▼
               ┌─────────────────────────────────┐
               │    MongoDB Atlas (Cloud DB)     │
               │   - Free Tier M0                │
               │   - Existing collections intact │
               └─────────────────────────────────┘
```

---

## 📑 Quick Steps Summary

1. **Launch an AWS EC2 Instance** (Ubuntu 22.04 LTS, `t2.micro` or `t3.micro` Free Tier eligible).
2. **Configure Security Group** (Open Inbound ports `22`, `80`, `443`).
3. **Configure MongoDB Atlas** (Allow EC2 Public IP or `0.0.0.0/0` in Network Access).
4. **Clone & Run the One-Click Deployment Script**:
   ```bash
   git clone https://github.com/Piyush-7718/Vision_Inspect_AI.git
   cd Vision_Inspect_AI
   chmod +x deploy-ec2.sh
   ./deploy-ec2.sh
   ```

---

## 🛠️ Step-by-Step Instructions

### Step 1: Launch your AWS EC2 Instance
1. In the [AWS Management Console](https://console.aws.amazon.com/ec2/), click **Launch Instance**.
2. **Name**: `visioninspect-ai`
3. **AMI**: `Ubuntu Server 22.04 LTS (HVM), SSD Volume Type`
4. **Instance Type**: `t2.micro` or `t3.micro` *(Free Tier eligible)*
5. **Key Pair**: Select your existing key pair (or create a new `.pem` key pair).
6. **Network Settings**:
   - Check **Allow SSH traffic from** (`Anywhere` or `My IP`)
   - Check **Allow HTTP traffic from the internet** (Port 80)
   - Check **Allow HTTPS traffic from the internet** (Port 443)
7. **Storage**: Configure 16 GB to 30 GB gp3 storage *(AWS Free Tier includes up to 30 GB)*.
8. Click **Launch Instance**.

---

### Step 2: Configure MongoDB Atlas (Keep Database Intact)
1. Go to [MongoDB Atlas](https://cloud.mongodb.com/).
2. In the left navigation, click **Security** → **Network Access**.
3. Click **Add IP Address** → choose **Allow Access from Anywhere** (`0.0.0.0/0`) or enter your EC2 Elastic IP.
4. Click **Confirm**. Your database, users, batches, and findings are **100% safe and intact**.

---

### Step 3: SSH into EC2 & Deploy

1. Open your terminal and connect to your EC2 instance:
   ```bash
   ssh -i /path/to/your-key.pem ubuntu@<YOUR_EC2_PUBLIC_IP>
   ```

2. Clone your repository:
   ```bash
   git clone https://github.com/Piyush-7718/Vision_Inspect_AI.git
   cd Vision_Inspect_AI
   ```

3. Setup your `.env` files with your MongoDB Atlas URI:
   
   **For Node.js Backend:**
   ```bash
   nano backend/.env
   ```
   Add:
   ```env
   MONGODB_URI=mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/visioninspect?retryWrites=true&w=majority
   JWT_SECRET=your_jwt_secret_key_here
   PORT=3000
   ```

   **For Python FastAPI Backend:**
   ```bash
   nano backend_python/.env
   ```
   Add:
   ```env
   MONGODB_URI=mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/visioninspect?retryWrites=true&w=majority
   JWT_SECRET=your_jwt_secret_key_here
   HOST=0.0.0.0
   PORT=8000
   ```

4. Run the automated deployment script:
   ```bash
   chmod +x deploy-ec2.sh
   ./deploy-ec2.sh
   ```

5. The script will automatically:
   - Configure 2GB swap space (prevents OOM on free tier instances during model inference).
   - Install Python dependencies, Node.js 20, Nginx, and PM2.
   - Build the React production bundle.
   - Configure Nginx reverse proxy on port 80.
   - Start and daemonize both backends with PM2.

---

### Step 4: Access Your Live Application
Open your browser and navigate to:
```text
http://<YOUR_EC2_PUBLIC_IP>/
```

- **Frontend:** `http://<YOUR_EC2_PUBLIC_IP>/`
- **FastAPI Interactive Docs:** `http://<YOUR_EC2_PUBLIC_IP>/pyapi/docs`
- **Health Check:** `http://<YOUR_EC2_PUBLIC_IP>/pyapi/`

---

## 🔧 Useful Maintenance Commands

- **Check running services:**
  ```bash
  pm2 status
  ```
- **View logs:**
  ```bash
  pm2 logs visioninspect-python
  pm2 logs visioninspect-node
  ```
- **Restart all services after code updates:**
  ```bash
  git pull origin main
  ./deploy-ec2.sh
  ```
