# Slice 2: Update Environment Templates

## Objective
Add database connection variables to environment templates.

## Files to Modify
- `dev/.env.template`
- `prod/.env.template`

## Changes Required

### Add these lines to both template files (after existing EMAIL variables):
```bash
# Database configuration
DB_PASSWORD=your-secure-database-password
DATABASE_URL=postgres://app_user:${DB_PASSWORD}@database:5432/system_db
```

## Testing Steps
1. Open `dev/.env.template`
2. Verify new database variables are present
3. Open `prod/.env.template`
4. Verify new database variables are present
5. Check that variable format matches existing EMAIL variables

## Success Criteria
- Both .env.template files contain new DB_PASSWORD variable
- Both .env.template files contain new DATABASE_URL variable
- Variables follow same format/style as existing variables
- No syntax errors or typos in variable names