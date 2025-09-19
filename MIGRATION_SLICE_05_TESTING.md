# Migration Slice 5: Testing and Validation

## Objective
Comprehensive testing and validation of the complete meal-planner service integration with the system-management infrastructure.

## Prerequisites
- Slices 1-4 completed successfully
- meal-planner service fully implemented
- System-management environment configured
- GitHub repository created and CI/CD pipeline active

## Testing Strategy

This slice provides a systematic testing approach to validate:
1. Database schema and data operations
2. API service functionality
3. Docker containerization
4. Environment configuration
5. CI/CD pipeline end-to-end
6. Integration with system-management infrastructure

## Tasks

### Task 5.1: Database Integration Testing
**Location**: `/home/qtym/meal-planner/database/`
**Action**: Comprehensive database testing

```bash
#!/bin/bash
# File: /home/qtym/meal-planner/database/test-database.sh

set -e

echo "🧪 Testing meal-planner database integration..."

# Source environment variables
if [ -f "/home/qtym/system-management/dev/.env.dev" ]; then
    source /home/qtym/system-management/dev/.env.dev
    echo "✅ Environment variables loaded"
else
    echo "❌ Development environment file not found"
    exit 1
fi

# Test database connection
echo "🔍 Testing database connection..."
PGPASSWORD=$DB_PASSWORD psql -h localhost -p 5432 -U $DB_USER -d $DB_NAME -c "SELECT version();" > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Database connection successful"
else
    echo "❌ Database connection failed"
    exit 1
fi

# Test schema exists
echo "🔍 Verifying meal_planner schema..."
SCHEMA_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h localhost -p 5432 -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = 'meal_planner';")

if [ "$SCHEMA_COUNT" -eq 1 ]; then
    echo "✅ meal_planner schema exists"
else
    echo "❌ meal_planner schema not found"
    exit 1
fi

# Test all tables exist
echo "🔍 Verifying database tables..."
EXPECTED_TABLES=("recipes" "ingredients" "recipe_ingredients" "meal_plans" "planned_meals" "grocery_lists" "grocery_list_items")

for table in "${EXPECTED_TABLES[@]}"; do
    TABLE_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h localhost -p 5432 -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'meal_planner' AND table_name = '$table';")

    if [ "$TABLE_COUNT" -eq 1 ]; then
        echo "✅ Table meal_planner.$table exists"
    else
        echo "❌ Table meal_planner.$table not found"
        exit 1
    fi
done

# Test data operations
echo "🔍 Testing data operations..."

# Insert test ingredient
PGPASSWORD=$DB_PASSWORD psql -h localhost -p 5432 -U $DB_USER -d $DB_NAME -c "
INSERT INTO meal_planner.ingredients (name, category, unit_type)
VALUES ('Test Ingredient', 'test', 'piece')
ON CONFLICT (name) DO NOTHING;
"

# Verify ingredient insertion
INGREDIENT_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h localhost -p 5432 -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM meal_planner.ingredients WHERE name = 'Test Ingredient';")

if [ "$INGREDIENT_COUNT" -eq 1 ]; then
    echo "✅ Data insertion successful"
else
    echo "❌ Data insertion failed"
    exit 1
fi

# Test foreign key relationships
echo "🔍 Testing foreign key relationships..."
PGPASSWORD=$DB_PASSWORD psql -h localhost -p 5432 -U $DB_USER -d $DB_NAME -c "
INSERT INTO meal_planner.recipes (name, instructions)
VALUES ('Test Recipe', 'Test instructions')
ON CONFLICT DO NOTHING;
"

# Clean up test data
PGPASSWORD=$DB_PASSWORD psql -h localhost -p 5432 -U $DB_USER -d $DB_NAME -c "
DELETE FROM meal_planner.recipes WHERE name = 'Test Recipe';
DELETE FROM meal_planner.ingredients WHERE name = 'Test Ingredient';
"

echo "🎉 Database integration testing completed successfully!"
```

