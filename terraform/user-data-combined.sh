#!/bin/bash
yum update -y
yum install -y docker git
service docker start
usermod -a -G docker ec2-user

cd /home/ec2-user
if [ ! -d "cloud" ]; then
  git clone https://github.com/alenmahmutovic34/cloud.git
fi
cd cloud

# Backend build i run
docker build -f backend.Dockerfile -t backend-app .
docker run -d --name backend-container --restart unless-stopped -p 8085:8085 backend-app

# Frontend run sa bind mount iz ui foldera
docker run -d --name frontend-container --restart unless-stopped -p 80:80 -v /home/ec2-user/cloud/ui:/usr/share/nginx/html:ro nginx:alpine



