#!/bin/bash

echo "=== Brisanje Grocery Web Aplikacije ==="

echo "Zaustavljanje i brisanje kontejnera..."
docker-compose down

echo "Brisanje volumena..."
docker volume rm $(docker volume ls -q | grep "grocery-web-app_mysql-data") 2>/dev/null || true

echo "Brisanje Docker slika..."
docker rmi grocery-web-app_frontend grocery-web-app_backend 2>/dev/null || true

echo "Brisanje Docker mreže..."
docker network rm grocery-web-app_grocery-web-network 2>/dev/null || true

echo "=== Aplikacija je uspješno obrisana. ==="
echo "Za ponovnu pripremu aplikacije koristite ./pripremi_aplikaciju.sh"
