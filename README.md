# System Management

This repository is the central source of truth for the architecture and deployment of all services in the `dev` and `prod` environments. It uses Docker Compose for container orchestration and Terraform for infrastructure management.

## Overview

- `/dev`: Contains the `docker-compose.yml` and environment variable templates for the **Development** environment.
- `/prod`: Contains the `docker-compose.yml` and environment variable templates for the **Production** environment.
- `/terraform`: Manages all Terraform-based infrastructure (like Hubitat configurations). It uses workspaces to separate `dev` and `prod` states.
- `/scripts`: Contains helper scripts, primarily for deployment automation.
- `/docs`: Contains detailed documentation, including the process for onboarding new applications.

## Core Concepts

- **Environment Isolation**: The `dev` and `prod` environments are completely isolated using separate Docker networks (`dev_network`, `prod_network`).
- **Service Discovery**: Services within an environment can communicate with each other using their service name as the hostname (e.g., `http://email-service:3000`), thanks to Docker's internal DNS.
- **CI/CD**: Deployments are automated via GitHub Actions.
    1. An application's repository builds and pushes a Docker image to GHCR.
    2. It then sends a `repository_dispatch` event to this repository.
    3. A GitHub Action in this repository catches the event and runs the `scripts/deploy.sh` script on the local runner to update the relevant service.

## Getting Started

1. **Prerequisites**: Ensure Docker, Docker Compose, and Terraform are installed on the host machine/runner.
2. **Configuration**: Copy the `.env.template` files in `/dev` and `/prod` to `.env.dev` and `.env.prod` respectively. Fill in the required environment variables. **These `.env` files should be in your `.gitignore` and never committed.**
3. **Initial Deployment**: To bring up an entire environment for the first time, navigate to the environment directory and run:
   ```bash
   cd dev/
   docker-compose up -d
   ```

For detailed instructions on adding a new service, see [`docs/ONBOARDING_NEW_APP.md`](./docs/ONBOARDING_NEW_APP.md).
