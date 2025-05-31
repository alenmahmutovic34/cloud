#!/bin/bash
exec > >(tee /var/log/user-data.log) 2>&1
echo "Starting user data script at $(date)"

# Update packages
sudo yum update -y

# Enable amazon-linux-extras repo for docker
sudo amazon-linux-extras enable docker

# Install docker and git
sudo yum install -y docker git curl

# Start and enable docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to docker group
sudo usermod -a -G docker ec2-user

# Create webapp directory
mkdir -p /opt/webapp
cd /opt/webapp

echo "Cloning repository..."
git clone ${git_repo_url} .

# Wait for Docker to be fully ready
sleep 10

# Create Docker network
docker network create webapp-network 2>/dev/null || true

echo "Building Docker images..."

# Build backend image
docker build -f Dockerfile.backend -t webapp-backend .

# Build frontend image  
docker build -f Dockerfile.frontend -t webapp-frontend .

# Create backend environment file with RDS connection
cat > backend_env.txt << EOF
NODE_ENV=production
PORT=3000
DB_HOST=${db_host}
DB_PORT=5432
DB_NAME=${db_name}
DB_USER=${db_username}
DB_PASSWORD=${db_password}
EOF

echo "Starting backend container..."
# Start Backend (connecting to RDS, not local PostgreSQL)
docker run -d \
    --name webapp-backend \
    --network webapp-network \
    --env-file backend_env.txt \
    -p 3000:3000 \
    webapp-backend

# Wait for backend to be ready
echo "Waiting for backend to be ready..."
for i in {1..30}; do
    if curl -f http://localhost:3000/health &> /dev/null; then
        echo "✅ Backend is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Backend failed to start"
        docker logs webapp-backend
        exit 1
    fi
    sleep 5
done

echo "Starting frontend container..."
# Start Frontend (without nginx proxy to backend since ALB handles routing)
docker run -d \
    --name webapp-frontend \
    --network webapp-network \
    -p 80:80 \
    webapp-frontend

# Wait for frontend to be ready
echo "Waiting for frontend to be ready..."
for i in {1..20}; do
    if curl -f http://localhost/ &> /dev/null; then
        echo "✅ Frontend is ready"
        break
    fi
    if [ $i -eq 20 ]; then
        echo "❌ Frontend failed to start"
        docker logs webapp-frontend
        exit 1
    fi
    sleep 3
done

echo "✅ Fullstack application is ready!"
echo "Backend: http://localhost:3000"
echo "Frontend: http://localhost:80"
echo "Database: RDS PostgreSQL at ${db_host}"

# Cleanup
rm -f backend_env.txt

echo "User data script completed at $(date)"