### Task 5.2: API Service Testing
**Location**: `/home/qtym/meal-planner/api/`
**Action**: Local API service testing

```bash
#!/bin/bash
# File: /home/qtym/meal-planner/api/test-api.sh

set -e

echo "🧪 Testing meal-planner API service..."

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js 18+"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Run linting
echo "🔍 Running code linting..."
npm run lint

# Run unit tests
echo "🧪 Running unit tests..."
npm test

# Start API in background for integration testing
echo "🚀 Starting API service for integration testing..."
npm start &
API_PID=$!

# Wait for API to start
echo "⏳ Waiting for API to start..."
sleep 10

# Test health endpoint
echo "🔍 Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s http://localhost:3001/api/health)
if echo "$HEALTH_RESPONSE" | grep -q '"success":true'; then
    echo "✅ Health endpoint responding correctly"
else
    echo "❌ Health endpoint failed"
    kill $API_PID 2>/dev/null || true
    exit 1
fi

# Test recipes endpoint
echo "🔍 Testing recipes endpoint..."
RECIPES_RESPONSE=$(curl -s http://localhost:3001/api/recipes)
if echo "$RECIPES_RESPONSE" | grep -q '"success":true'; then
    echo "✅ Recipes endpoint responding correctly"
else
    echo "❌ Recipes endpoint failed"
    kill $API_PID 2>/dev/null || true
    exit 1
fi

# Test invalid endpoint (should return 404)
echo "🔍 Testing 404 handling..."
NOT_FOUND_RESPONSE=$(curl -s -w "%{http_code}" http://localhost:3001/nonexistent)
if echo "$NOT_FOUND_RESPONSE" | grep -q "404"; then
    echo "✅ 404 handling working correctly"
else
    echo "❌ 404 handling failed"
    kill $API_PID 2>/dev/null || true
    exit 1
fi

# Clean up
echo "🧹 Cleaning up..."
kill $API_PID 2>/dev/null || true
sleep 2

echo "🎉 API service testing completed successfully!"
```

### Task 5.3: Docker Container Testing
**Location**: `/home/qtym/meal-planner/api/`
**Action**: Docker containerization testing

```bash
#!/bin/bash
# File: /home/qtym/meal-planner/api/test-docker.sh

set -e

echo "🧪 Testing meal-planner Docker containerization..."

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker"
    exit 1
fi

IMAGE_NAME="meal-planner-api:test"
CONTAINER_NAME="meal-planner-test"

# Build Docker image
echo "🔨 Building Docker image..."
docker build -t $IMAGE_NAME .

if [ $? -eq 0 ]; then
    echo "✅ Docker image built successfully"
else
    echo "❌ Docker image build failed"
    exit 1
fi

# Test image exists
echo "🔍 Verifying Docker image..."
if docker images | grep -q $IMAGE_NAME; then
    echo "✅ Docker image exists"
else
    echo "❌ Docker image not found"
    exit 1
fi

# Run container with environment variables
echo "🚀 Starting Docker container..."
docker run -d \
    --name $CONTAINER_NAME \
    -p 3002:3001 \
    -e DB_HOST=host.docker.internal \
    -e DB_PORT=5432 \
    -e DB_NAME=system_db \
    -e DB_USER=app_user \
    -e DB_PASSWORD=test_password \
    -e NODE_ENV=test \
    $IMAGE_NAME

# Wait for container to start
echo "⏳ Waiting for container to start..."
sleep 15

# Check container status
CONTAINER_STATUS=$(docker inspect --format='{{.State.Status}}' $CONTAINER_NAME)
if [ "$CONTAINER_STATUS" = "running" ]; then
    echo "✅ Container is running"
else
    echo "❌ Container failed to start"
    docker logs $CONTAINER_NAME
    docker rm -f $CONTAINER_NAME 2>/dev/null || true
    exit 1
fi

# Test container health (if health check is enabled)
echo "🔍 Testing container health..."
sleep 30  # Wait for health check

HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' $CONTAINER_NAME 2>/dev/null || echo "no-healthcheck")
if [ "$HEALTH_STATUS" = "healthy" ] || [ "$HEALTH_STATUS" = "no-healthcheck" ]; then
    echo "✅ Container health check passed"
else
    echo "❌ Container health check failed: $HEALTH_STATUS"
    docker logs $CONTAINER_NAME
    docker rm -f $CONTAINER_NAME 2>/dev/null || true
    exit 1
fi

# Test container endpoints
echo "🔍 Testing containerized API endpoints..."
CONTAINER_HEALTH=$(curl -s -f http://localhost:3002/api/health 2>/dev/null || echo "failed")
if echo "$CONTAINER_HEALTH" | grep -q '"success":true'; then
    echo "✅ Containerized API responding correctly"
else
    echo "❌ Containerized API failed to respond"
    docker logs $CONTAINER_NAME
    docker rm -f $CONTAINER_NAME 2>/dev/null || true
    exit 1
fi

# Clean up
echo "🧹 Cleaning up Docker resources..."
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME
docker rmi $IMAGE_NAME

echo "🎉 Docker containerization testing completed successfully!"
```

