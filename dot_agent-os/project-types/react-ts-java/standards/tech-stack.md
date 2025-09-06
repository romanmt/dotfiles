# Tech Stack

## Context

Tech stack specifications for React/TypeScript frontend and Java backend applications following KWI back-office patterns and micro-frontend architecture.

## Frontend Stack

### Core Framework
- **Framework**: React 18.3.1 with TypeScript
- **Build Tool**: Webpack 5 with SystemJS module federation
- **Module Format**: SystemJS for micro-frontend integration
- **Node Version**: 18+ (managed via asdf)
- **Package Manager**: npm

### State Management
- **Client State**: Redux Toolkit 2.x with Redux Persist 6.x
- **Server State**: React Query/TanStack Query for API state
- **Form State**: React Hook Form for form management
- **Local State**: useState/useReducer for component state

### UI and Styling
- **Design System**: @kwi/ui-components (KWI internal design system)
- **Theme**: BackOfficeTheme from @kwi/ui-components
- **Icons**: Hero Icons (Phoenix default) or design system icons
- **Responsive Design**: Built into @kwi/ui-components
- **CSS**: CSS-in-JS via @kwi/ui-components or CSS modules

### Routing and Navigation
- **Router**: React Router DOM 6.x
- **Integration**: SystemJS module coordination with host application
- **Lazy Loading**: React.lazy for code splitting
- **Navigation**: Cross-origin communication for navigation events

### Development Tools
- **TypeScript**: 5.x (strict configuration)
- **Linting**: ESLint with TypeScript rules
- **Formatting**: Prettier integration
- **Testing**: React Testing Library, Jest, Cypress
- **Dev Server**: Webpack Dev Server with proxy configuration

### Integration Libraries
- **Authentication**: ClientInfoProvider from @kwi/ui-components
- **Internationalization**: TranslationsProvider with multi-language support
- **Configuration**: ConfigurationProvider for runtime configuration
- **Alerts**: AlertProvider for notifications
- **Error Handling**: ErrorProvider for global error handling
- **Analytics**: TelemetryProvider for usage tracking

### Build and Deployment
- **Build Output**: SystemJS module (`app-name.js`)
- **Asset Optimization**: Webpack 5 optimization and minification
- **Source Maps**: Generated for debugging in production
- **CDN Deployment**: Static asset deployment to CDN
- **Cache Busting**: Version-based cache management

## Backend Stack

### Core Framework
- **Language**: Java 8+ (JDK 8 minimum)
- **Framework**: JAX-RS 2.1.1 REST API
- **Application Server**: JBoss/WildFly
- **Build Tool**: Maven 3.6+
- **Packaging**: WAR file deployment

### Dependencies and Libraries
- **JSON Processing**: Jackson 2.13.4 (Core, Databind, Annotations)
- **API Documentation**: Swagger/OpenAPI 2.2.2 with annotations
- **Logging**: SLF4J 1.7.36 API with Logback implementation
- **Utilities**: Apache Commons Lang 3.12.0
- **Validation**: javax.validation annotations
- **Dependency Injection**: CDI (Context and Dependency Injection)

### Database and Persistence
- **Database**: PostgreSQL (primary database)
- **Connection Management**: KWI common persistence layer
- **Connection Factory**: JNDI connection factory for client-specific connections
- **Transaction Management**: JTA (Java Transaction API)
- **Query Approach**: Native SQL with parameterized queries
- **Schema Management**: Flyway or custom migration scripts

### Security and Authentication
- **Authentication**: ApiSecurityAuthenticator (KWI common pattern)
- **Authorization**: Basic Authentication with client credentials
- **Session Management**: Stateless with per-request authentication
- **Data Security**: Client-specific database connections and access controls
- **Input Validation**: javax.validation with custom validators

### Testing Framework
- **Unit Testing**: JUnit 4.13.2 (following KWI patterns)
- **Mocking**: Mockito 3.12.4 for mock objects
- **PowerMock**: PowerMock 2.0.9 for static mocking
- **Integration Testing**: TestContainers with PostgreSQL
- **API Testing**: REST Assured 5.3.0
- **Test Database**: H2 2.1.214 for unit tests

### Application Server Configuration
- **Server**: JBoss/WildFly with module system
- **JNDI Resources**: DataSource and connection factory configuration
- **CDI**: Context and Dependency Injection enabled
- **JAX-RS Provider**: RESTEasy (JBoss default)
- **JSON Provider**: Jackson JAX-RS JSON provider
- **CORS**: Cross-origin resource sharing configuration

## Integration Architecture

### Micro-Frontend Integration
- **Host Environment**: Embedded in existing JSP monolith
- **Module Loading**: SystemJS importmap registration
- **Shared Dependencies**: React and ReactDOM externalized
- **Context Sharing**: Authentication and theme context from host
- **Communication**: Cross-origin messaging for navigation

