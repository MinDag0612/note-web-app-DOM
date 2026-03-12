sau khi ssh và server



clone git repo về

* **mkdir /var/www**
* **cd /var/www**
* **git clone https://github.com/MinDag0612/NoteWeb**
* 

Kiểm tra

* **ls ->** thấy project là ok



tải Node.js LTS

* **curl -fsSL https://deb.nodesource.com/setup\_20.x | sudo -E bash -**
* **sudo apt install -y nodejs**



Chạy file scrips

* **chmod +x deploy.sh**
* **./deploy.sh**
* Phải thấy === DEPLOY DONE ===



Set môi trường

* **nano /var/www/NoteWeb/.env**
* Dán .env vào -> save lại
* **change mode cho .env: chmod 600 /var/www/NoteWeb/.env**

chmod 600 nghĩa là



Owner   : read + write   (rw-)

Group   : ---            (không xem được)

Others  : ---            (không xem được)



Chỉ user sở hữu file mới đọc/ghi được .env



config NginX

*  	**apt install nginx** -> cài NginX
*  	nano **/var/www/NoteWeb/nginx.conf** -> tự config

 	hoặc **cp /var/www/NoteWeb/nginx.conf /etc/nginx/sites-available/noteweb** -> copy file qua -> Kiểm tra nano -> lưu ý config lại theo IP của mình



*  	**ln -s /etc/nginx/sites-available/noteweb /etc/nginx/sites-enabled/** -> Kích hoạt site
*  	**rm /etc/nginx/sites-enabled/default** -> Disable mặc định
*  	**nginx -t** -> tets lại
*  	**systemctl reload nginx** -> reload
*  	Check lại 	**ls /etc/nginx/sites-available**
* 

 			**ls /etc/nginx/sites-enabled**



**-> Đến đây có thể truy cập vào ip xem UI lên chưa -> không cần mở port hay cấu hình firewall vì 80 mở mặc định**





Tạo systemd service cho backend

* **nano /etc/systemd/system/backend.service**



\\\\\\\\\\

\[Unit]

Description=FastAPI Backend

After=network.target



\[Service]

User=root

WorkingDirectory=/var/www/NoteWeb

EnvironmentFile=/var/www/NoteWeb/.env

ExecStart=/var/www/NoteWeb/backendSrc/venv/bin/gunicorn \\

          backendSrc.main:app \\

          --bind 127.0.0.1:8000 \\

          --workers 2 \\

          --worker-class uvicorn.workers.UvicornWorker

Restart=always



\[Install]

WantedBy=multi-user.target

\\\\\\\\\\\\



Chạy systemd để FastAPI chạy trong venv



**systemctl daemon-reexec**

**systemctl daemon-reload**

**systemctl enable backend**

**systemctl start backend**

dùng venv để cô lập môi trường Python của project, tránh xung đột thư viện và đảm bảo backend luôn chạy đúng version dependency mà không ảnh hưởng đến hệ thống.



**systemctl status backend** -> test





**curl http://127.0.0.1:8000/**-> check nội bộ, phải thấy {"status":"API is running"}



**journalctl -u backend -n 50 --no-pager** -> xem lỗi nếu có



Có thể vào máy ảo (**source venv/bin/activate**) - ở thư mục NoteWeb chạy thử **uvicorn backendSrc.main:app --reload --host 127.0.0.1 --port 8000 -** nếu có lỗi app sẽ khong lên

deactivate



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



