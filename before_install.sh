#!/bin/bash

# Function to print error and exit
function error_exit {
    echo "Error: $1"
    exit 1
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    error_exit "Docker is not installed."
fi

echo "Docker is installed."

# Check if a container named 'nodejs' is running
container_status=$(docker ps --filter "name=nodejs" --filter "status=running" --format "{{.Names}}")

if [ -z "$container_status" ]; then
    echo "No running container named 'nodejs' found. Exiting."
    exit 0
else
    echo "Container 'nodejs' is running. Stopping it..."
    docker stop nodejs || error_exit "Failed to stop container 'nodejs'."

    echo "Removing container 'nodejs'..."
    docker rm nodejs || error_exit "Failed to remove container 'nodejs'."

    # Get the image ID used by the stopped container
    image_id=$(docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | grep "^nodejs:" | awk '{print $2}')

    if [ -n "$image_id" ]; then
        echo "Removing image associated with 'nodejs': $image_id"
        docker rmi "$image_id" || error_exit "Failed to remove image $image_id."
    else
        echo "No image found for repository 'nodejs'."
    fi

    echo "Container and image cleanup complete."
fi
