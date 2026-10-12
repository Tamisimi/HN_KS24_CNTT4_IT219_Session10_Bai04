#!/bin/bash
set -e

# 1. Custom Bridge Network
docker network create app-net

# 2. Named Volume
docker volume create db-data

# 3. Database container (Postgres)
docker run -d \
  --name db-server \
  --network app-net \
  -e POSTGRES_USER=app \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=appdb \
  -v db-data:/var/lib/postgresql/data \
  postgres:15-alpine

echo "Waiting for Postgres..."
sleep 8

# 4. Backend container (join app-net, DB host = db-server)
docker run -d \
  --name app-container \
  --network app-net \
  -e DB_HOST=db-server \
  -e DB_PORT=5432 \
  -e DB_USER=app \
  -e DB_PASSWORD=secret \
  -e DB_NAME=appdb \
  alpine:3.19 sleep infinity

docker exec app-container apk add --no-cache iputils >/dev/null

echo "=== network / volume ==="
docker network ls | grep app-net
docker volume ls | grep db-data

echo "=== ping db-server from app-container ==="
docker exec app-container ping -c 2 db-server

echo "=== insert test data ==="
docker exec -e PGPASSWORD=secret db-server \
  psql -U app -d appdb -c "CREATE TABLE IF NOT EXISTS notes(id serial primary key, content text);"
docker exec -e PGPASSWORD=secret db-server \
  psql -U app -d appdb -c "INSERT INTO notes(content) VALUES ('persist-ok');"
docker exec -e PGPASSWORD=secret db-server \
  psql -U app -d appdb -c "SELECT * FROM notes;"

echo "=== recreate db-server (persistence test) ==="
docker rm -f db-server
docker run -d \
  --name db-server \
  --network app-net \
  -e POSTGRES_USER=app \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=appdb \
  -v db-data:/var/lib/postgresql/data \
  postgres:15-alpine

sleep 8
echo "=== data after recreate ==="
docker exec -e PGPASSWORD=secret db-server \
  psql -U app -d appdb -c "SELECT * FROM notes;"
