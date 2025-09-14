# Migration Step 2.1: Add `email-service` to Development Compose File

**Objective:** Teach the development environment how to run the `email-service`.

**Action:** Add the service definition for `email-service` to the `dev/docker-compose.yml` file.

**Agent Task:**
```
replace(
    file_path='/home/qtym/system-management/dev/docker-compose.yml',
    old_string='# --- Example Service Definition ---',
    new_string='''# --- Service Definitions ---
  email-service:
    image: ghcr.io/YOUR_ORG/email-service:dev
    restart: always
    networks:
      - dev_network
    env_file:
      - .env.dev
    ports:
      - "3001:3000" # Mapped to 3001 to avoid local conflicts'''
)
```
