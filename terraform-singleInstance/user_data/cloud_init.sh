#!/bin/bash
set -e

# ----------------- Install dependencies -----------------
apt-get update -y
apt-get install -y git python3 python3-pip python3-venv nodejs npm

# ----------------- Clone repo -----------------
cd /opt
git clone https://github.com/GeyasreeR/Tutedude-docker.git app

# ----------------- Setup Flask backend -----------------
cd /opt/app/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt || pip install flask

cat <<EOF > /etc/systemd/system/flask.service
[Unit]
Description=Flask Backend
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt/app/backend
Environment="PATH=/opt/app/backend/venv/bin"
ExecStart=/opt/app/backend/venv/bin/python app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# ----------------- Setup Express frontend -----------------
cd /opt/app/frontend
npm install

cat <<EOF > /etc/systemd/system/express.service
[Unit]
Description=Express Frontend
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt/app/frontend
ExecStart=/usr/bin/node index.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# ----------------- Enable and start services -----------------
systemctl daemon-reload
systemctl enable flask.service express.service
systemctl start flask.service express.service
