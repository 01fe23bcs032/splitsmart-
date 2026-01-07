#!/bin/bash

# SplitSmart Kubernetes Deployment Script

echo "🚀 Starting SplitSmart Deployment..."

# Configuration
DOCKER_USERNAME="01FE23BCS032"
APP_NAME="splitsmart"
VERSION="latest"

# Step 1: Build Docker Image
echo "📦 Building Docker image..."
docker build -t $DOCKER_USERNAME/$APP_NAME:$VERSION .

# Step 2: Push to Docker Hub
echo "⬆️  Pushing image to Docker Hub..."
docker push $DOCKER_USERNAME/$APP_NAME:$VERSION

# Step 3: Apply Kubernetes configurations
echo "☸️  Applying Kubernetes configurations..."

# Apply ConfigMap
kubectl apply -f k8s/configmap.yaml

# Apply Secret (make sure to update with your MongoDB URI first!)
kubectl apply -f k8s/secret.yaml

# Apply Deployment
kubectl apply -f k8s/deployment.yaml

# Apply Service
kubectl apply -f k8s/service.yaml

# Step 4: Wait for deployment
echo "⏳ Waiting for deployment to be ready..."
kubectl rollout status deployment/splitsmart-deployment

# Step 5: Get service information
echo "✅ Deployment complete!"
echo ""
echo "📊 Service Status:"
kubectl get services splitsmart-service

echo ""
echo "🔍 Pod Status:"
kubectl get pods -l app=splitsmart

echo ""
echo "🌐 Access your application:"
kubectl get service splitsmart-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
