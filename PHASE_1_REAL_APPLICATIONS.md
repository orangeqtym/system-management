# Phase 1: Replace Placeholder Services with Real Applications

**Objective:** Replace nginx placeholder services with actual applications while maintaining the established infrastructure.

---

## Overview

After completing the 5 infrastructure slices, you now have a working foundation with:
- ✅ Database service (PostgreSQL)
- ✅ API service placeholder (nginx)
- ✅ Webapp service placeholder (nginx)
- ✅ Environment configuration
- ✅ CI/CD pipeline integration

**Phase 1 Goal:** Replace placeholders with functional applications.

---

## Step 1.1: Create API Service Application

**Objective:** Replace `api-service` nginx placeholder with a real backend application.

### Technology Decisions Needed:
- **Node.js** (Express, Fastify, NestJS)
- **Python** (Flask, FastAPI, Django)
- **Go** (Gin, Echo, Fiber)
- **Java** (Spring Boot)

### Implementation Tasks:
1. Create new repository: `system-api-service`
2. Set up basic HTTP server with health endpoint
3. Configure database connection using `DATABASE_URL`
4. Create Dockerfile for containerization
5. Set up CI/CD workflow (copy from email-service pattern)
6. Update docker-compose.yml to use new image instead of nginx

### Database Integration:
```bash
# Environment variables available to API service:
DATABASE_URL=postgres://app_user:${DB_PASSWORD}@database:5432/system_db
```

### Success Criteria:
- API responds to health checks
- Database connection established
- Service deploys via CI/CD pipeline
- Integrated with existing docker-compose network

---

## Step 1.2: Create Webapp Application

**Objective:** Replace `webapp` nginx placeholder with a real frontend application.

### Technology Decisions Needed:
- **React** (Vite, Next.js, Create React App)
- **Vue** (Vue 3, Nuxt.js)
- **Angular**
- **Svelte/SvelteKit**

### Implementation Tasks:
1. Create new repository: `system-webapp`
2. Set up basic frontend application
3. Configure API service connection (`http://api-service:6003`)
4. Create Dockerfile with nginx for serving static files
5. Set up CI/CD workflow
6. Update docker-compose.yml to use new image

### API Integration:
```javascript
// Frontend will connect to API service via Docker network
const API_BASE_URL = process.env.API_URL || 'http://localhost:6003'
```

### Success Criteria:
- Frontend serves correctly
- API communication established
- Responsive design
- Production-ready build process

---

## Step 1.3: Migrate Meal Planner Service

**Objective:** Move existing meal-planner application into the new infrastructure.

### Current State Analysis:
```yaml
# Existing meal-planner uses:
postgres:
  POSTGRES_DB: meal_planner
  POSTGRES_USER: meal_user
  POSTGRES_PASSWORD: meal_pass

api:
  DB_HOST: postgres
  DB_USER: meal_user
  DB_PASSWORD: meal_pass
  DB_NAME: meal_planner
```

### Migration Options:

**Option A: Separate Database (Recommended)**
- Keep `meal_planner` database separate
- Add `meal-planner-db` service to docker-compose
- Maintain service isolation

**Option B: Integrate into System Database**
- Migrate data to `system_db`
- Update connection strings
- Consolidate database management

### Implementation Tasks:
1. Decide on database strategy
2. Update meal-planner configuration for new infrastructure
3. Test meal-planner in new environment
4. Update CI/CD to deploy to system-management infrastructure
5. Migrate any existing data

### Success Criteria:
- Meal planner functionality preserved
- Integrated with new infrastructure
- No data loss during migration
- Performance maintained or improved

---

## Testing Strategy

### Local Development Testing:
```bash
# Test each service independently
docker compose up database -d
docker compose up api-service -d
docker compose up webapp -d

# Test full stack
docker compose up -d
curl http://localhost:6003/health
curl http://localhost:6004
```

### Integration Testing:
- API ↔ Database connectivity
- Webapp ↔ API communication
- Service discovery via Docker DNS
- Environment variable loading

---

## Rollback Plan

If issues arise during migration:
1. Revert to nginx placeholders
2. Keep existing meal-planner deployment running
3. Debug issues in development environment
4. Gradual migration approach (one service at a time)

---

## Next Phase

After completing Phase 1, proceed to `PHASE_2_SERVICE_INTEGRATION.md` for advanced service communication and features.