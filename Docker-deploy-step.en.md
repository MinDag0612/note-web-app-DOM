# CLOUD DEPLOY - DOCKER VERSION

## Steps after SSHing into the cloud server
### Clone git repo:
```bash
git clone https://github.com/MinDag0612/NoteWeb
```

### Switch to the docker branch
```bash
git checkout feature-docker-containerization
```

### If not available locally
```bash
git checkout -b feature-docker-containerization
git pull origin feature-docker-containerization
```

### Install Docker & Docker Compose
```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
```

### Setup Env
In this step, manually set up the env based on the template so the backend can run
```bash
cp .env.example .env
nano .env
chmod 600 .env
```

### Run the following command:
Run backend and database
```bash
docker compose -f docker-compose.image.yml up -d backend mongodb
```

### Restore mongo into the container
```bash
docker exec -it mongodb mongorestore --drop /dump
```
### CONFIG NGINX
## Step 1
Configuration is almost similar to Deploy-step.md

Install nginx:
```bash
sudo apt install nginx -y
```

Check if it is running - Active: active (running)
```bash
sudo systemctl status nginx
```

Allow port 80 (if using UFW)
```bash
sudo ufw allow 'Nginx Full'
```
## Step 2
Create directory for build files
```bash
sudo mkdir -p /var/www/NoteWeb/build
```
Use a temporary container to extract build files to the host machine
```bash
docker run --rm \
  -v /var/www/NoteWeb/build:/mnt/output \
  bkgamer1412/noteweb-frontend:latest \
  cp -r /app/build/. /mnt/output/
```
Check on the server:
```bash
ls /var/www/NoteWeb/build
```
Grant permissions to nginx
```bash
sudo chown -R www-data:www-data /var/www/NoteWeb
sudo chmod -R 755 /var/www/NoteWeb
```
## Step 3
Remove default config:
```bash
sudo rm /etc/nginx/sites-enabled/default
```
Create a new one:
```bash
sudo nano /etc/nginx/sites-available/noteweb
```
Paste the exact config into nginx.conf (change server_name to your cloud ip/domain name)
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
Enable config
```bash
sudo ln -s /etc/nginx/sites-available/noteweb /etc/nginx/sites-enabled/
```
Check syntax and reload
```bash
sudo nginx -t
sudo systemctl reload nginx
```

#### Open the IP/domain set in the conf to test
### Helper commands:

Remove compose containers + networks + volumes
```bash
docker compose -f docker-compose.image.yml down  -v
```
Test nginx configuration
```bash
sudo nginx -t
```
Reload nginx
```bash
sudo systemctl reload nginx
```
Check Docker
```bash
docker --version
docker compose version
```
Check Docker service
```bash
sudo systemctl status docker
sudo systemctl is-enabled docker
```
Check host-level reverse proxy (e.g., Nginx)
```bash
sudo systemctl status nginx
```
Check pulled images from registry
```bash
docker images
```
Check running containers
```bash
docker ps
```
Restart containers
```bash
docker compose -f docker-compose.image.yml  restart
```
