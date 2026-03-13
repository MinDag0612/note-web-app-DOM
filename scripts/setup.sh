#!/usr/bin/env bash
set -euo pipefail

# Phase 1 automation script:
# Prepare an Ubuntu environment with required runtimes, packages, and project folders.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backendSrc"
VENV_DIR="$BACKEND_DIR/venv"

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

log_info "Starting Ubuntu environment setup for NoteWeb"

# 1) Install system-level runtime dependencies.
log_info "Installing OS packages and language runtimes"
apt-get update -y
apt-get install -y curl git nginx python3 python3-pip python3-venv ca-certificates
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# 2) Show installed versions for quick verification.
log_info "Installed versions"
node -v
npm -v
python3 --version
pip3 --version

# 3) Create required runtime directories.
log_info "Creating runtime directories"
mkdir -p "$PROJECT_ROOT/logs"
mkdir -p "$PROJECT_ROOT/uploads"
mkdir -p "$PROJECT_ROOT/data"
mkdir -p "$BACKEND_DIR/logs"

# 4) Prepare backend virtual environment and Python dependencies.
log_info "Preparing backend virtual environment"
python3 -m venv "$VENV_DIR"
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install -r "$BACKEND_DIR/requirements.txt"

# 5) Install frontend dependencies for local/app runtime.
log_info "Installing frontend dependencies"
cd "$PROJECT_ROOT"
npm install

if [[ ! -f "$PROJECT_ROOT/.env" ]]; then
  log_warn ".env file was not found. Create it from .env.example before running the application."
fi

log_info "Setup completed successfully"
log_info "Next steps:"
log_info "1) Configure .env"
log_info "2) Start backend: $VENV_DIR/bin/uvicorn backendSrc.main:app --host 127.0.0.1 --port 8000"
log_info "3) Start frontend: npm start"
