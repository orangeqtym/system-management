# Meal Planner Migration - Master Instructions

## Overview
This document coordinates the migration of the meal-planner service into the new microservices infrastructure. The migration preserves all existing data (476 recipes, 4 shopping lists, user preferences) and is split into 5 thin slices for systematic implementation.

## Execution Strategy
1. **One slice at a time** - Complete each slice fully before moving to the next
2. **Test after each slice** - Verify functionality before proceeding
3. **Rollback capability** - Each slice can be independently rolled back
4. **Location-specific instructions** - Each slice has instructions placed in the relevant directory

## Slice Execution Order

### Slice 1: Database Data Export and Schema Migration
**Location**: `/home/qtym/meal-planner/MIGRATION_SLICE_01_DATABASE.md`
**Objective**: Export existing data (476 recipes, shopping lists) and migrate to new PostgreSQL schema
**Dependencies**: Infrastructure database service (already deployed) + existing meal-planner database running
**Estimated Time**: 45 minutes

### Slice 2: API Service Migration
**Location**: `/home/qtym/meal-planner/MIGRATION_SLICE_02_API.md`
**Objective**: Migrate API to support existing data structure (recipes, shopping lists, ingredients)
**Dependencies**: Slice 1 complete (data exported and imported)
**Estimated Time**: 45 minutes

### Slice 3: Environment Configuration
**Location**: `/home/qtym/system-management/MIGRATION_SLICE_03_ENV.md`
**Objective**: Update environment templates and docker-compose files
**Dependencies**: Slice 2 complete
**Estimated Time**: 20 minutes

### Slice 4: CI/CD Pipeline Integration
**Location**: `/home/qtym/meal-planner/MIGRATION_SLICE_04_CICD.md`
**Objective**: Set up GitHub Actions for meal-planner deployment
**Dependencies**: Slice 3 complete
**Estimated Time**: 30 minutes

### Slice 5: Testing and Validation
**Location**: `/home/qtym/system-management/MIGRATION_SLICE_05_TESTING.md`
**Objective**: Comprehensive testing of entire meal-planner stack
**Dependencies**: Slices 1-4 complete
**Estimated Time**: 45 minutes

## Success Criteria
- [ ] Existing data exported successfully (476 recipes, 4 shopping lists)
- [ ] Enhanced database schema deployed with migrated data
- [ ] API service responding to health checks with existing data accessible
- [ ] Environment variables properly configured
- [ ] CI/CD pipeline successfully deploying
- [ ] End-to-end functionality tested with all 476 recipes
- [ ] Production deployment capability verified

## Rollback Plan
Each slice includes specific rollback instructions. If issues arise:
1. Stop at current slice
2. Execute rollback steps from slice instructions
3. Investigate and fix issues
4. Resume from failed slice

## Communication
- **Start each slice**: Report slice number and objectives
- **Complete each slice**: Confirm completion and test results
- **Issues encountered**: Report immediately with error details
- **Final completion**: Provide full test results and deployment status

## Notes
- The meal-planner repository location is assumed to be `/home/qtym/meal-planner`
- **Existing data preservation**: 476 recipes and 4 shopping lists (Kimbie's, Trader Joe's, Wegman's, Aldi) will be migrated
- All database operations use the existing PostgreSQL service in system-management
- The API will integrate with the existing service discovery patterns
- Environment variables follow the established naming conventions
- **No data loss**: Original meal-planner database remains untouched during migration

## Ready to Begin
Once this master plan is confirmed, execute slices in order. Each slice contains detailed, actionable instructions for Gemini to follow.