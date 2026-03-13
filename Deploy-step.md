# Deploy-step.md

This document describes the manual deployment flow for later phases after Phase 1 repository preparation is complete.

## 1. Target Environment

- Ubuntu server
- Nginx
- systemd
- Node.js 20+
- Python 3 + `venv`

## 2. Clone Project

```bash
sudo mkdir -p /var/www
cd /var/www
sudo git clone https://github.com/MinDag0612/note-web-app-DOM.git
cd note-web-app-DOM
```

## 3. Prepare Runtime (Phase 1 Script)

Run the setup script to install dependencies and create runtime directories:

```bash
sudo bash scripts/setup.sh
```

The script installs OS packages/runtimes and creates:

- `logs/`
- `uploads/`
- `data/`
- `backendSrc/logs/`

## 4. Configure Environment Variables

```bash
cp .env.example .env
```

Edit `.env` with real values (MongoDB URI, JWT secret, OAuth, Cloudinary).  
Restrict file permission:

```bash
chmod 600 .env
```

## 5. Deploy Application

Run deployment script:

```bash
sudo bash scripts/deploy.sh
```

The script will:

- pull latest source code
- execute `scripts/setup.sh`
- build frontend
- configure Nginx
- install and restart backend systemd service

## 6. Validate Deployment

Check service status:

```bash
sudo systemctl status backend --no-pager
sudo systemctl status nginx --no-pager
```

Check backend health:

```bash
curl http://127.0.0.1:8000/
```

Expected response:

```json
{"status":"API is running"}
```

Open browser:

```text
http://SERVER_IP
```

## 7. Optional Hardening for Later Phases

- Configure domain DNS to server IP
- Enable HTTPS using Let's Encrypt (`certbot`)
- Restrict CORS origins to your production domain(s)
- Add firewall rules for ports 80/443
