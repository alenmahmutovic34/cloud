#!/bin/bash

echo "=== Pokretanje Grocery Web Aplikacije ==="

docker-compose up -d

echo "Čekanje da svi servisi budu spremni..."
sleep 30

CONTAINERS_STATUS=$(docker-compose ps --services --filter "status=running" | wc -l)

if [ "$CONTAINERS_STATUS" -eq 3 ]; then
    echo "Svi servisi su uspješno pokrenuti!"
    echo ""
    echo "===== APLIKACIJA JE USPJEŠNO POKRENUTA! ====="
    echo "Frontend je dostupan na: http://localhost"
    echo "Backend API je dostupan na: http://localhost:5000"
    echo "Baza podataka je dostupna na: localhost:3306"
    echo ""
    echo "Koristi ./zaustavi_aplikaciju.sh za zaustavljanje aplikacije."
else
    echo "GREŠKA: Neki servisi nisu uspješno pokrenuti."
    echo "Provjerite docker-compose logs za više detalja."
    docker-compose logs
fi
