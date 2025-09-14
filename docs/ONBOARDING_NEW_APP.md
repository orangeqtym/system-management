# Onboarding a New Application

This guide provides the step-by-step process for integrating a new application into the `dev` and `prod` environments.

## Step 1: Application Repository Setup

1.  **Create a Dockerfile**: Ensure your application has a well-structured, multi-stage `Dockerfile` at its root.

2.  **Add CI/CD Workflow**: Add a GitHub Actions workflow file at `.github/workflows/ci-cd.yml`. This workflow is responsible for building the Docker image, pushing it to GitHub Container Registry (GHCR), and dispatching a deployment event to the `system-management` repository.

    *A template for this workflow can be found in the `system-management` repository or a shared documentation space.*

## Step 2: Configure `system-management`

1.  **Add Service to Docker Compose**: Add the new service's definition to both `dev/docker-compose.yml` and `prod/docker-compose.yml`.
    - In `dev`, the image tag should point to `:dev`.
    - In `prod`, the image tag should point to a specific version (e.g., `:v1.0.0`) that you will control via your Git tagging strategy.

    ```yaml
    # Example service definition
    new-service-name:
      image: ghcr.io/your-org/new-service-name:dev # or :v1.0.0 for prod
      restart: always
      networks:
        - dev_network # or prod_network
      env_file:
        - .env.dev # or .env.prod
    ```

2.  **Update Environment Templates**: Add any new environment variables required by your service to `dev/.env.template` and `prod/.env.template`. This keeps the documentation of required variables up to date.

3.  **Set Environment Variables**: On the runner machine where deployments occur, update or create the `.env.dev` and `.env.prod` files with the actual values for the variables you just added.

## Step 3: Configure Dependencies

If existing services need to communicate with your new service, you must update their configuration.

1.  **Update `.env` files**: In the `.env.dev` and `.env.prod` files, add or update the URL for the new service in the configuration of any dependent services. For example, if `meal-planner` needs to talk to `new-service-name`:
    ```
    # In the section for meal-planner variables
    NEW_SERVICE_URL=http://new-service-name:8080
    ```

## Step 4: Deploy and Verify

1.  **Deploy to Dev**: Push your application code to the `develop` branch. This will trigger the CI/CD workflow, build the `:dev` image, and deploy it to the development environment.

2.  **Verify**: Check the service logs (`docker-compose logs -f new-service-name`) and test the integration with other `dev` services.

3.  **Deploy to Prod**: Once verified, merge your code into the `main` branch, create a version tag (e.g., `v1.1.0`), and push the tag. This will trigger the workflow to build a versioned image and deploy it to the production environment.
