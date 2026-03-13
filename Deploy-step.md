sau khi ssh và server

cd /mnt/d/Extend/DOM/MID/demo


# NoteWeb – Fullstack Notes Application

A fullstack note-taking web application built with **ReactJS**, **FastAPI**, and **MySQL**, deployed using **Nginx** and **systemd**.

This project demonstrates a typical **production deployment pipeline** including backend service management, reverse proxy configuration, and environment isolation using Python virtual environments.

---

# Project Architecture

```
Client (Browser)
        │
        ▼
      Nginx
 (Reverse Proxy)
        │
        ▼
     FastAPI
   (Gunicorn +
   Uvicorn Worker)
        │
        ▼
      MySQL
```

Frontend is served by **Nginx**, while API requests are forwarded to the **FastAPI backend** running on `127.0.0.1:8000`.

---

# Tech Stack

### Frontend

* ReactJS
* Vite

### Backend

* FastAPI
* Python
* Gunicorn
* Uvicorn Worker

### Infrastructure

* Nginx (Reverse Proxy)
* systemd (Process Manager)
* Linux Server

### Database

* MonggoDB

---

# Deployment

The project includes an **automation script (`deploy.sh`)** that installs dependencies and prepares the environment automatically.

### 1. Clone repository

```bash
mkdir /var/www
cd /var/www
git clone https://github.com/MinDag0612/NoteWeb
ls
```

`ls` is used to verify the project was cloned successfully.

---

# 2. Run deployment script

```bash
chmod +x deploy.sh
./deploy.sh
```

The script will automatically:

* install required runtimes
* install backend dependencies
* create Python virtual environment
* build the frontend
* prepare project directories

Successful deployment will output:

```
=== DEPLOY DONE ===
```



NOTE 
---
```bash
chmod 600 /var/www/NoteWeb/.env
```

### Permission explanation

| User   | Permission   |
| ------ | ------------ |
| Owner  | read + write |
| Group  | none         |
| Others | none         |

Only the owner can access the `.env` file to prevent **API keys or database credentials from leaking**.

---

# Nginx Configuration

Nginx acts as a **reverse proxy** for the backend API.

Copy the project configuration:

```bash
cp /var/www/NoteWeb/nginx.conf /etc/nginx/sites-available/noteweb
```

Enable the site:

```bash
ln -s /etc/nginx/sites-available/noteweb /etc/nginx/sites-enabled/
```

Disable the default configuration:

```bash
rm /etc/nginx/sites-enabled/default
```

Test configuration:

```bash
nginx -t
```

Reload Nginx:

```bash
systemctl reload nginx
```

Verify configuration:

```bash
ls /etc/nginx/sites-available
ls /etc/nginx/sites-enabled
```

---

# Testing Frontend

Open browser:

```
http://SERVER_IP
```

If the React UI loads successfully, the **frontend and Nginx are working correctly**.

Port **80** is typically open by default.

---

# Backend Service (systemd)

Backend runs as a **systemd service** to ensure automatic startup and crash recovery.

Service file location:

```
/etc/systemd/system/backend.service
```

Example configuration:

```
[Unit]
Description=FastAPI Backend
After=network.target

[Service]
User=root
WorkingDirectory=/var/www/NoteWeb
EnvironmentFile=/var/www/NoteWeb/.env

ExecStart=/var/www/NoteWeb/backendSrc/venv/bin/gunicorn \
          backendSrc.main:app \
          --bind 127.0.0.1:8000 \
          --workers 2 \
          --worker-class uvicorn.workers.UvicornWorker

Restart=always

[Install]
WantedBy=multi-user.target
```

### Key options

**WorkingDirectory**

Project root directory.

**EnvironmentFile**

Loads environment variables from `.env`.

**Gunicorn + Uvicorn Worker**

Production server for running FastAPI.

**Restart=always**

Automatically restarts backend if it crashes.

---

# Start Backend Service

Reload systemd configuration:

```bash
systemctl daemon-reexec
systemctl daemon-reload
```

Enable auto-start:

```bash
systemctl enable backend
```

Start the backend:

```bash
systemctl start backend
```

---

# Backend Health Check

Check service status:

```bash
systemctl status backend
```

Test API internally:

```bash
curl http://127.0.0.1:8000/
```

Expected response:

```
{"status":"API is running"}
```

---

# Debugging

### Check backend logs

```bash
journalctl -u backend -n 50 --no-pager
```

| Option       | Meaning                      |
| ------------ | ---------------------------- |
| `-u backend` | logs for backend service     |
| `-n 50`      | last 50 lines                |
| `--no-pager` | display directly in terminal |

---

### Manual backend test

Activate virtual environment:

```bash
source venv/bin/activate
```

Run backend manually:

```bash
uvicorn backendSrc.main:app --reload --host 127.0.0.1 --port 8000
```

If the application has errors, they will appear directly in the terminal.

Deactivate environment:

```
deactivate
```

---

# Production Setup

Optional steps after deployment:

* configure **domain → server IP**
* enable **HTTPS (Let's Encrypt)**

---

# Security Notes

* `.env` permissions restricted with `chmod 600`
* backend bound to **localhost (127.0.0.1)** only
* external traffic handled through **Nginx reverse proxy**

---

# Author

**MinDag**

IT Student – Web Development / System Deployment Project




**Test web và config Domain trỏ tới IP
Config HTTPS**



0️⃣ Điều kiện bắt buộc (trước khi xin)

✔ Có domain (vd: dangtm.pro)
✔ Domain đã trỏ A record → IP server
✔ Nginx đã cài
✔ Port 80 \& 443 mở (UFW + DigitalOcean Firewall)



3️⃣ Cài Certbot + plugin Nginx

**sudo apt update
sudo apt install certbot python3-certbot-nginx -y**



5️⃣ Xin HTTPS (LET’S ENCRYPT)
**sudo certbot --nginx -d dangtm.pro -d www.dangtm.pro**



Bot sẽ tự làm
✔ Nhập email
✔ Agree Terms
✔ Certbot tự:

xin cert

sửa file nginx

cấu hình SSL

reload nginx

6️⃣ Kiểm tra cert đã có chưa
**ls /etc/letsencrypt/live/dangtm.pro/**



Phải thấy:

fullchain.pem
privkey.pem



kiểm tra lại file nginx đang chạy trong **/etc/nginx/sites-enabled/ //name**

Sẽ thấy các dòng **# managed by Certbot**



**check lại domain với https**



