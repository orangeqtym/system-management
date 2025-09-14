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
IMAGE_TAG=$3

# Load environment variables from the appropriate .env file
ENV_FILE=".env.${ENVIRONMENT}"
if [ -f "$ENV_FILE" ]; then
    set -a # Automatically export all variables
    . "$ENV_FILE"
    set +a
    echo "Loaded environment variables from $ENV_FILE"
else
    echo "Warning: No .env file found for environment $ENVIRONMENT at $ENV_FILE"
fi

# Ensure BASE_RECIPIENT_EMAIL is set from the loaded environment
if [ -z "$BASE_RECIPIENT_EMAIL" ]; then
    echo "Error: BASE_RECIPIENT_EMAIL is not set in $ENV_FILE or as an environment variable."
    exit 1
fi

FINAL_RECIPIENT_EMAIL=$(echo "$BASE_RECIPIENT_EMAIL" | sed "s/@/+$ENVIRONMENT@/")

if [ -z "$ENVIRONMENT" ] || [ -z "$SERVICE_NAME" ]; then
    echo "Usage: $0 <ENVIRONMENT> <SERVICE_NAME> <IMAGE_TAG>"
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
docker compose up -d --no-deps $SERVICE_NAME -e RECIPIENT_EMAIL=$FINAL_RECIPIENT_EMAIL

echo "---"
echo "Deployment of '$SERVICE_NAME' to '$ENVIRONMENT' completed successfully."
echo "---"
