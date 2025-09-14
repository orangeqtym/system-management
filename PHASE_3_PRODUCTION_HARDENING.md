# Phase 3: Production Hardening and Security

**Objective:** Secure, monitor, and optimize the system for production deployment.

---

## Prerequisites
- Phase 2 completed (services integrated and communicating)
- Authentication system functional
- All services responding to health checks

---

## Step 3.1: Security Hardening

**Objective:** Implement production-grade security measures.

### Password and Secrets Management:
```bash
# Replace all placeholder passwords
# In .env.prod:
DB_PASSWORD=$(openssl rand -base64 32)
JWT_SECRET=$(openssl rand -base64 64)
EMAIL_APP_PASSWORD=your-actual-gmail-app-password

# Use Docker secrets for production
POSTGRES_PASSWORD_FILE=/run/secrets/db_password
JWT_SECRET_FILE=/run/secrets/jwt_secret
```

### Docker Secrets Implementation:
```yaml
# Production docker-compose.yml additions
services:
  database:
    secrets:
      - db_password
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt
```

### Implementation Tasks:
1. Generate cryptographically secure passwords
2. Implement Docker secrets for sensitive data
3. Remove any hardcoded credentials
4. Set up secret rotation procedures
5. Audit all environment variables

---

## Step 3.2: HTTPS and SSL/TLS Configuration

**Objective:** Encrypt all communication channels.

### Reverse Proxy Setup:
```yaml
# Add nginx reverse proxy
nginx:
  image: nginx:alpine
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - ./nginx/conf.d:/etc/nginx/conf.d
    - ./ssl:/etc/nginx/ssl
  depends_on:
    - api-service
    - webapp
```

### Nginx Configuration:
```nginx
# /nginx/conf.d/default.conf
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    # API service proxy
    location /api/ {
        proxy_pass http://api-service:6003/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Webapp proxy
    location / {
        proxy_pass http://webapp:6004/;
        proxy_set_header Host $host;
    }
}
```

