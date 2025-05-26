#!/bin/bash

echo "=== Pripremanje Grocery Web Aplikacije ==="

echo "=== Izgradnja Docker slika ==="
docker-compose build

echo "Priprema aplikacije je uspješno završena!"
echo "Koristi ./pokreni_aplikaciju.sh za pokretanje aplikacije."
