#!/bin/sh
# wait-for-it.sh script za čekanje da MySQL bude spreman

host="$1"
echo "Waiting for MySQL at $host..."

until mysql -h"${host%:*}" -P"${host#*:}" -uroot -p"Test@123" -e 'SELECT 1' 2>/dev/null; do
  echo "MySQL is unavailable - waiting"
  sleep 3
done

echo "MySQL is up - continuing"