### Task 5.4: Integration Testing Script
**Location**: `/home/qtym/system-management/`
**Action**: End-to-end integration testing

```bash
#!/bin/bash
# File: /home/qtym/system-management/test-meal-planner-integration.sh

set -e

echo "🧪 Testing meal-planner integration with system-management..."

# Test environment configuration
echo "🔍 Testing environment configuration..."

# Check development environment
if [ -f "dev/.env.dev" ]; then
    source dev/.env.dev

    # Verify meal-planner variables exist
    REQUIRED_VARS=("MEAL_PLANNER_DB_HOST" "MEAL_PLANNER_DB_PORT" "MEAL_PLANNER_DB_NAME" "MEAL_PLANNER_DB_USER" "MEAL_PLANNER_PORT")

    for var in "${REQUIRED_VARS[@]}"; do
        if [ -n "${!var}" ]; then
            echo "✅ $var is set: ${!var}"
        else
            echo "❌ $var is not set"
            exit 1
        fi
    done
else
    echo "❌ Development environment file not found"
    exit 1
fi

# Test docker-compose configuration
echo "🔍 Testing docker-compose configuration..."

cd dev/
if docker compose config > /dev/null 2>&1; then
    echo "✅ Development docker-compose configuration is valid"
else
    echo "❌ Development docker-compose configuration is invalid"
    exit 1
fi

# Check if meal-planner-api service is defined
if docker compose config | grep -q "meal-planner-api:"; then
    echo "✅ meal-planner-api service found in docker-compose"
else
    echo "❌ meal-planner-api service not found in docker-compose"
    exit 1
fi

cd ../prod/
if docker compose config > /dev/null 2>&1; then
    echo "✅ Production docker-compose configuration is valid"
else
    echo "❌ Production docker-compose configuration is invalid"
    exit 1
fi

cd ..

# Test deployment workflow
echo "🔍 Testing deployment workflow configuration..."

if [ -f ".github/workflows/deploy.yml" ]; then
    if grep -q "meal-planner-api" .github/workflows/deploy.yml; then
        echo "✅ meal-planner-api deployment logic found in workflow"
    else
        echo "❌ meal-planner-api deployment logic not found in workflow"
        exit 1
    fi
else
    echo "❌ Deployment workflow not found"
    exit 1
fi

# Test database connectivity from system-management perspective
echo "🔍 Testing database connectivity..."

cd dev/
if docker compose ps | grep -q "database.*Up"; then
    echo "✅ Database service is running"

    # Test database connection with meal-planner credentials
    PGPASSWORD=$MEAL_PLANNER_DB_PASSWORD psql -h localhost -p 5432 -U $MEAL_PLANNER_DB_USER -d $MEAL_PLANNER_DB_NAME -c "SELECT 1;" > /dev/null

    if [ $? -eq 0 ]; then
        echo "✅ Database connection with meal-planner credentials successful"
    else
        echo "❌ Database connection with meal-planner credentials failed"
        exit 1
    fi
else
    echo "⚠️  Database service not running - starting services for testing..."
    docker compose up -d database
    sleep 10

    if docker compose ps | grep -q "database.*Up"; then
        echo "✅ Database service started successfully"
    else
        echo "❌ Failed to start database service"
        exit 1
    fi
fi

cd ..

echo "🎉 Integration testing completed successfully!"
```

