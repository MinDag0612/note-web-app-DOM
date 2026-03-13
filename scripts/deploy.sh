#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="note-web-app-DOM"
PROJECT_BASE="/var/www"
PROJECT_ROOT="$PROJECT_BASE/$PROJECT_NAME"
REPO_URL="https://github.com/MinDag0612/note-web-app-DOM.git"
NGINX_SITE_NAME="noteweb"

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
  log_error "Please run as root (or with sudo): sudo bash scripts/deploy.sh"
  exit 1
fi

log_info "Deployment started"

mkdir -p "$PROJECT_BASE"

if [[ ! -d "$PROJECT_ROOT/.git" ]]; then
  log_info "Cloning repository into $PROJECT_ROOT"
  git clone "$REPO_URL" "$PROJECT_ROOT"
else
  log_info "Repository already exists, pulling latest changes"
  cd "$PROJECT_ROOT"
  git pull --ff-only
fi

cd "$PROJECT_ROOT"

log_info "Running system setup"
bash "$PROJECT_ROOT/scripts/setup.sh"

if [[ ! -f "$PROJECT_ROOT/.env" ]]; then
  log_warn ".env not found. Creating from .env.example"
  cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
  chmod 600 "$PROJECT_ROOT/.env"
  log_error "Please fill .env values, then run deploy.sh again."
  exit 1
fi

chmod 600 "$PROJECT_ROOT/.env"

log_info "Building frontend"
npm run build

log_info "Configuring Nginx"
cp "$PROJECT_ROOT/nginx.conf" "/etc/nginx/sites-available/$NGINX_SITE_NAME"
ln -sfn "/etc/nginx/sites-available/$NGINX_SITE_NAME" "/etc/nginx/sites-enabled/$NGINX_SITE_NAME"

if [[ -f "/etc/nginx/sites-enabled/default" ]]; then
  rm -f "/etc/nginx/sites-enabled/default"
fi

nginx -t
systemctl restart nginx

if [[ ! -f "$PROJECT_ROOT/backend.service" ]]; then
  log_error "backend.service not found at $PROJECT_ROOT/backend.service"
  exit 1
fi

log_info "Installing backend systemd service"
cp "$PROJECT_ROOT/backend.service" /etc/systemd/system/backend.service
systemctl daemon-reload
systemctl enable backend
systemctl restart backend

if systemctl is-active --quiet backend; then
  log_info "Backend service is active"
else
  log_error "Backend service failed to start"
  systemctl status backend --no-pager || true
  exit 1
fi

log_info "Deployment completed successfully"
