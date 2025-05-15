#!/bin/bash

# Set variables
AWS_REGION="ap-south-1"  # Replace with your region
ECR_REPO_URL="864981745854.dkr.ecr.ap-south-1.amazonaws.com/nodejs"  # Replace with your ECR repo URL
IMAGE_TAG="latest"  # Replace with your desired tag
CONTAINER_NAME="nodejs"

# Function to print error and exit
function error_exit {
    echo "Error: $1"
    exit 1
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    error_exit "Docker is not installed."
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    error_exit "AWS CLI is not installed."
fi

# Authenticate Docker to ECR
echo "Logging into ECR..."
aws ecr get-login-password --region "$AWS_REGION" | \
docker login --username AWS --password-stdin "$ECR_REPO_URL" || error_exit "Failed to log in to ECR."

# Pull the image from ECR
echo "Pulling Docker image: $ECR_REPO_URL:$IMAGE_TAG"
docker pull "$ECR_REPO_URL:$IMAGE_TAG" || error_exit "Failed to pull image."

# Check if a container with the same name already exists and remove it
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
    echo "Removing existing container: $CONTAINER_NAME"
    docker rm -f "$CONTAINER_NAME" || error_exit "Failed to remove existing container."
fi

# Run the container in detached mode with restart policy
echo "Running container '$CONTAINER_NAME' in detached mode with restart=always..."
docker run -d \
  --name "$CONTAINER_NAME" \
  --restart=always \
  -p 5000:5000 \
  "$ECR_REPO_URL:$IMAGE_TAG" || error_exit "Failed to run container."

echo "Container '$CONTAINER_NAME' is now running with auto-restart enabled."