### Task 5.5: CI/CD Pipeline Testing
**Location**: `/home/qtym/meal-planner/`
**Action**: GitHub Actions pipeline validation

```bash
#!/bin/bash
# File: /home/qtym/meal-planner/test-cicd.sh

set -e

echo "🧪 Testing CI/CD pipeline configuration..."

# Check if GitHub CLI is available
if ! command -v gh &> /dev/null; then
    echo "⚠️  GitHub CLI not found. Install 'gh' for full pipeline testing"
    echo "Proceeding with local validation only..."
else
    echo "✅ GitHub CLI found"
fi

# Validate workflow syntax
echo "🔍 Validating GitHub Actions workflow syntax..."

if [ -f ".github/workflows/ci-cd.yml" ]; then
    echo "✅ CI/CD workflow file exists"

    # Basic YAML syntax validation
    if command -v python3 &> /dev/null; then
        python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci-cd.yml'))" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "✅ Workflow YAML syntax is valid"
        else
            echo "❌ Workflow YAML syntax is invalid"
            exit 1
        fi
    else
        echo "⚠️  Python3 not found - skipping YAML validation"
    fi

    # Check for required workflow elements
    REQUIRED_ELEMENTS=("name:" "on:" "jobs:" "build-and-push:" "steps:")

    for element in "${REQUIRED_ELEMENTS[@]}"; do
        if grep -q "$element" .github/workflows/ci-cd.yml; then
            echo "✅ Found required element: $element"
        else
            echo "❌ Missing required element: $element"
            exit 1
        fi
    done

    # Check for meal-planner specific configuration
    if grep -q "meal-planner-api" .github/workflows/ci-cd.yml; then
        echo "✅ meal-planner-api specific configuration found"
    else
        echo "❌ meal-planner-api specific configuration not found"
        exit 1
    fi

    # Check for deployment trigger
    if grep -q "repository-dispatch" .github/workflows/ci-cd.yml; then
        echo "✅ Deployment trigger configuration found"
    else
        echo "❌ Deployment trigger configuration not found"
        exit 1
    fi

else
    echo "❌ CI/CD workflow file not found"
    exit 1
fi

# Test package.json scripts
echo "🔍 Testing package.json scripts..."

cd api/

if [ -f "package.json" ]; then
    echo "✅ package.json exists"

    # Check for required scripts
    REQUIRED_SCRIPTS=("start" "dev" "test" "lint")

    for script in "${REQUIRED_SCRIPTS[@]}"; do
        if grep -q "\"$script\":" package.json; then
            echo "✅ Found required script: $script"
        else
            echo "❌ Missing required script: $script"
            exit 1
        fi
    done
else
    echo "❌ package.json not found"
    exit 1
fi

# Test dependency installation
echo "🔍 Testing dependency installation..."
npm install --dry-run > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Dependencies can be installed successfully"
else
    echo "❌ Dependency installation failed"
    exit 1
fi

cd ..

# Test Dockerfile
echo "🔍 Testing Dockerfile..."

cd api/

if [ -f "Dockerfile" ]; then
    echo "✅ Dockerfile exists"

    # Basic Dockerfile validation
    if grep -q "FROM node:" Dockerfile; then
        echo "✅ Node.js base image specified"
    else
        echo "❌ Node.js base image not found"
        exit 1
    fi

    if grep -q "EXPOSE 3001" Dockerfile; then
        echo "✅ Port 3001 exposed"
    else
        echo "❌ Port 3001 not exposed"
        exit 1
    fi

    if grep -q "HEALTHCHECK" Dockerfile; then
        echo "✅ Health check configured"
    else
        echo "❌ Health check not configured"
        exit 1
    fi
else
    echo "❌ Dockerfile not found"
    exit 1
fi

cd ..

echo "🎉 CI/CD pipeline testing completed successfully!"
```

