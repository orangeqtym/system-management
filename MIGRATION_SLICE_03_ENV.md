# Migration Slice 3: Environment Configuration

## Objective
Update system-management environment templates and docker-compose files to integrate the new meal-planner service.

## Prerequisites
- Slice 1 completed (database schema deployed)
- Slice 2 completed (API service created)
- Access to system-management repository

## Tasks

### Task 3.1: Update Development Environment Template
**Location**: `/home/qtym/system-management/dev/`
**Action**: Add meal-planner environment variables to .env.template

Add the following to `/home/qtym/system-management/dev/.env.template`:

```env
# --- Variables for meal-planner-api ---
# Database connection (shared with system database)
MEAL_PLANNER_DB_HOST=database
MEAL_PLANNER_DB_PORT=5432
MEAL_PLANNER_DB_NAME=system_db
MEAL_PLANNER_DB_USER=app_user
MEAL_PLANNER_DB_PASSWORD=${DB_PASSWORD}

# API Configuration
MEAL_PLANNER_PORT=3001
MEAL_PLANNER_CORS_ORIGIN=http://localhost:3000
MEAL_PLANNER_LOG_LEVEL=info
```

### Task 3.2: Update Production Environment Template
**Location**: `/home/qtym/system-management/prod/`
**Action**: Add meal-planner environment variables to .env.template

Add the following to `/home/qtym/system-management/prod/.env.template`:

```env
# --- Variables for meal-planner-api ---
# Database connection (shared with system database)
MEAL_PLANNER_DB_HOST=database
MEAL_PLANNER_DB_PORT=5432
MEAL_PLANNER_DB_NAME=system_db
MEAL_PLANNER_DB_USER=app_user
MEAL_PLANNER_DB_PASSWORD=${DB_PASSWORD}

# API Configuration
MEAL_PLANNER_PORT=3001
MEAL_PLANNER_CORS_ORIGIN=https://your-production-domain.com
MEAL_PLANNER_LOG_LEVEL=warn
```

### Task 3.3: Update Development Docker Compose
**Location**: `/home/qtym/system-management/dev/`
**Action**: Replace placeholder meal-planner-api service with real implementation

Update the `meal-planner-api` service in `/home/qtym/system-management/dev/docker-compose.yml`:

```yaml
  meal-planner-api:
    image: ghcr.io/orangeqtym/meal-planner-api:dev
    restart: always
    networks:
      - dev_network
    env_file:
      - .env.dev
    environment:
      # Database Configuration
      DB_HOST: ${MEAL_PLANNER_DB_HOST}
      DB_PORT: ${MEAL_PLANNER_DB_PORT}
      DB_NAME: ${MEAL_PLANNER_DB_NAME}
      DB_USER: ${MEAL_PLANNER_DB_USER}
      DB_PASSWORD: ${MEAL_PLANNER_DB_PASSWORD}

      # API Configuration
      PORT: ${MEAL_PLANNER_PORT}
      NODE_ENV: development
      CORS_ORIGIN: ${MEAL_PLANNER_CORS_ORIGIN}
      LOG_LEVEL: ${MEAL_PLANNER_LOG_LEVEL}
    ports:
      - "3001:3001"
    depends_on:
      - database
    healthcheck:
      test: ["CMD", "node", "-e", "require('http').get('http://localhost:3001/api/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### Task 3.4: Update Production Docker Compose
**Location**: `/home/qtym/system-management/prod/`
**Action**: Replace placeholder meal-planner-api service with real implementation

Update the `meal-planner-api` service in `/home/qtym/system-management/prod/docker-compose.yml`:

```yaml
  meal-planner-api:
    image: ghcr.io/orangeqtym/meal-planner-api:latest
    restart: always
    networks:
      - prod_network
    env_file:
      - .env.prod
    environment:
      # Database Configuration
      DB_HOST: ${MEAL_PLANNER_DB_HOST}
      DB_PORT: ${MEAL_PLANNER_DB_PORT}
      DB_NAME: ${MEAL_PLANNER_DB_NAME}
      DB_USER: ${MEAL_PLANNER_DB_USER}
      DB_PASSWORD: ${MEAL_PLANNER_DB_PASSWORD}

      # API Configuration
      PORT: ${MEAL_PLANNER_PORT}
      NODE_ENV: production
      CORS_ORIGIN: ${MEAL_PLANNER_CORS_ORIGIN}
      LOG_LEVEL: ${MEAL_PLANNER_LOG_LEVEL}
    ports:
      - "3001:3001"
    depends_on:
      - database
    healthcheck:
      test: ["CMD", "node", "-e", "require('http').get('http://localhost:3001/api/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### Task 3.5: Update Deployment Workflow
**Location**: `/home/qtym/system-management/.github/workflows/`
**Action**: Add meal-planner-api to deployment workflow

Update `/home/qtym/system-management/.github/workflows/deploy.yml` to include meal-planner-api service handling:

Add to the service handling section (around line 65):

```yaml
      - name: Deploy meal-planner-api service
        if: github.event.client_payload.service == 'meal-planner-api'
        run: |
          echo "🚀 Deploying meal-planner-api to ${{ github.event.client_payload.environment }}"
          cd "${{ github.event.client_payload.environment }}"

          # Pull new image
          docker compose pull meal-planner-api

          # Restart service
          docker compose up -d --no-deps meal-planner-api

          # Wait for service to be healthy
          echo "⏳ Waiting for meal-planner-api to be healthy..."
          timeout 60 bash -c 'until docker compose ps meal-planner-api | grep -q "healthy"; do sleep 2; done'

          # Test the service
          if [ "${{ github.event.client_payload.environment }}" = "dev" ]; then
            TEST_URL="http://localhost:3001/api/health"
          else
            TEST_URL="http://localhost:3001/api/health"
          fi

          echo "🧪 Testing meal-planner-api endpoint: $TEST_URL"
          curl -f "$TEST_URL" || exit 1

          echo "✅ meal-planner-api deployment completed successfully"
```

### Task 3.6: Update Current Environment Files
**Location**: `/home/qtym/system-management/dev/` and `/home/qtym/system-management/prod/`
**Action**: Add meal-planner variables to existing .env.dev and .env.prod

**For Development (.env.dev)**:
Add these variables (use actual password from existing DB_PASSWORD):

```env
# --- Variables for meal-planner-api ---
MEAL_PLANNER_DB_HOST=database
MEAL_PLANNER_DB_PORT=5432
MEAL_PLANNER_DB_NAME=system_db
MEAL_PLANNER_DB_USER=app_user
MEAL_PLANNER_DB_PASSWORD=your_actual_dev_password

MEAL_PLANNER_PORT=3001
MEAL_PLANNER_CORS_ORIGIN=http://localhost:3000
MEAL_PLANNER_LOG_LEVEL=info
```

**For Production (.env.prod)**:
Add these variables (use actual password from existing DB_PASSWORD):

```env
# --- Variables for meal-planner-api ---
MEAL_PLANNER_DB_HOST=database
MEAL_PLANNER_DB_PORT=5432
MEAL_PLANNER_DB_NAME=system_db
MEAL_PLANNER_DB_USER=app_user
MEAL_PLANNER_DB_PASSWORD=your_actual_prod_password

MEAL_PLANNER_PORT=3001
MEAL_PLANNER_CORS_ORIGIN=https://your-production-domain.com
MEAL_PLANNER_LOG_LEVEL=warn
```

### Task 3.7: Update Deployment Script
**Location**: `/home/qtym/system-management/scripts/`
**Action**: Ensure deploy.sh handles meal-planner-api service

Verify that `/home/qtym/system-management/scripts/deploy.sh` correctly handles the meal-planner-api service name. The current script should work as-is since it takes SERVICE_NAME as a parameter.

## Testing Tasks

### Task 3.8: Test Environment Configuration
**Action**: Verify environment variables and docker-compose changes

1. **Validate docker-compose syntax**:
   ```bash
   cd /home/qtym/system-management/dev
   docker compose config

   cd /home/qtym/system-management/prod
   docker compose config
   ```

2. **Test environment variable loading**:
   ```bash
   cd /home/qtym/system-management/dev
   source .env.dev
   echo "DB Host: $MEAL_PLANNER_DB_HOST"
   echo "API Port: $MEAL_PLANNER_PORT"
   ```

3. **Verify image references**:
   ```bash
   # Check that the image references are correct
   grep -n "meal-planner-api" /home/qtym/system-management/dev/docker-compose.yml
   grep -n "meal-planner-api" /home/qtym/system-management/prod/docker-compose.yml
   ```

4. **Test deployment workflow syntax**:
   ```bash
   # Use GitHub CLI to validate workflow
   cd /home/qtym/system-management
   gh workflow view deploy.yml
   ```

## Configuration Summary

### Environment Variables Added
- `MEAL_PLANNER_DB_HOST`: Database hostname (points to database service)
- `MEAL_PLANNER_DB_PORT`: Database port (5432)
- `MEAL_PLANNER_DB_NAME`: Database name (system_db - shared)
- `MEAL_PLANNER_DB_USER`: Database user (app_user - shared)
- `MEAL_PLANNER_DB_PASSWORD`: Database password (shared with main DB)
- `MEAL_PLANNER_PORT`: API service port (3001)
- `MEAL_PLANNER_CORS_ORIGIN`: CORS origin configuration
- `MEAL_PLANNER_LOG_LEVEL`: Logging level (info/warn)

### Docker Services Updated
- **Development**: Uses `ghcr.io/orangeqtym/meal-planner-api:dev`
- **Production**: Uses `ghcr.io/orangeqtym/meal-planner-api:latest`
- **Health checks**: Configured for proper service monitoring
- **Dependencies**: Service depends on database
- **Networking**: Connected to appropriate environment networks

### Deployment Integration
- GitHub Actions updated to handle meal-planner-api deployments
- Repository dispatch from meal-planner repo will trigger deployments
- Health check validation included in deployment process

## Success Criteria
- [ ] Environment templates updated with meal-planner variables
- [ ] Docker compose files updated with real meal-planner-api service
- [ ] Environment .env files contain meal-planner variables
- [ ] Deployment workflow includes meal-planner-api handling
- [ ] Docker compose config validation passes
- [ ] Environment variable loading works correctly

## Rollback Instructions
If this slice fails:

1. **Revert environment templates**:
   ```bash
   git checkout HEAD -- dev/.env.template prod/.env.template
   ```

2. **Revert docker-compose files**:
   ```bash
   git checkout HEAD -- dev/docker-compose.yml prod/docker-compose.yml
   ```

3. **Revert deployment workflow**:
   ```bash
   git checkout HEAD -- .github/workflows/deploy.yml
   ```

4. **Remove meal-planner variables from .env files**:
   - Manually remove meal-planner sections from .env.dev and .env.prod

## Next Slice
Once complete, proceed to **Slice 4: CI/CD Pipeline Integration** in `/home/qtym/meal-planner/MIGRATION_SLICE_04_CICD.md`