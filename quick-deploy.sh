#!/bin/bash

# Quick Deploy Script for SplitSmart
# Usage: ./quick-deploy.sh [your-dockerhub-username] [mongodb-uri]

set -e

DOCKER_USERNAME=${1:-"01FE23BCS032"}
MONGODB_URI=${2:-"mongodb+srv://01fe23bcs032_db_user:3OUJdIgGUpN2h3fx@cluster0.v0c3ht1.mongodb.net/?"}
APP_NAME="splitsmart"

echo "🎯 SplitSmart Quick Deploy"
echo "=========================="

if [ -z "$MONGODB_URI" ]; then
    echo "❌ Error: MongoDB URI required"
    echo "Usage: ./quick-deploy.sh [dockerhub-username] [mongodb-uri]"
    exit 1
fi

# Step 1: Build and Push Docker Image
echo "📦 Building Docker image..."
docker build -t $DOCKER_USERNAME/$APP_NAME:latest .

echo "⬆️  Pushing to Docker Hub..."
docker push $DOCKER_USERNAME/$APP_NAME:latest

# Step 2: Update Kubernetes files with actual values
echo "📝 Updating Kubernetes configurations..."
sed -i.bak "s|01FE23BCS032|$DOCKER_USERNAME|g" k8s/deployment.yaml
sed -i.bak "s|mongodb+srv://01fe23bcs032_db_user:3OUJdIgGUpN2h3fx@cluster0.v0c3ht1.mongodb.net/?|$MONGODB_URI|g" k8s/secret.yaml

# Step 3: Deploy to Kubernetes
echo "☸️  Deploying to Kubernetes..."
kubectl apply -f k8s/

# Step 4: Wait for deployment
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/splitsmart-deployment

# Step 5: Display status
echo ""
echo "✅ Deployment Complete!"
echo "======================"
kubectl get all -l app=splitsmart

echo ""
echo "🌐 Access your app:"
echo "Run: kubectl port-forward service/splitsmart-service 8080:80"
echo "Then visit: http://localhost:8080"

# Restore backup files
mv k8s/deployment.yaml.bak k8s/deployment.yaml
mv k8s/secret.yaml.bak k8s/secret.yaml