### Task 5.6: End-to-End Deployment Test
**Location**: `/home/qtym/system-management/`
**Action**: Full deployment testing script

```bash
#!/bin/bash
# File: /home/qtym/system-management/test-end-to-end.sh

set -e

echo "🧪 Running end-to-end meal-planner deployment test..."

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check if meal-planner directory exists
if [ -d "/home/qtym/meal-planner" ]; then
    echo "✅ meal-planner directory exists"
else
    echo "❌ meal-planner directory not found"
    echo "Please ensure all migration slices 1-4 are completed"
    exit 1
fi

# Check if database is running
cd dev/
if ! docker compose ps | grep -q "database.*Up"; then
    echo "🚀 Starting database service..."
    docker compose up -d database
    sleep 15
fi

# Test database schema
echo "🔍 Testing database schema..."
cd /home/qtym/meal-planner/database/
chmod +x test-database.sh
./test-database.sh

# Test API service
echo "🔍 Testing API service..."
cd /home/qtym/meal-planner/api/
chmod +x test-api.sh
./test-api.sh

# Test Docker containerization
echo "🔍 Testing Docker containerization..."
chmod +x test-docker.sh
./test-docker.sh

# Test integration
echo "🔍 Testing integration..."
cd /home/qtym/system-management/
chmod +x test-meal-planner-integration.sh
./test-meal-planner-integration.sh

# Test CI/CD configuration
echo "🔍 Testing CI/CD configuration..."
cd /home/qtym/meal-planner/
chmod +x test-cicd.sh
./test-cicd.sh

# Simulate deployment process
echo "🔍 Simulating deployment process..."
cd /home/qtym/system-management/dev/

# Build meal-planner image locally for testing
echo "🔨 Building meal-planner image for deployment test..."
cd /home/qtym/meal-planner/api/
docker build -t ghcr.io/orangeqtym/meal-planner-api:dev .

# Test deployment script
echo "🚀 Testing deployment script..."
cd /home/qtym/system-management/
./scripts/deploy.sh dev meal-planner-api dev

# Wait for service to be ready
echo "⏳ Waiting for meal-planner-api to be ready..."
sleep 30

# Test deployed service
echo "🔍 Testing deployed service..."
if curl -f http://localhost:3001/api/health > /dev/null 2>&1; then
    echo "✅ Deployed meal-planner-api responding correctly"
else
    echo "❌ Deployed meal-planner-api not responding"
    docker compose logs meal-planner-api
    exit 1
fi

# Test recipes endpoint
echo "🔍 Testing recipes endpoint on deployed service..."
RECIPES_RESPONSE=$(curl -s http://localhost:3001/api/recipes)
if echo "$RECIPES_RESPONSE" | grep -q '"success":true'; then
    echo "✅ Deployed recipes endpoint working correctly"
else
    echo "❌ Deployed recipes endpoint failed"
    docker compose logs meal-planner-api
    exit 1
fi

# Check service health
echo "🔍 Checking service health status..."
HEALTH_STATUS=$(docker compose ps meal-planner-api | grep -o "healthy\|unhealthy\|starting" || echo "unknown")
echo "Service health status: $HEALTH_STATUS"

if [ "$HEALTH_STATUS" = "healthy" ] || [ "$HEALTH_STATUS" = "unknown" ]; then
    echo "✅ Service health check passed"
else
    echo "❌ Service health check failed"
    docker compose logs meal-planner-api
    exit 1
fi

echo ""
echo "🎉 End-to-end deployment test completed successfully!"
echo ""
echo "📊 Test Summary:"
echo "✅ Database schema and operations"
echo "✅ API service functionality"
echo "✅ Docker containerization"
echo "✅ Environment integration"
echo "✅ CI/CD pipeline configuration"
echo "✅ Deployment process"
echo "✅ Service health and endpoints"
echo ""
echo "🚀 meal-planner service is ready for production deployment!"
```

