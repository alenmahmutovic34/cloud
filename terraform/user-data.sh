#!/bin/bash

# Log sve što se dešava
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Počinje User Data skripta..."

# Update sistema
yum update -y

# Instalacija Docker-a
yum install -y docker git

# Pokretanje Docker servisa
systemctl start docker
systemctl enable docker

# Dodavanje ec2-user u docker grupu
usermod -a -G docker ec2-user

# Instalacija Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Kreiranje simboličke veze
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Pripremanje EBS volumena
echo "Priprema EBS volumena..."

# Čeka da EBS volumen bude dostupan
while [ ! -e ${ebs_device} ]; do
  echo "Čeka EBS volumen ${ebs_device}..."
  sleep 5
done

# Kreiranje file sistema ako ne postoji
if ! blkid ${ebs_device}; then
  echo "Kreiranje ext4 file sistema na ${ebs_device}"
  mkfs.ext4 ${ebs_device}
fi

# Kreiranje mount point-a
mkdir -p /mnt/ebs

# Mount EBS volumena
mount ${ebs_device} /mnt/ebs

# Dodavanje u fstab za perzistentno mount-ovanje
echo "${ebs_device} /mnt/ebs ext4 defaults,nofail 0 2" >> /etc/fstab

# Kreiranje direktorijuma za MySQL podatke
mkdir -p /mnt/ebs/mysql-data
chown -R ec2-user:ec2-user /mnt/ebs

# Prebacivanje na ec2-user za kloniranje repozitorija
cd /home/ec2-user

# Kloniranje Git repozitorija
echo "Kloniranje Git repozitorija: ${git_repo_url}"
git clone ${git_repo_url} app-repo

# Navigacija u direktorij sa aplikacijom
cd app-repo/klaud_projekat1

# Kreiranje modifikovanog docker-compose.yml koji koristi EBS
cat > docker-compose-aws.yml << 'EOF'
version: '3.8'

services:
  frontend:
    build:
      context: .
      dockerfile: ./frontend.Dockerfile
    ports:
      - "8080:80"
    depends_on:
      - backend
    restart: unless-stopped
    networks:
      - grocery-web-network

  backend:
    build:
      context: .
      dockerfile: ./backend.Dockerfile
    ports:
      - "5000:5000"
    volumes:
      - ./backend:/app
    depends_on:
      - db
    entrypoint: ["/bin/sh", "-c", "/app/wait-for-it.sh db:3306 && python server.py"]
    environment:
      - DB_HOST=db
      - DB_USER=root
      - DB_PASSWORD=Test123456
      - DB_NAME=grocery_store
      - MYSQL_ALLOW_EMPTY_PASSWORD=yes
    restart: on-failure
    networks:
      - grocery-web-network

  db:
    image: mysql:8.0
    ports:
      - "3306:3306"
    volumes:
      - /mnt/ebs/mysql-data:/var/lib/mysql
      - ./database:/docker-entrypoint-initdb.d
    environment:
      - MYSQL_ROOT_PASSWORD=Test123456
      - MYSQL_DATABASE=grocery_store
      - MYSQL_ROOT_HOST=%
    command: --default-authentication-plugin=mysql_native_password
    restart: unless-stopped
    networks:
      - grocery-web-network

networks:
  grocery-web-network:
    driver: bridge
EOF

# Kreiranje osnovnog health check endpointa ako ne postoji
mkdir -p ./backend/health
cat > ./backend/health_check.py << 'EOF'
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/api/health')
def health_check():
    return jsonify({"status": "healthy", "message": "Backend is running"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
EOF

# Promena vlasništva fajlova
chown -R ec2-user:ec2-user /home/ec2-user/app-repo

# Pokretanje aplikacije kao ec2-user
echo "Pokretanje aplikacije..."
sudo -u ec2-user docker-compose -f docker-compose-aws.yml up -d --build

echo "User Data skripta završena!"

# Čeka da se kontejneri pokrenu
sleep 30

# Provjera statusa kontejnera
echo "Status kontejnera:"
sudo -u ec2-user docker-compose -f docker-compose-aws.yml ps
