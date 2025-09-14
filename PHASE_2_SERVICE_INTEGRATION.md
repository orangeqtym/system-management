# Phase 2: Service Integration and Communication

**Objective:** Implement proper service-to-service communication, authentication, and shared functionality.

---

## Prerequisites
- Phase 1 completed (real API and webapp services deployed)
- All services responding to health checks
- Database connectivity established

---

## Step 2.1: API Service Database Schema

**Objective:** Design and implement database schema for cross-service functionality.

### Schema Design Decisions:
```sql
-- Core system tables
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL
);

-- Service-specific tables
CREATE TABLE email_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    recipient VARCHAR(255),
    subject VARCHAR(255),
    sent_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE system_settings (
    id SERIAL PRIMARY KEY,
    key VARCHAR(255) UNIQUE NOT NULL,
    value TEXT,
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### Implementation Tasks:
1. Create database migration system
2. Implement core API endpoints:
   - `POST /auth/login`
   - `POST /auth/logout`
   - `GET /users/profile`
   - `GET /system/health`
3. Add database connection pooling
4. Implement proper error handling and logging

---

## Step 2.2: Authentication System

**Objective:** Implement centralized authentication for all services.

### Authentication Flow:
```
1. User logs in via webapp
2. API service validates credentials
3. JWT token issued and stored
4. Webapp stores token for API requests
5. All services validate tokens via API service
```

### Implementation Tasks:
1. JWT token generation and validation
2. Middleware for protected routes
3. Token refresh mechanism
4. Logout and session management

### API Endpoints:
```javascript
// Authentication endpoints
POST /auth/login     // Login with email/password
POST /auth/logout    // Invalidate token
POST /auth/refresh   // Refresh JWT token
GET  /auth/verify    // Validate token (for other services)
```

---

## Step 2.3: Service-to-Service Communication

**Objective:** Enable secure communication between services.

### Communication Patterns:

**HTTP API Calls:**
```javascript
// From webapp to api-service
const response = await fetch('http://api-service:6003/api/users/profile', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});

// From api-service to email-service
const emailResponse = await fetch('http://email-service:3000/send', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    to: user.email,
    subject: 'Welcome!',
    body: 'Welcome to the system!'
  })
});
```

**Message Queue (Optional):**
```yaml
# Add Redis or RabbitMQ for async communication
redis:
  image: redis:7-alpine
  restart: always
  networks:
    - dev_network
```

### Implementation Tasks:
1. Create service discovery mechanism
2. Implement retry logic and circuit breakers
3. Add request/response logging
4. Error handling for service failures

---

## Step 2.4: Webapp Integration

**Objective:** Connect frontend to API service with proper state management.

### Frontend Architecture:
```javascript
// API client setup
class ApiClient {
  constructor(baseURL = 'http://localhost:6003') {
    this.baseURL = baseURL;
    this.token = localStorage.getItem('authToken');
  }

  async request(endpoint, options = {}) {
    const url = `${this.baseURL}${endpoint}`;
    const config = {
      headers: {
        'Content-Type': 'application/json',
        ...(this.token && { 'Authorization': `Bearer ${this.token}` })
      },
      ...options
    };

    const response = await fetch(url, config);

    if (!response.ok) {
      throw new Error(`API Error: ${response.status}`);
    }

    return response.json();
  }
}
```

### Implementation Tasks:
1. Set up API client with authentication
2. Implement global state management (Redux, Vuex, Zustand)
3. Create reusable UI components
4. Add form validation and error handling
5. Implement responsive design

---

## Step 2.5: Email Service Integration

**Objective:** Integrate email service with user management and notifications.

### Integration Points:
- Welcome emails for new users
- Password reset emails
- System notifications
- Activity digest emails

### Implementation Tasks:
1. Update email-service to accept API calls
2. Create email templates
3. Add email queue for reliability
4. Implement email preferences per user

### API Integration:
```javascript
// Email service endpoints
POST /send           // Send individual email
POST /send/bulk      // Send bulk emails
GET  /templates      // List email templates
POST /templates      // Create email template
```

---

## Step 2.6: Hubitat Integration Preparation

**Objective:** Prepare infrastructure for home automation integration.

### Hubitat Service Design:
```yaml
hubitat-service:
  image: ghcr.io/orangeqtym/hubitat-service:dev
  restart: always
  networks:
    - dev_network
  env_file:
    - .env.dev
  environment:
    HUBITAT_HUB_IP: ${HUBITAT_HUB_IP}
    HUBITAT_ACCESS_TOKEN: ${HUBITAT_ACCESS_TOKEN}
    API_SERVICE_URL: http://api-service:6003
  depends_on:
    - api-service
```

### Environment Variables:
```bash
# Add to .env templates
HUBITAT_HUB_IP=192.168.1.xxx
HUBITAT_ACCESS_TOKEN=your-maker-api-token
HUBITAT_APP_ID=your-maker-api-app-id
```

### Integration Tasks:
1. Design device data schema
2. Plan real-time event handling
3. Create device control API endpoints
4. Design automation rules system

---

## Testing Strategy

### Integration Testing:
```bash
# Test service communication
docker compose up -d
curl -X POST http://localhost:6003/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'

# Test email integration
curl -X POST http://localhost:6003/api/emails/send \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"to":"user@example.com","subject":"Test","body":"Hello!"}'
```

### Load Testing:
- API endpoint performance
- Database connection pooling
- Concurrent user sessions
- Service-to-service latency

---

## Security Considerations

### API Security:
- Input validation and sanitization
- Rate limiting on API endpoints
- SQL injection prevention
- CORS configuration

### Authentication Security:
- JWT token expiration
- Secure password hashing (bcrypt)
- HTTPS enforcement in production
- Session management

---

## Monitoring and Logging

### Application Logging:
```javascript
// Structured logging example
logger.info('User authentication', {
  userId: user.id,
  email: user.email,
  timestamp: new Date().toISOString(),
  service: 'api-service'
});
```

### Health Checks:
```javascript
// Enhanced health check
app.get('/health', async (req, res) => {
  const checks = {
    database: await checkDatabaseConnection(),
    emailService: await checkEmailService(),
    timestamp: new Date().toISOString()
  };

  const healthy = Object.values(checks).every(check =>
    check === true || check.status === 'healthy'
  );

  res.status(healthy ? 200 : 503).json(checks);
});
```

---

## Next Phase

After completing Phase 2, proceed to `PHASE_3_PRODUCTION_HARDENING.md` for security, monitoring, and deployment optimization.