### Implementation Tasks:
1. Obtain SSL certificates (Let's Encrypt recommended)
2. Configure nginx reverse proxy
3. Implement HTTP to HTTPS redirects
4. Set up certificate auto-renewal
5. Test SSL configuration with SSL Labs

---

## Step 3.3: Database Security and Backup

**Objective:** Secure database access and implement backup strategies.

### Database Security:
```yaml
database:
  image: postgres:15
  environment:
    POSTGRES_DB: system_db
    POSTGRES_USER: app_user
    POSTGRES_PASSWORD_FILE: /run/secrets/db_password
  volumes:
    - db_data:/var/lib/postgresql/data
    - ./postgresql.conf:/etc/postgresql/postgresql.conf
  command: postgres -c config_file=/etc/postgresql/postgresql.conf
```

### PostgreSQL Security Configuration:
```bash
# postgresql.conf security settings
ssl = on
ssl_cert_file = '/etc/ssl/certs/server.crt'
ssl_key_file = '/etc/ssl/private/server.key'
log_connections = on
log_disconnections = on
log_statement = 'mod'
shared_preload_libraries = 'pg_stat_statements'
```

### Backup Strategy:
```bash
#!/bin/bash
# backup.sh
BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DB_NAME="system_db"

# Create backup
docker exec -t postgres-container pg_dump -U app_user $DB_NAME > \
  "$BACKUP_DIR/backup_${DB_NAME}_${TIMESTAMP}.sql"

# Compress and upload to cloud storage
gzip "$BACKUP_DIR/backup_${DB_NAME}_${TIMESTAMP}.sql"
aws s3 cp "$BACKUP_DIR/backup_${DB_NAME}_${TIMESTAMP}.sql.gz" \
  s3://your-backup-bucket/database/

# Cleanup old backups (keep 30 days)
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +30 -delete
```

### Implementation Tasks:
1. Configure database SSL connections
2. Set up automated daily backups
3. Test backup restoration procedures
4. Implement database access logging
5. Configure connection limits and timeouts

---

## Step 3.4: Logging and Monitoring

**Objective:** Implement comprehensive logging and monitoring.

### Centralized Logging Stack:
```yaml
# Add to docker-compose.yml
elasticsearch:
  image: docker.elastic.co/elasticsearch/elasticsearch:8.8.0
  environment:
    - discovery.type=single-node
    - xpack.security.enabled=false
  volumes:
    - es_data:/usr/share/elasticsearch/data

kibana:
  image: docker.elastic.co/kibana/kibana:8.8.0
  ports:
    - "5601:5601"
  depends_on:
    - elasticsearch

filebeat:
  image: docker.elastic.co/beats/filebeat:8.8.0
  volumes:
    - ./filebeat.yml:/usr/share/filebeat/filebeat.yml
    - /var/lib/docker/containers:/var/lib/docker/containers:ro
    - /var/run/docker.sock:/var/run/docker.sock:ro
  depends_on:
    - elasticsearch
```

### Application Logging Standards:
```javascript
// Structured logging in all services
const logger = require('winston');

logger.configure({
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({
      filename: '/var/log/app/error.log',
      level: 'error'
    }),
    new winston.transports.File({
      filename: '/var/log/app/combined.log'
    })
  ]
});

// Usage throughout application
logger.info('User login attempt', {
  userId: user.id,
  email: user.email,
  ip: req.ip,
  userAgent: req.get('User-Agent'),
  timestamp: new Date().toISOString()
});
```

### Monitoring and Alerting:
```yaml
# Prometheus and Grafana
prometheus:
  image: prom/prometheus
  ports:
    - "9090:9090"
  volumes:
    - ./prometheus.yml:/etc/prometheus/prometheus.yml

grafana:
  image: grafana/grafana
  ports:
    - "3001:3000"
  environment:
    - GF_SECURITY_ADMIN_PASSWORD=secure_password
  volumes:
    - grafana_data:/var/lib/grafana
```

### Implementation Tasks:
1. Set up ELK stack for log aggregation
2. Configure application metrics collection
3. Create monitoring dashboards
4. Set up alerting rules for critical issues
5. Implement uptime monitoring

---

## Step 3.5: Performance Optimization

**Objective:** Optimize system performance for production load.

### Database Optimization:
```sql
-- Add database indexes for common queries
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_sessions_token ON user_sessions(token);
CREATE INDEX idx_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_email_logs_user_id ON email_logs(user_id);
CREATE INDEX idx_email_logs_sent_at ON email_logs(sent_at);

-- Configure connection pooling
-- In application config:
{
  "database": {
    "pool": {
      "min": 2,
      "max": 10,
      "acquireTimeoutMillis": 60000,
      "idleTimeoutMillis": 600000
    }
  }
}
```

### Application Caching:
```yaml
# Redis for caching
redis:
  image: redis:7-alpine
  restart: always
  networks:
    - prod_network
  volumes:
    - redis_data:/data
  command: redis-server --appendonly yes
```

### Performance Monitoring:
```javascript
// API response time monitoring
app.use((req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;
    logger.info('API Request', {
      method: req.method,
      url: req.url,
      status: res.statusCode,
      duration: duration,
      userAgent: req.get('User-Agent')
    });
  });

  next();
});
```

### Implementation Tasks:
1. Add database indexes for performance
2. Implement Redis caching layer
3. Set up application performance monitoring
4. Configure connection pooling
5. Optimize Docker images for size and startup time

---

## Step 3.6: Deployment Automation

**Objective:** Automate production deployments with safety measures.

### Blue-Green Deployment:
```yaml
# docker-compose.blue.yml
services:
  api-service-blue:
    image: ghcr.io/orangeqtym/api-service:${VERSION}
    networks:
      - prod_network
    deploy:
      replicas: 2

# docker-compose.green.yml
services:
  api-service-green:
    image: ghcr.io/orangeqtym/api-service:${VERSION}
    networks:
      - prod_network
    deploy:
      replicas: 2
```

### Deployment Script:
```bash
#!/bin/bash
# deploy.sh
set -e

VERSION=$1
ENVIRONMENT=$2

if [ -z "$VERSION" ] || [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <version> <environment>"
    exit 1
fi

echo "Deploying version $VERSION to $ENVIRONMENT"

# Health check function
health_check() {
    local service=$1
    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if curl -f "http://localhost:6003/health" > /dev/null 2>&1; then
            echo "Service $service is healthy"
            return 0
        fi
        echo "Attempt $attempt/$max_attempts: Service not ready, waiting..."
        sleep 10
        ((attempt++))
    done

    echo "Service $service failed health check"
    return 1
}

# Deploy new version
docker compose -f docker-compose.$ENVIRONMENT.yml pull
docker compose -f docker-compose.$ENVIRONMENT.yml up -d

# Wait for services to be healthy
health_check "api-service"

# Run database migrations if needed
docker compose exec api-service npm run migrate

echo "Deployment completed successfully"
```

### Implementation Tasks:
1. Set up blue-green deployment process
2. Create automated health checks
3. Implement rollback procedures
4. Set up database migration automation
5. Configure deployment notifications

---

## Step 3.7: Disaster Recovery

**Objective:** Prepare for system failures and data recovery.

### Backup Verification:
```bash
#!/bin/bash
# verify_backup.sh
BACKUP_FILE=$1
TEST_DB="test_restore_$(date +%s)"

# Create test database
docker exec postgres-container psql -U app_user -c "CREATE DATABASE $TEST_DB;"

# Restore backup
docker exec -i postgres-container psql -U app_user -d $TEST_DB < $BACKUP_FILE

# Verify data integrity
RECORD_COUNT=$(docker exec postgres-container psql -U app_user -d $TEST_DB -t -c "SELECT COUNT(*) FROM users;")

if [ "$RECORD_COUNT" -gt 0 ]; then
    echo "Backup verification successful: $RECORD_COUNT records found"
else
    echo "Backup verification failed: No records found"
    exit 1
fi

# Cleanup
docker exec postgres-container psql -U app_user -c "DROP DATABASE $TEST_DB;"
```

### Implementation Tasks:
1. Document recovery procedures
2. Test backup restoration regularly
3. Set up off-site backup storage
4. Create incident response playbook
5. Implement automated failover for critical services

---

## Security Checklist

### Application Security:
- [ ] All passwords are cryptographically secure
- [ ] Docker secrets implemented for sensitive data
- [ ] HTTPS enforced on all endpoints
- [ ] SQL injection prevention in place
- [ ] Input validation on all API endpoints
- [ ] Rate limiting configured
- [ ] CORS properly configured
- [ ] Security headers implemented

### Infrastructure Security:
- [ ] Database access restricted to application services
- [ ] Firewall rules configured
- [ ] Regular security updates scheduled
- [ ] Access logs monitored
- [ ] Intrusion detection configured

---

## Production Readiness Checklist

### Monitoring:
- [ ] Application metrics collected
- [ ] Error alerting configured
- [ ] Performance monitoring in place
- [ ] Log aggregation working
- [ ] Health checks implemented

### Reliability:
- [ ] Automated backups running
- [ ] Backup restoration tested
- [ ] Disaster recovery plan documented
- [ ] High availability configured
- [ ] Load testing completed

### Deployment:
- [ ] CI/CD pipeline functional
- [ ] Blue-green deployment working
- [ ] Rollback procedures tested
- [ ] Database migrations automated
- [ ] Configuration management in place

---

## Maintenance Procedures

### Daily Tasks:
- Monitor system health dashboards
- Review error logs and alerts
- Verify backup completion

### Weekly Tasks:
- Review security logs
- Update dependencies
- Performance analysis

### Monthly Tasks:
- Security vulnerability scanning
- Disaster recovery testing
- Capacity planning review

---

## Next Steps

After completing Phase 3, your system is production-ready! Consider:

1. **Additional Services**: Add Hubitat integration, monitoring services
2. **Advanced Features**: Real-time notifications, advanced analytics
3. **Scaling**: Load balancing, microservices architecture
4. **Compliance**: GDPR, SOC2, or other regulatory requirements

Excellent work using the thin-slice approach! The systematic progression from infrastructure → integration → hardening has created a robust, maintainable system.