#!/bin/bash
set -e

echo "=== DEPLOY START ==="

# ---- CONFIG ----
PROJECT_NAME=note-web-app-DOM
PROJECT_DIR=/var/www
BACKEND_DIR=$PROJECT_DIR/$PROJECT_NAME/backendSrc
VENV_DIR=$BACKEND_DIR/venv

echo "=== Installing packages... ==="

curl -fsSL https://deb.nodesource.com/setup\_20.x | sudo -E bash -
sudo apt update
sudo apt install -y python3-venv python3-pip nodejs nginx git
sudo apt install -y nodejs

echo "=== ReactJS, Python packages installed ==="

echo "=== Cloning repository... ==="
sudo mkdir -p $PROJECT_DIR

if [ ! -d "$PROJECT_DIR/$PROJECT_NAME" ]; then
    cd $PROJECT_DIR
    git clone https://github.com/MinDag0612/note-web-app-DOM.git
else
    echo "Repository already exists. Pulling latest changes..."
    cd $PROJECT_DIR/$PROJECT_NAME
    git pull
fi

cd $PROJECT_DIR/$PROJECT_NAME


echo "=== Repository cloned ==="

echo "=== Installing frontend dependencies and building... ==="
if [ ! -f ".env" ]; then
  echo ".env not found. Creating from template..."
  cp .env.example .env
  echo "Please edit .env before running the script again."
  exit 1
fi

# Enter the project directory and set permissions for .env
cd $PROJECT_DIR/$PROJECT_NAME
sudo chmod 600 $PROJECT_DIR/$PROJECT_NAME/.env
sudo npm install
sudo npm run build

echo "=== Frontend built ==="

# Config Nginx
echo "=== Configuring Nginx... ==="
cd ~
# apt install nginx
cp /var/www/note-web-app-DOM/nginx.conf /etc/nginx/sites-available/noteweb
sudo ln -s /etc/nginx/sites-available/noteweb /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

echo "=== Nginx configured - UI is accessible ==="

# ---- BACKEND ----
echo "=== Setup backend... ==="
cd $BACKEND_DIR

#Lệnh tạo venv
if [ ! -d "venv" ]; then
  echo "Creating virtual environment..."
  python3 -m venv venv
fi

# cài đặt dependence
$VENV_DIR/bin/pip install --upgrade pip
$VENV_DIR/bin/pip install -r requirements.txt
echo "=== Python virtual environment ready ==="

# kiểm tra service file
SERVICE_FILE="$PROJECT_DIR/$PROJECT_NAME/backend.service"

if [ ! -f "$SERVICE_FILE" ]; then
  echo "ERROR: backend.service not found!"
  exit 1
fi

echo "=== Python virtual environment created ==="
echo "=== create systemd service file... ==="
sudo cp $PROJECT_DIR/$PROJECT_NAME/backend.service /etc/systemd/system/

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable backend
sudo systemctl restart backend

# kiểm tra service
if systemctl is-active --quiet backend; then
  echo "Backend service started successfully"
else
  echo "ERROR: Backend service failed"
  sudo systemctl status backend
  exit 1
fi

echo "=== DEPLOY DONE ==="
