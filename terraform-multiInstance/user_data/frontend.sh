#!/bin/bash
sudo apt update -y


# Clone your repo
git clone https://github.com/GeyasreeR/Tutedude-docker.git /home/ubuntu/frontend
cd /home/ubuntu/frontend/frontend
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install dependencies
npm install

# Run Express
nohup node server.js &