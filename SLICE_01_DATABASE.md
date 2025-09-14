# Slice 1: Add Database Service

## Objective
Add PostgreSQL database service to both dev and prod docker-compose files.

## Files to Modify
- `dev/docker-compose.yml`
- `prod/docker-compose.yml`

## Changes Required

### 1. Add database service to services section
```yaml
  database:
    image: postgres:15
    restart: always
    networks:
      - dev_network  # or prod_network for prod file
    env_file:
      - .env.dev  # or .env.prod for prod file
    environment:
      POSTGRES_DB: system_db
      POSTGRES_USER: app_user
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - db_data:/var/lib/postgresql/data
```

### 2. Add volumes section at the end of file
```yaml
volumes:
  db_data:
```

## Testing Steps
**Note: Full testing requires Slice 2 to be completed first (DB_PASSWORD needed)**

1. Run: `cd /home/qtym/system-management/dev`
2. Run: `docker compose config database` (verify YAML syntax)
3. For complete test (after Slice 2):
   - Run: `docker compose up database -d`
   - Run: `docker compose logs database`
   - Verify output contains: "database system is ready to accept connections"
   - Run: `docker compose down`

## Success Criteria
- Both docker-compose files have database service added
- `docker compose config` passes without errors
- Database service includes env_file directive
- No YAML syntax errors
- (After Slice 2) Database starts and shows ready message