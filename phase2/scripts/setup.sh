#!/bin/bash
set -e

log_info() {
  echo "[INFO] $1"
}

log_warn() {
  echo "[WARN] $1"
}

log_error() {
  echo "[ERROR] $1"
}

if [[ "${EUID}" -ne 0 ]]; then
  log_error "Please run as root (or with sudo): sudo bash scripts/setup.sh"
  exit 1
fi

log_info "=== DEPLOY START ==="

# ---- CONFIG ----
PROJECT_NAME=note-web-app-DOM/phase2
PROJECT_DIR=/var/www
PROJECT_ROOT=$PROJECT_DIR/$PROJECT_NAME
BACKEND_DIR=$PROJECT_DIR/$PROJECT_NAME/backendSrc
VENV_DIR=$BACKEND_DIR/venv

log_info "=== Installing packages... ==="

curl -fsSL https://deb.nodesource.com/setup\_20.x | sudo -E bash -
apt update
apt install -y python3-venv python3-pip nodejs nginx git

log_info "=== ReactJS, Python packages installed ==="

log_info "=== Cloning repository... ==="
mkdir -p $PROJECT_DIR

if [ ! -d "$PROJECT_DIR/$PROJECT_NAME/.git" ]; then
    cd $PROJECT_DIR
    git clone https://github.com/MinDag0612/note-web-app-DOM.git
else
    log_info "Repository already exists. Pulling latest changes..."
    cd $PROJECT_DIR/$PROJECT_NAME
    git pull --ff-only
fi

cd $PROJECT_DIR/$PROJECT_NAME


log_info "=== Repository cloned ==="

log_info "=== Installing frontend dependencies and building... ==="
if [ ! -f ".env" ]; then
  log_warn ".env not found. Creating from template..."
  cp .env.example .env
  log_info "=== Please edit .env before running the script again. ==="
  exit 1
fi

# Enter the project directory and set permissions for .env
cd $PROJECT_ROOT
chmod 600 $PROJECT_DIR/$PROJECT_NAME/.env
npm install
npm run build

log_info "=== Frontend built ==="

# Config Nginx
log_info "=== Configuring Nginx... ==="
cd ~
# apt install nginx
cp $PROJECT_ROOT/deploy/nginx.conf /etc/nginx/sites-available/noteweb

sudo ln -sf /etc/nginx/sites-available/noteweb /etc/nginx/sites-enabled/

if [ -f /etc/nginx/sites-enabled/default ]; then
  rm /etc/nginx/sites-enabled/default
fi

sudo nginx -t
sudo systemctl restart nginx

log_info "=== Nginx configured - UI is accessible ==="

# ---- BACKEND ----
log_info "=== Setup backend... ==="
cd $BACKEND_DIR

#Lệnh tạo venv
if [ ! -d "$VENV_DIR" ]; then
  log_info "Creating virtual environment..."
  python3 -m venv $VENV_DIR
fi

# cài đặt dependence
$VENV_DIR/bin/pip install --upgrade pip
$VENV_DIR/bin/pip install -r requirements.txt
log_info "=== Python virtual environment ready ==="

# kiểm tra service file
SERVICE_FILE="$PROJECT_ROOT/deploy/backend.service"

if [ ! -f "$SERVICE_FILE" ]; then
  log_error "ERROR: backend.service not found!"
  exit 1
fi

log_info "=== Python virtual environment created ==="
log_info "=== create systemd service file... ==="
sudo cp $PROJECT_ROOT/deploy/backend.service /etc/systemd/system/

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable backend
sudo systemctl restart backend

# kiểm tra service
if systemctl is-active --quiet backend; then
  log_info "Backend service started successfully"
else
  log_error "ERROR: Backend service failed"
  sudo systemctl status backend
  exit 1
fi

log_info "=== DEPLOY DONE ==="
