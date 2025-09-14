#!/bin/bash

# This script handles the deployment of a single service.
# It is called by the deployment GitHub Action in this repository.

set -e # Exit immediately if a command exits with a non-zero status.

# --- Parameters ---
# $1: ENVIRONMENT (e.g., "dev" or "prod")
# $2: SERVICE_NAME (e.g., "email-service")
# $3: IMAGE_TAG (e.g., "dev" or "v1.2.1")

ENVIRONMENT=$1
SERVICE_NAME=$2
IMAGE_TAG=$3 # Note: The image tag is defined in the docker-compose file, this is for logging/verification

if [ -z "$ENVIRONMENT" ] || [ -z "$SERVICE_NAME" ]; then
    echo "Usage: $0 <ENVIRONMENT> <SERVICE_NAME>"
    exit 1
fi

echo "---"
echo "Starting deployment for service '$SERVICE_NAME' to environment '$ENVIRONMENT'"
echo "Timestamp: $(date)"
echo "---"

# Navigate to the correct environment directory
cd "/home/qtym/system-management/${ENVIRONMENT}"

# Pull the latest image for the service
# The image name and tag are specified in the docker-compose.yml file.
echo "Pulling new image for $SERVICE_NAME..."
docker compose pull $SERVICE_NAME

# Restart the service container
# --no-deps ensures that only the specified service is restarted.
echo "Restarting container for $SERVICE_NAME..."
docker compose up -d --no-deps $SERVICE_NAME

echo "---"
echo "Deployment of '$SERVICE_NAME' to '$ENVIRONMENT' completed successfully."
echo "---"
