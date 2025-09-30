# Tech Stack

## Context

Tech stack specifications for Java REST API backend applications following KWI back-office patterns.

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

## API Integration

### REST API Design
- **Protocol**: RESTful HTTP/HTTPS
- **Format**: JSON request/response bodies
- **Authentication**: Basic Auth headers
- **Error Handling**: Standardized ApiResponse wrapper format
- **Versioning**: URL path versioning (`/v1/`)
- **Documentation**: OpenAPI/Swagger generated documentation

### Development Environment Integration
- **Backend Dev Server**: JBoss/WildFly on port 8080
- **Database**: Local PostgreSQL or Docker container
- **Hot Reloading**: JBoss hot deployment for WAR updates

## Configuration Management

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

### Backend Deployment
- **Application Server**: JBoss/WildFly cluster
- **Load Balancing**: Round-robin with health checks
- **Database**: PostgreSQL with connection pooling
- **Monitoring**: Health check endpoints and metrics collection

### CI/CD Pipeline
- **Source Control**: Git with feature branch workflow
- **Build**: GitLab CI/CD
- **Testing**: Automated unit, integration, and E2E tests
- **Deployment**: Blue-green deployment strategy
- **Rollback**: Automated rollback procedures

## Development Tools and Workflow

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
# Backend development
cd backend && mvn clean compile && mvn test && mvn package

# Full stack with Docker
docker-compose up -d

# Testing
mvn test              # Backend tests
mvn verify            # Integration tests
```

## Performance and Scalability

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

This tech stack provides a comprehensive foundation for building scalable, maintainable Java REST API backend applications, following established KWI patterns and industry best practices.