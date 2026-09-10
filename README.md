# 🔍 VisionInspect AI: Manufacturing Defect Detection & Quality Inspection Platform

[![Python](https://img.shields.io/badge/Python-3.10%2B-blue.svg?logo=python&logoColor=white)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688.svg?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![React](https://img.shields.io/badge/Frontend-React.js%20%2F%20Next.js-61DAFB.svg?logo=react&logoColor=black)](https://react.dev/)
[![PyTorch](https://img.shields.io/badge/AI%2FDL-PyTorch%20%7C%20YOLOv8-EE4C2C.svg?logo=pytorch&logoColor=white)](https://pytorch.org/)
[![OpenCV](https://img.shields.io/badge/Vision-OpenCV-5C3EE8.svg?logo=opencv&logoColor=white)](https://opencv.org/)
[![Docker](https://img.shields.io/badge/Deployment-Docker%20%7C%20AWS-2496ED.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **VisionInspect AI** is an end-to-end, Industry 4.0 automated quality inspection platform. Leveraging state-of-the-art computer vision and deep learning models, it identifies manufacturing anomalies, localizes surface defects, computes an objective multi-factor **Severity Score**, renders automated **Pass/Fail decisions**, and provides executive production analytics in real time.
* **Live Demo:** `http://15.206.204.165/` (Industrial EC2 Deployment)
---

## 📌 Table of Contents
- [Overview & Problem Statement](#-overview--problem-statement)
- [Key Features](#-key-features)
- [System Architecture](#-system-architecture)
- [Severity Scoring Mathematical Framework](#-severity-scoring-mathematical-framework)
- [Tech Stack](#-tech-stack)
- [Project Directory Structure](#-project-directory-structure)
- [Datasets & Preprocessing](#-datasets--preprocessing)
- [Installation & Quickstart](#-installation--quickstart)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#1-backend-setup-fastapi)
  - [Frontend Setup](#2-frontend-setup-react--nextjs)
  - [Dockerized Deployment](#3-docker-compose-full-stack)
- [API Endpoints & Documentation](#-api-endpoints--documentation)
- [Milestones & Development Roadmap](#-milestones--development-roadmap)
- [Evaluation Criteria & Key Performance Metrics](#-evaluation-criteria--key-performance-metrics)
- [License & Acknowledgments](#-license--acknowledgments)

---

## 🎯 Overview & Problem Statement

Manual inspection on high-throughput assembly lines is error-prone, subjective, slow, and expensive. Subtle structural cracks, miniature pinholes, texture abrasions, and missing electronic components often bypass visual scrutiny, leading to catastrophic field failures, high scrap rates, and product recalls.

**VisionInspect AI** bridges this gap by introducing an automated vision inspection pipeline:
* **High-Throughput Vision Acquisition:** Ingests live inspection streams or batch uploads from industrial area/line scan cameras.
* **Intelligent Defect Localization:** Combines unsupervised anomaly detection (for zero-shot novel defect discovery) with supervised object detection and semantic segmentation.
* **Deterministic Quality Control:** Translates complex deep learning inferences into actionable Pass/Fail verdicts with real-time PLC/SCADA integration and alerting.
* **Production Intelligence:** Live dashboards track scrap rates, First-Time-Yield (FTY), and defect distributions across shifts.

---

## ✨ Key Features

| Capability | Technical Details |
| :--- | :--- |
| **Multi-Modal Inspection** | Supports JPEG, PNG, BMP, and high-fidelity industrial TIFF formats with batch upload support. |
| **Deep Feature Extraction** | Combines morphological texture analysis, edge filters (Canny/Sobel), and deep CNN embeddings. |
| **Defect Localization** | Deep learning architectures (**YOLOv8**, **U-Net**) combined with anomaly heatmaps for pixel-level damage segmentation. |
| **Deterministic Severity Engine** | Algorithmic risk matrix calculating size, critical area placement, defect type, and prediction confidence. |
| **Automated Decision Engine** | Auto-approval, rework recommendation, or immediate line-halt escalation triggers. |
| **Enterprise RBAC & Security** | Granular JWT-based authentication separating **Quality Engineers**, **Floor Supervisors**, and **Plant Managers**. |
| **Real-time Analytics** | Operational dashboard tracking MTBF, scrap metrics, defect heatmaps, and exportable audit certificates (PDF/CSV). |

---

## 🏛 System Architecture

The following diagram illustrates the inspection pipeline and platform layers:

```
[ Industrial Cameras / Batch Upload ] 
               │
               ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        INSPECTION & ANALYTICS PIPELINE                      │
├─────────────────┬──────────────────┬──────────────────┬─────────────────────┤
│ 1. Preprocessing│ 2. Feature Extr. │ 3. Detection Eng.│ 4. Severity & QC    │
│ • Resizing/Norm │ • Texture / Edge │ • Anomaly Model  │ • Severity Scoring  │
│ • Denoising     │ • Shape Analysis │ • YOLOv8 / U-Net │ • Pass/Fail Rules   │
│ • ROI Extraction│ • Deep Embeddings│ • Heatmap Gen.   │ • Auto-Escalation   │
└────────┬────────┴────────┬─────────┴────────┬─────────┴──────────┬──────────┘
         │                 │                  │                    │
         ▼                 ▼                  ▼                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          DATA & PLATFORM SERVICES                           │
├─────────────────┬──────────────────┬──────────────────┬─────────────────────┤
│ Object Storage  │ Relational / NoSQL│ Model Registry   │ Event Stream & Cache│
│ S3 / MinIO      │ PostgreSQL/MongoDB│ MLflow / Torch   │ Redis & RabbitMQ    │
└─────────────────┴──────────────────┴──────────────────┴─────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          OUTPUTS & EXTERNAL CONSUMERS                       │
├──────────────────────┬──────────────────────────┬───────────────────────────┤
│ Web & Mobile App UI  │ Automated Inspection Log │ PLC / SCADA / ERP Alerts  │
│ Live Dashboards      │ Digital Quality Certs    │ Webhook / MQTT / REST API │
└──────────────────────┴──────────────────────────┴───────────────────────────┘
```

---

## 🧮 Severity Scoring Mathematical Framework

Every detected defect is assigned a **Severity Score ($S$)** between $0$ and $100$ to eliminate subjective inspector bias:

$$S = (S_{	ext{size}} 	imes 0.30) + (S_{	ext{location}} 	imes 0.25) + (S_{	ext{type}} 	imes 0.25) + (S_{	ext{conf}} 	imes 0.20)$$

### Parameter Breakdown

1. **Defect Size Score ($S_{	ext{size}} \in [0, 100]$ | 30% Weight):**
   * Ratio of defect bounding/polygon area relative to total product region of interest (ROI).
2. **Defect Location Score ($S_{	ext{location}} \in [0, 100]$ | 25% Weight):**
   * Non-critical / Cosmetic Perimeter: $0 - 40$
   * Structural Enclosure / Sub-assembly: $41 - 75$
   * Core Functional / Contact / Bearing Surface: $76 - 100$
3. **Defect Type Score ($S_{	ext{type}} \in [0, 100]$ | 25% Weight):**
   * Cosmetic Blemish / Discoloration: $10 - 35$
   * Surface Scratch / Tool Mark: $36 - 60$
   * Void / Porosity / Dent: $61 - 85$
   * Structural Crack / Contamination / Missing Component: $86 - 100$
4. **Detection Confidence Score ($S_{	ext{conf}} \in [0, 100]$ | 20% Weight):**
   * Model output probability mapped linearly. If confidence $< 70\%$, flagged for secondary human audit.

### Severity Action Matrix

| Severity Level | Score Range | Action Required | System Trigger |
| :--- | :---: | :--- | :--- |
| **Critical** | **80 – 100** | Immediate rejection; scrap part | Halts downstream cycle; triggers line alert |
| **High** | **60 – 79** | Product flagged; rework required | Routes unit to rework queue |
| **Medium** | **40 – 59** | Quality review advisory | Flags batch for sampling re-inspection |
| **Low** | **0 – 39** | Cosmetic variance; acceptable | Automatically approved with log entry |

---

## 💻 Tech Stack

* **Backend Engine:** Python 3.10+, FastAPI, Pydantic v2, Uvicorn, Celery
* **Computer Vision & AI:** PyTorch, Ultralytics YOLOv8, OpenCV (cv2), Albumentations, Scikit-image, Scikit-learn
* **Frontend Application:** React 18 / Next.js, Tailwind CSS, Lucide Icons, Recharts, Axios
* **Data & Storage:** PostgreSQL (relational audit & user records), MongoDB (flexible inspection JSON metadata), Redis (caching & task queues)
* **DevOps & Infrastructure:** Docker & Docker Compose, Nginx, AWS EC2 / S3, GitHub Actions CI/CD

---

## 📂 Project Directory Structure

```plaintext
visioninspect-ai/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   ├── v1/
│   │   │   │   ├── endpoints/
│   │   │   │   │   ├── auth.py          # User authentication & JWT
│   │   │   │   │   ├── inspection.py    # Inference & defect analysis
│   │   │   │   │   ├── analytics.py     # KPIs, yields, and defect trends
│   │   │   │   │   └── export.py        # PDF & CSV reporting
│   │   ├── core/
│   │   │   ├── config.py                # Environment configs & thresholds
│   │   │   └── security.py              # Password hashing & token handling
│   │   ├── db/
│   │   │   ├── base.py
│   │   │   └── session.py               # PostgreSQL & MongoDB clients
│   │   ├── models/                      # SQLAlchemy & Pydantic schemas
│   │   └── services/
│   │       ├── preprocessor.py          # Denoising, CLAHE, ROI cropping
│   │       ├── inference_engine.py      # YOLOv8 / PatchCore PyTorch runtime
│   │       └── severity_scorer.py       # Deterministic scoring algorithm
│   ├── weights/                         # Pretrained model checkpoints
│   ├── Dockerfile
│   └── requirements.txt
├── frontend/
│   ├── public/
│   ├── src/
│   │   ├── components/
│   │   │   ├── CameraFeed.tsx           # Real-time capture & upload
│   │   │   ├── DefectHeatmap.tsx        # Bounding boxes & segmentation overlays
│   │   │   ├── SeverityBadge.tsx        # Severity classification tags
│   │   │   └── YieldChart.tsx           # Analytics charts (Recharts)
│   │   ├── pages/
│   │   │   ├── index.tsx                # Overview & dashboard
│   │   │   ├── inspect.tsx              # Live inspection terminal
│   │   │   └── reports.tsx              # Historical trends & exports
│   │   └── styles/
│   ├── package.json
│   └── Dockerfile
├── data/
│   └── samples/                         # Sample test images
├── docker-compose.yml
└── README.md
```

---

## 🧪 Datasets & Preprocessing

The platform natively supports benchmark datasets and custom manufacturing lines:
* **MVTec AD (Anomaly Detection Dataset):** Comprehensive evaluation across 15 industrial categories (capsules, bottles, screws, printed circuit boards, transistors, metal parts).
* **Preprocessing Pipeline:**
  1. Contrast-Limited Adaptive Histogram Equalization (**CLAHE**) for surface texture enhancement.
  2. Gaussian and Median Filtering for sensor noise attenuation.
  3. Edge and Contour Morphological Extraction to crop region-of-interest (ROI).
  4. Dynamic normalization $(0, 1)$ with image resizing to $640	imes640$ tensor inputs.

---

## 🚀 Installation & Quickstart

### Prerequisites
* **Git**
* **Python 3.10+** & **Node.js 18+**
* **Docker & Docker Compose** (Recommended for zero-friction setup)
* NVIDIA GPU with CUDA drivers (Optional, for accelerated deep learning inference)

### 1. Backend Setup (FastAPI)
```bash
# Clone the repository
git clone https://github.com/your-username/visioninspect-ai.git
cd visioninspect-ai/backend

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start the development server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
*API interactive documentation will be available at `http://localhost:8000/docs`.*

### 2. Frontend Setup (React / Next.js)
```bash
cd ../frontend

# Install node dependencies
npm install

# Run the development server
npm run dev
```
*Dashboard will be accessible at `http://localhost:3000`.*

### 3. Docker Compose (Full Stack)
Spin up the entire microservice ecosystem (FastAPI, Next.js, PostgreSQL, Redis) with a single command:
```bash
docker-compose up --build -d
```

---

## 📡 API Endpoints & Documentation

| Method | Endpoint | Description | Protected |
| :--- | :--- | :--- | :---: |
| `POST` | `/api/v1/auth/login` | Authenticate user & return JWT token | No |
| `POST` | `/api/v1/inspection/analyze` | Upload image for synchronous defect inspection | Yes |
| `POST` | `/api/v1/inspection/batch` | Upload multiple images for asynchronous batch worker queue | Yes |
| `GET` | `/api/v1/inspection/{id}` | Fetch full inspection record with defect masks & scores | Yes |
| `GET` | `/api/v1/analytics/overview` | Return live KPIs: total inspected, scrap rate, defect trends | Yes |
| `GET` | `/api/v1/export/report/{id}` | Generate downloadable inspection PDF certificate | Yes |

---

## 📈 Evaluation Criteria & Key Performance Metrics

### 1. AI Vision Model Benchmarks
* **mAP@0.5:0.95:** $> 88.5\%$ on industrial defect detection datasets.
* **Precision / Recall:** Precision $\ge 94\%$, Recall $\ge 96\%$ (optimized to minimize False Negatives).
* **F1-Score:** $> 0.95$ across major defect categories (cracks, scratches, contamination).

### 2. Manufacturing & Line Performance
* **Inspection Automation Rate:** $> 92\%$ of items classified without manual intervention.
* **False Rejection Rate (FRR):** $< 1.5\%$ (protecting production throughput).
* **Inference Latency:** $< 45	ext{ ms}$ per part on NVIDIA T4 GPU; $< 180	ext{ ms}$ on 4-core Intel CPU.

---

## 🗺 Milestones & Development Roadmap

- [x] **Milestone 1 (Weeks 1-2):** Architecture blueprint, DB schema, JWT RBAC, and MVTec AD data ingestion.
- [x] **Milestone 2 (Weeks 3-4):** Preprocessing pipeline, YOLOv8/U-Net integration, and defect heatmap visualizer.
- [x] **Milestone 3 (Weeks 5-6):** Deterministic Severity Scoring engine, Pass/Fail decision matrix, and production analytics UI.
- [x] **Milestone 4 (Weeks 7-8):** Docker containerization, cloud deployment (AWS/EC2), stress testing, and documentation.

---

## 📄 License & Contact

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

* **Author:** VisionInspect AI Team
* **Project Repository:** [https://github.com/your-username/visioninspect-ai](https://github.com/your-username/visioninspect-ai)

