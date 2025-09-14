# Migration Step 2.2: Add `email-service` to Production Compose File

**Objective:** Teach the production environment how to run the `email-service`.

**Action:** Add the service definition for `email-service` to the `prod/docker-compose.yml` file.

**Agent Task:**
```
replace(
    file_path='/home/qtym/system-management/prod/docker-compose.yml',
    old_string='# --- Example Service Definition ---',
    new_string='''# --- Service Definitions ---
  email-service:
    image: ghcr.io/YOUR_ORG/email-service:v1.0.0 # This tag will be updated by your release process
    restart: always
    networks:
      - prod_network
    env_file:
      - .env.prod'''
)
```
