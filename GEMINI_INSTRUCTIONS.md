# Instructions for Gemini: Database/API/Webapp Implementation

## Overview
You will implement 5 thin slices to add database, API, and webapp services to the system-management infrastructure. Complete each slice in order and verify testing before proceeding to the next.

## Processing Order
1. **SLICE_01_DATABASE.md** - Add PostgreSQL database service
2. **SLICE_02_ENV_TEMPLATES.md** - Update environment templates
3. **SLICE_03_API_SERVICE.md** - Add API service placeholder
4. **SLICE_04_WEBAPP_SERVICE.md** - Add webapp service placeholder
5. **SLICE_05_CI_CD_PIPELINE.md** - Update deployment pipeline

## General Instructions
- Read each slice file completely before making changes
- Follow the exact YAML formatting and indentation shown
- Test each slice after implementation using provided testing steps
- Do not proceed to next slice until current slice tests pass
- Ask for clarification if any instruction is unclear

## File Locations
- Working directory: `/home/qtym/system-management`
- All slice instruction files are in the root directory
- Docker compose files are in `dev/` and `prod/` subdirectories
- Environment templates are in `dev/` and `prod/` subdirectories

## Success Criteria for Completion
- All 5 slices implemented successfully
- All testing steps pass for each slice
- Docker services start without errors
- HTTP endpoints respond correctly where applicable
- No syntax errors in any modified files

## Notes
- These are placeholder implementations using nginx
- Real API and webapp implementations will be added later
- Database service is production-ready PostgreSQL
- Maintain existing service functionality throughout