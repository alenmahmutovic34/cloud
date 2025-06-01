#!/bin/bash
yum update -y
yum install -y docker git
service docker start
usermod -a -G docker ec2-user

cd /home/ec2-user
git clone https://github.com/IbrahimSelimovic786/Cloud.git
cd Cloud

# Backend build i run (pretpostavka: backend ima Dockerfile i koristi port 8085)
cd backend
docker build -t backend-app .
docker run -d -p 8085:8085 --name backend-container backend-app &

# Frontend build i run (pretpostavka: frontend ima Dockerfile i koristi nginx na portu 80)
cd ../frontend
docker build -t frontend-app .
docker run -d -p 80:80 --name frontend-container frontend-app &
