#!/bin/bash
sudo apt update -y
sudo apt install python3-pip git -y

# Clone your repo
git clone https://github.com/GeyasreeR/Tutedude-docker.git /home/ubuntu/backend
cd /home/ubuntu/backend/backend

python3 -m venv venv

. venv/bin/activate

# Install requirements
pip3 install -r requirements.txt

# Run Flask
nohup python3 app.py --host=0.0.0.0 --port=5000 &
