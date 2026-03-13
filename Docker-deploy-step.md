# CLOUD DEPLOY - DOCKER VERSION

## Các bước sau khi đã ssh vào cloud server
### Clone git repo:
```bash
git clone https://github.com/MinDag0612/NoteWeb
```

### chuyển sang nhánh docker
```bash
git checkout feature-docker-containerization
```

### (Trường hơp nếu chưa có ở local)
```bash
git checkout -b feature-docker-containerization
git pull origin feature-docker-containerization
```

### Cài Docker & Docker Compose
```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
```

### Chạy lệnh sau:
```bash
docker compose -f docker-compose.image.yml up -d
```

### Restore mongo vào container
```bash
docker exec -it mongodb mongorestore --drop /dump
```
### CONFIG NGINX
## Bước 1
config gần như tương tự bên Deploy-step.md

Cài nginx:
```bash
sudo apt install nginx -y
```

Kiểm tra có chạy hay không - Active: active (running)
```bash
sudo systemctl status nginx
```

Cho phép port 80 (nếu dùng UFW)
```bash
sudo ufw allow 'Nginx Full'
```
## Bước 2
Copy file build trong project
```bash
sudo mkdir -p /var/www/NoteWeb/build
sudo docker cp react:/app/build/. /var/www/NoteWeb/build/
```
Kiểm tra trên server:
```bash
ls /var/www/NoteWeb/build
```
Cấp quyền cho nginx
```bash
sudo chown -R www-data:www-data /var/www/NoteWeb
sudo chmod -R 755 /var/www/NoteWeb
```
## Bước 3
Xóa config mặc định:
```bash
sudo rm /etc/nginx/sites-enabled/default
```
Tạo mới:
```bash
sudo nano /etc/nginx/sites-available/noteweb
```
Dán đúng config trong nginx.conf
```bash
server {
    listen 80;
    server_name _;

    # React build
    root /var/www/NoteWeb/build;
    index index.html;

    # React Router (SPA)
    location / {
        try_files $uri $uri/ /index.html;
    }

    # FastAPI
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        # proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Proto http;

        proxy_redirect off;
    }
}

```
Kích hoạt config
```bash
sudo ln -s /etc/nginx/sites-available/noteweb /etc/nginx/sites-enabled/
```
### Helper commands:

Xóa container + network + volume của compose
```bash
docker compose -f docker-compose.image.yml down  -v
```
Test cấu hình nginx
```bash
sudo nginx -t
```
Reload nginx
```bash
sudo systemctl reload nginx
```
Kiểm tra Docker
```bash
docker --version
docker compose version
```
Kiểm tra Docker service
```bash
sudo systemctl status docker
sudo systemctl is-enabled docker
```
Kiểm tra reverse proxy host-level (ví dụ Nginx)
```bash
sudo systemctl status nginx
```
Kiểm tra image đã pull từ registry
```bash
docker images
```
Kiểm tra container chạy
```bash
docker ps
```
Restart container
```bash
docker compose -f docker-compose.image.yml  restart
```