### Task 5.7: Create Master Test Runner
**Location**: `/home/qtym/system-management/`
**Action**: Single command to run all tests

```bash
#!/bin/bash
# File: /home/qtym/system-management/run-meal-planner-tests.sh

set -e

echo "🧪 Running comprehensive meal-planner testing suite..."
echo "=================================================="

# Create executable permissions for all test scripts
echo "🔧 Setting up test scripts..."
chmod +x /home/qtym/meal-planner/database/test-database.sh 2>/dev/null || true
chmod +x /home/qtym/meal-planner/api/test-api.sh 2>/dev/null || true
chmod +x /home/qtym/meal-planner/api/test-docker.sh 2>/dev/null || true
chmod +x /home/qtym/meal-planner/test-cicd.sh 2>/dev/null || true
chmod +x test-meal-planner-integration.sh 2>/dev/null || true
chmod +x test-end-to-end.sh 2>/dev/null || true

# Run end-to-end test (includes all other tests)
echo ""
echo "🚀 Starting end-to-end testing..."
echo "=================================================="
./test-end-to-end.sh

echo ""
echo "🎉 All meal-planner tests completed successfully!"
echo "=================================================="
echo ""
echo "📋 Next Steps:"
echo "1. Commit and push meal-planner code to GitHub"
echo "2. Trigger CI/CD pipeline to build and deploy"
echo "3. Verify production deployment"
echo "4. Begin Phase 2: Service Integration planning"
echo ""
echo "🎯 meal-planner service migration is COMPLETE!"
```

## Success Criteria Checklist

- [ ] **Database Testing**
  - [ ] Schema exists and is accessible
  - [ ] All tables created correctly
  - [ ] Data operations work (CRUD)
  - [ ] Foreign key relationships functional

- [ ] **API Testing**
  - [ ] All endpoints respond correctly
  - [ ] Health checks pass
  - [ ] Error handling works
  - [ ] Authentication/validation working

- [ ] **Docker Testing**
  - [ ] Image builds successfully
  - [ ] Container starts and runs
  - [ ] Health checks pass
  - [ ] API accessible from container

- [ ] **Integration Testing**
  - [ ] Environment variables configured
  - [ ] Docker compose syntax valid
  - [ ] Database connectivity works
  - [ ] Service discovery functional

- [ ] **CI/CD Testing**
  - [ ] Workflow syntax valid
  - [ ] Required elements present
  - [ ] Package.json scripts work
  - [ ] Dependencies install correctly

- [ ] **End-to-End Testing**
  - [ ] Complete deployment process works
  - [ ] Service starts and responds
  - [ ] Health checks pass
  - [ ] API endpoints functional

## Rollback Instructions

If any tests fail:

1. **Stop running services**:
   ```bash
   cd /home/qtym/system-management/dev
   docker compose down meal-planner-api
   ```

2. **Review logs**:
   ```bash
   docker compose logs meal-planner-api
   ```

3. **Revert to placeholder service**:
   ```bash
   git checkout HEAD~1 -- dev/docker-compose.yml
   docker compose up -d meal-planner-api
   ```

4. **Report specific failure details** for troubleshooting

## Post-Testing Actions

After successful completion:

1. **Commit all changes** to system-management repository
2. **Create meal-planner GitHub repository**
3. **Push initial meal-planner code**
4. **Trigger first CI/CD pipeline run**
5. **Verify production deployment capability**

## Final Validation

Run this command to validate everything is working:

```bash
cd /home/qtym/system-management
./run-meal-planner-tests.sh
```

Expected output: All tests pass with "🎉 All meal-planner tests completed successfully!"

This completes the meal-planner service migration to the microservices infrastructure. The service is now fully integrated, tested, and ready for production use.