### API Integration
- **Protocol**: RESTful HTTP/HTTPS
- **Format**: JSON request/response bodies
- **Authentication**: Basic Auth headers
- **Error Handling**: Standardized ApiResponse wrapper format
- **Versioning**: URL path versioning (`/v1/`)
- **Documentation**: OpenAPI/Swagger generated documentation

### Development Environment Integration
- **Frontend Dev Server**: Webpack Dev Server on port 8002
- **Backend Dev Server**: JBoss/WildFly on port 8080
- **Database**: Local PostgreSQL or Docker container
- **Proxy Configuration**: Frontend proxy to backend for API calls
- **Hot Reloading**: Webpack HMR for frontend development

## Configuration Management

### Frontend Configuration
- **Environment Variables**: React environment variables with REACT_APP_ prefix
- **Runtime Configuration**: ConfigurationProvider with database-backed properties
- **Build Configuration**: Webpack environment-specific configurations
- **SystemJS Configuration**: Import map management and versioning

```javascript
// Development environment variables
REACT_APP_USE_PROXY=true
REACT_APP_AUTH_HEADER=Basic <credentials>
REACT_APP_PROXY_PATH=/common-bo-call/BackOfficeCallServlet
ENVIRONMENT=development
PUBLIC_PATH=/app-name/
```

### Backend Configuration
- **JNDI Properties**: Database connection configuration
- **System Properties**: JBoss system properties for application settings
- **Application Properties**: Configuration file for application-specific settings
- **Runtime Configuration**: Database-backed configuration properties

```xml
<!-- JNDI Configuration Example -->
<subsystem xmlns="urn:jboss:domain:naming:2.0">
    <bindings>
        <simple name="java:global/app-name/db/url" value="jdbc:postgresql://localhost:5432/db"/>
        <simple name="java:global/app-name/db/username" value="username"/>
        <simple name="java:global/app-name/db/password" value="password"/>
    </bindings>
</subsystem>
```

## Deployment Architecture

### Frontend Deployment
- **Static Assets**: CDN deployment with versioned URLs
- **Module Registration**: Database registration of SystemJS modules
- **Cache Strategy**: Long-term caching with version-based invalidation
- **Load Balancer**: Nginx with HTTPS termination

### Backend Deployment
- **Application Server**: JBoss/WildFly cluster
- **Load Balancing**: Round-robin with health checks
- **Database**: PostgreSQL with connection pooling
- **Monitoring**: Health check endpoints and metrics collection

### CI/CD Pipeline
- **Source Control**: Git with feature branch workflow
- **Build**: GitHub Actions or Jenkins
- **Testing**: Automated unit, integration, and E2E tests
- **Deployment**: Blue-green deployment strategy
- **Rollback**: Automated rollback procedures

## Development Tools and Workflow

### Frontend Development
```json
{
  "scripts": {
    "dev": "webpack serve --mode development",
    "build:dev": "webpack --mode development",
    "build:prod": "webpack --mode production",
    "test": "jest",
    "test:coverage": "jest --coverage",
    "lint": "eslint src --ext .ts,.tsx",
    "type-check": "tsc --noEmit"
  }
}
```

### Backend Development
```xml
<!-- Maven build lifecycle -->
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>3.8.1</version>
        </plugin>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-war-plugin</artifactId>
            <version>3.2.3</version>
        </plugin>
        <plugin>
            <groupId>io.swagger.core.v3</groupId>
            <artifactId>swagger-maven-plugin</artifactId>
            <version>2.2.2</version>
        </plugin>
    </plugins>
</build>
```

### Common Development Commands
```bash
# Frontend development
cd frontend && npm install && npm run dev

# Backend development  
cd backend && mvn clean compile && mvn test && mvn package

# Full stack with Docker
docker-compose up -d

# Testing
npm run test:coverage  # Frontend tests
mvn test              # Backend tests
npm run test:e2e      # End-to-end tests
```

## Performance and Scalability

### Frontend Performance
- **Code Splitting**: Route-based and component-based lazy loading
- **Bundle Optimization**: Webpack optimization and tree shaking
- **Caching**: Service worker caching and HTTP cache headers
- **Virtual Scrolling**: For large data sets
- **Memoization**: React.memo, useMemo, and useCallback optimization

### Backend Performance
- **Connection Pooling**: HikariCP or JBoss connection pooling
- **Query Optimization**: Indexed database queries and query planning
- **Caching**: Application-level caching where appropriate
- **Resource Management**: Proper connection and resource cleanup
- **Thread Pool**: JBoss worker thread pool optimization

### Monitoring and Observability
- **Health Checks**: REST endpoints for application health status
- **Metrics**: Application metrics and performance monitoring
- **Logging**: Structured logging with trace correlation
- **Error Tracking**: Comprehensive error logging and alerting

This tech stack provides a comprehensive foundation for building scalable, maintainable React/TypeScript frontend applications with Java REST API backends, following established KWI patterns and industry best practices.