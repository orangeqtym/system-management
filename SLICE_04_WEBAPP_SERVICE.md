# Slice 4: Add Webapp Service

## Objective
Add webapp service to docker-compose files using nginx as placeholder.

## Files to Modify
- `dev/docker-compose.yml`
- `prod/docker-compose.yml`

## Changes Required

### Add webapp service to services section:
```yaml
  webapp:
    image: nginx:alpine
    restart: always
    networks:
      - dev_network  # or prod_network for prod file
    ports:
      - "6004:80"  # dev uses 6004, prod uses different port
```

**Note:** For prod file, use port "6104:80" instead of "6004:80"

## Testing Steps
1. Run: `cd /home/qtym/system-management/dev`
2. Run: `docker-compose up webapp -d`
3. Run: `curl http://localhost:6004`
4. Verify nginx welcome page is returned
5. Run: `docker-compose down`
6. Repeat for prod environment with port 6104

## Success Criteria
- Both docker-compose files have webapp service added
- Webapp service starts successfully on correct ports
- Service responds to HTTP requests on configured ports
- No docker-compose syntax errors
- Service integrates properly with existing network