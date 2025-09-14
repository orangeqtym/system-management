# Slice 3: Add API Service Placeholder

## Objective
Add api-service to docker-compose files using temporary nginx image as placeholder.

## Files to Modify
- `dev/docker-compose.yml`
- `prod/docker-compose.yml`

## Changes Required

### Add api-service to services section:
```yaml
  api-service:
    image: nginx:alpine
    restart: always
    networks:
      - dev_network  # or prod_network for prod file
    ports:
      - "6003:80"  # dev uses 6003, prod can use different port
    depends_on:
      - database
```

**Note:** For prod file, use port "6103:80" instead of "6003:80"

## Testing Steps
1. Run: `cd /home/qtym/system-management/dev`
2. Run: `docker-compose up api-service -d`
3. Run: `curl http://localhost:6003`
4. Verify nginx welcome page is returned
5. Run: `docker-compose down`
6. Repeat for prod environment with port 6103

## Success Criteria
- Both docker-compose files have api-service added
- API service starts successfully on correct ports
- Service responds to HTTP requests
- depends_on: database is properly configured
- No docker-compose syntax errors