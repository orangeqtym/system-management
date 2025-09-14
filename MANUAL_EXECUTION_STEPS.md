# Phase 3: Manual Execution and Verification

**Objective:** Commit all changes, configure secrets, and trigger the first automated deployment.

---

### Step 3.1: Set GitHub Secrets

**Action:** You must provide secrets to your GitHub repositories for the automation to work. **This cannot be done by the AI agent.**

1.  **In your `email-service` repository on GitHub:**
    - Go to `Settings` > `Secrets and variables` > `Actions`.
    - Create a new repository secret named `GH_PAT`.
    - The value should be a GitHub Personal Access Token with `repo` and `write:packages` scopes. This allows the `email-service` repo to dispatch an event to this (`system-management`) repo.

2.  **In your `system-management` repository on GitHub:**
    - Ensure you have a self-hosted runner configured and active for this repository.

### Step 3.2: Update Local Environment Files

**Action:** On your machine (`/home/qtym/`), create and populate the actual `.env` files with your secrets.

```bash
# Navigate to the system management directory
cd /home/qtym/system-management

# Create the .env files from the templates
cp dev/.env.template dev/.env.dev
cp prod/.env.template prod/.env.prod

# Now, securely edit dev/.env.dev and prod/.env.prod to fill in the real values.
```

### Step 3.3: Commit Changes

**Action:** Commit the pending changes in both repositories.

1.  **In `/home/qtym/system-management`:**
    ```bash
    git add .
    git commit -m "feat: Add email-service configuration and deployment workflow"
    git push origin main
    ```

2.  **In `/home/qtym/email-service`:**
    ```bash
    git add .
    git commit -m "feat: Add Dockerfile and CI/CD workflow"
    # DO NOT PUSH YET
    ```

### Step 3.4: Trigger the Dev Deployment

**Action:** Push the `develop` branch from the `email-service` repo. This will trigger the entire pipeline for the first time.

```bash
# In /home/qtym/email-service
git checkout -b develop
git push -u origin develop
```

### Step 3.5: Verify the Deployment

**Action:** Watch the GitHub Actions runners in both repositories. Once they complete, verify the service is running on your machine.

```bash
# Check that the container is running
docker ps | grep email-service

# View the logs for the dev service
cd /home/qtym/system-management/dev/
docker-compose logs -f email-service
```
