# Slice 5: Update CI/CD Pipeline

## Objective
Update deployment workflow to handle database, api-service, and webapp services.

## Files to Modify
- `.github/workflows/deploy.yml`

## Changes Required

### 1. Find the section that handles service deployment (around line with `docker-compose up`)

### 2. The current deployment logic should be updated to include new services
Look for patterns like:
```bash
docker-compose up email-service -d
docker-compose up meal-planner-api -d
```

### 3. Add these services to the deployment:
```bash
docker-compose up database -d
docker-compose up api-service -d
docker-compose up webapp -d
```

**Note:** Database should be started first, then api-service, then webapp

## Testing Steps
1. Run: `cd /home/qtym/system-management`
2. Run: `gh workflow view deploy.yml` (if gh CLI available)
3. Check workflow syntax by examining the file
4. Look for proper YAML indentation and structure
5. Verify new services are added in logical order

## Success Criteria
- deploy.yml includes database service deployment
- deploy.yml includes api-service deployment
- deploy.yml includes webapp service deployment
- Services are deployed in correct dependency order
- No YAML syntax errors
- Existing service deployments remain unchanged