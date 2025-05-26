#!/bin/bash

echo "=== Zaustavljanje Grocery Web Aplikacije ==="

docker-compose stop

echo "Svi servisi su zaustavljeni. Podaci su sačuvani."
echo "Za ponovno pokretanje koristite ./pokreni_aplikaciju.sh"
echo "Za potpuno brisanje aplikacije koristite ./obrisi_aplikaciju.sh"
