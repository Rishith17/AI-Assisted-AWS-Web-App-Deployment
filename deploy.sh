#!/bin/bash
set -e

echo "=============================================="
echo "🚀 CloudOps Pulse: Automated EC2 Deployment"
echo "=============================================="

# 1. Update system packages
echo "[1/6] Updating apt packages..."
sudo apt-get update -y
sudo apt-get install -y python3 python3-pip python3-venv nginx git curl

# 2. Setup project directory
APP_DIR="/home/ubuntu/aws-devops-webapp"
echo "[2/6] Configuring application at $APP_DIR..."
cd $APP_DIR

# 3. Create and activate virtual environment
echo "[3/6] Setting up Python virtual environment..."
python3 -m venv venv
./venv/bin/pip install --upgrade pip
./venv/bin/pip install -r requirements.txt

# 4. Configure Systemd Service
echo "[4/6] Installing systemd service..."
sudo cp devops-app.service /etc/systemd/system/devops-app.service
sudo systemctl daemon-reload
sudo systemctl enable devops-app
sudo systemctl restart devops-app

# 5. Configure Nginx Reverse Proxy
echo "[5/6] Setting up Nginx reverse proxy..."
sudo cp nginx.conf /etc/nginx/sites-available/devops-app
sudo ln -sf /etc/nginx/sites-available/devops-app /etc/nginx/sites-enabled/devops-app
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx

# 6. Verify health
echo "[6/6] Checking application health..."
sleep 2
curl -s http://127.0.0.1/health || true

echo ""
echo "=============================================="
echo "🎉 Deployment Complete!"
echo "Open your browser to: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo 'YOUR_EC2_PUBLIC_IP')"
echo "=============================================="
