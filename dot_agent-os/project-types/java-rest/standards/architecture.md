# System Architecture

## Overview

This document defines the architectural patterns and design principles for building scalable, maintainable Java REST API backends following KWI back-office patterns.

## Architecture Overview

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│               Backend (Java REST API)                       │
│                  JAX-RS + Maven                            │
├─────────────────────────────────────────────────────────────┤
│  • JAX-RS REST endpoints                                   │
│  • JBoss/WildFly application server                       │
│  • KWI common persistence layer                           │
│  • JNDI database connections                              │
│  • ApiSecurityAuthenticator integration                   │
└─────────────────────────────────────────────────────────────┘
                              │
                           JDBC/JNDI
                              │
┌─────────────────────────────────────────────────────────────┐
│                    Database Layer                           │
│                     PostgreSQL                             │
└─────────────────────────────────────────────────────────────┘
```

## Backend Architecture (Java REST API)

### JAX-RS Application Structure

Following KWI back-office patterns with JAX-RS and JBoss/WildFly:

```
backend/
├── src/main/java/com/kwi/backoffice/api/appname/
│   ├── application/      # JAX-RS Application configuration
│   ├── model/           # Domain models and entities
│   ├── request/         # Request DTOs and validation
│   ├── response/        # Response DTOs
│   ├── resource/        # REST API endpoints (controllers)
│   ├── service/         # Business logic layer
│   ├── dao/             # Data access layer
│   └── util/            # Utility classes and helpers
├── src/main/resources/
│   ├── META-INF/        # JBoss deployment configuration
│   ├── application.properties
│   └── logback.xml
└── src/test/java/       # Unit and integration tests
```

### JAX-RS Resource Pattern

```java
@Path("/entities")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Tag(name = "Entities", description = "Entity management operations")
public class EntityResource {

    @Inject
    private EntityService entityService;

    @Inject
    private ApiSecurityAuthenticator securityAuthenticator;

    @GET
    @Operation(summary = "Search entities")
    public Response searchEntities(
            @BeanParam @Valid EntitySearchRequest searchRequest,
            @Context HttpHeaders headers) {

        String traceId = UUID.randomUUID().toString();
        logger.info("Starting entity search - traceId: {}", traceId);

        try {
            // Authenticate request following KWI patterns
            String clientId = securityAuthenticator.authenticateRequest(headers);

            // Perform search
            PagedResponse<Entity> result = entityService.searchEntities(searchRequest, clientId);

            ApiResponse<PagedResponse<Entity>> response = ApiResponse.success(result);
            response.setTraceId(traceId);

            return Response.ok(response).build();

        } catch (SecurityException e) {
            logger.error("Authentication failed - traceId: {}", traceId, e);
            ApiResponse<?> response = ApiResponse.error("Unauthorized");
            response.setTraceId(traceId);
            return Response.status(Response.Status.UNAUTHORIZED).entity(response).build();
        }
    }
}
```

### Service Layer Pattern

```java
@ApplicationScoped
public class EntityService {

    @Inject
    private EntityDAO entityDAO;

    @Inject
    private EntityValidator entityValidator;

    @Transactional
    public PagedResponse<Entity> searchEntities(EntitySearchRequest request, String clientId) {
        logger.debug("Searching entities with criteria: {}", request);

        // Validate request
        entityValidator.validateSearchRequest(request);

        // Calculate offset
        int offset = (request.getPage() - 1) * request.getSize();

        // Perform search
        List<Entity> entities = entityDAO.searchEntities(request, clientId, offset, request.getSize());
        long totalCount = entityDAO.countEntities(request, clientId);

        // Create pagination info
        PaginationInfo pagination = new PaginationInfo(
            request.getPage(),
            request.getSize(),
            totalCount
        );

        return new PagedResponse<>(entities, pagination);
    }
}
```

### Data Access Layer Pattern

Following KWI common persistence patterns:

```java
public abstract class BaseDAO {

    @Inject
    protected DataAccess dataAccess;

    @Inject
    protected ConnectionFactory connectionFactory;

    protected Connection getConnection(String clientId) throws SQLException {
        return connectionFactory.getConnection(clientId);
    }

    protected void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                logger.warn("Error closing database connection", e);
            }
        }
    }
}

@ApplicationScoped
public class EntityDAO extends BaseDAO {

    public List<Entity> searchEntities(EntitySearchRequest request, String clientId, int offset, int limit) {
        Connection connection = null;
        try {
            connection = getConnection(clientId);

            // Use parameterized queries for SQL injection protection
            String sql = buildSearchQuery(request);

            try (PreparedStatement stmt = connection.prepareStatement(sql)) {
                setSearchParameters(stmt, request, offset, limit);

                try (ResultSet rs = stmt.executeQuery()) {
                    return mapResultSet(rs);
                }
            }

        } catch (SQLException e) {
            logger.error("Error searching entities for client: {}", clientId, e);
            rollbackTransaction(connection);
            throw new RuntimeException("Database error", e);
        } finally {
            closeConnection(connection);
        }
    }
}
```

## Security Architecture

### Backend Security Integration

```java
// Following KWI ApiSecurityAuthenticator patterns
@ApplicationScoped
public class ApiSecurityAuthenticator {

    public String authenticateRequest(HttpHeaders headers) throws SecurityException {
        List<String> authHeaders = headers.getRequestHeader("Authorization");

        if (authHeaders == null || authHeaders.isEmpty()) {
            throw new SecurityException("Authorization header is required");
        }

        String authHeader = authHeaders.get(0);

        if (!authHeader.startsWith("Basic ")) {
            throw new SecurityException("Invalid authorization format");
        }

        // Extract and validate credentials
        String credentials = authHeader.substring(6);
        String[] decodedCredentials = decodeBasicAuth(credentials);

        if (decodedCredentials.length != 2) {
            throw new SecurityException("Invalid credentials");
        }

        String clientId = decodedCredentials[0];
        String password = decodedCredentials[1];

        // Validate credentials against KWI authentication system
        if (!validateCredentials(clientId, password)) {
            throw new SecurityException("Authentication failed");
        }

        return clientId;
    }
}
```

## Database Integration Pattern

### JNDI Connection Management

```java
// Database configuration following KWI patterns
@ApplicationScoped
public class DatabaseConnectionManager {

    private static final String JNDI_NAME = "java:/AppNameDS";

    @Inject
    private ConnectionFactory connectionFactory;

    public Connection getConnection(String clientId) throws SQLException {
        try {
            // Use JNDI connection factory for client-specific connections
            return connectionFactory.getConnection(clientId);
        } catch (NamingException e) {
            logger.error("Failed to lookup JNDI resource: {}", JNDI_NAME, e);
            throw new SQLException("Database connection failed", e);
        }
    }
}
```

### JBoss/WildFly Configuration

```xml
<!-- jboss-deployment-structure.xml -->
<jboss-deployment-structure>
    <deployment>
        <dependencies>
            <module name="com.fasterxml.jackson.core.jackson-core"/>
            <module name="com.fasterxml.jackson.core.jackson-databind"/>
            <module name="com.fasterxml.jackson.core.jackson-annotations"/>
            <module name="com.fasterxml.jackson.jaxrs.jackson-jaxrs-json-provider"/>
        </dependencies>
    </deployment>
</jboss-deployment-structure>

<!-- jboss-web.xml -->
<jboss-web>
    <context-root>app-name-service</context-root>
</jboss-web>
```

## API Design Patterns

### Standardized Response Format

```java
@Schema(description = "Standard API response wrapper")
public class ApiResponse<T> {

    private T data;
    private boolean success;
    private String message;
    private List<ErrorDetail> errors;
    private LocalDateTime timestamp;
    private String traceId;

    public static <T> ApiResponse<T> success(T data) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setSuccess(true);
        response.setData(data);
        response.setMessage("Success");
        response.setTimestamp(LocalDateTime.now());
        return response;
    }

    public static <T> ApiResponse<T> error(String message) {
        ApiResponse<T> response = new ApiResponse<>();
        response.setSuccess(false);
        response.setMessage(message);
        response.setTimestamp(LocalDateTime.now());
        return response;
    }
}
```

### Paginated Responses

```java
@Schema(description = "Paginated response for list operations")
public class PagedResponse<T> {

    private List<T> items;
    private PaginationInfo pagination;

    public PagedResponse(List<T> items, PaginationInfo pagination) {
        this.items = items;
        this.pagination = pagination;
    }
}

@Schema(description = "Pagination metadata")
public class PaginationInfo {
    private int page;
    private int size;
    private long total;
    private int totalPages;
    private boolean hasNext;
    private boolean hasPrevious;

    public PaginationInfo(int page, int size, long total) {
        this.page = page;
        this.size = size;
        this.total = total;
        this.totalPages = (int) Math.ceil((double) total / size);
        this.hasNext = page < totalPages;
        this.hasPrevious = page > 1;
    }
}
```

## Configuration Management

### Backend Configuration

Following KWI patterns with JNDI properties and runtime configuration:

```java
// Runtime configuration via database properties
@ApplicationScoped
public class ConfigurationService {

    @Inject
    private ConfigDAO configDAO;

    public String getConfigValue(String key, String defaultValue) {
        try {
            String value = configDAO.getConfigValue(key);
            return value != null ? value : defaultValue;
        } catch (Exception e) {
            logger.warn("Failed to get config value for key: {}", key, e);
            return defaultValue;
        }
    }
}
```

## Deployment Architecture

### Backend WAR Deployment

Following KWI deployment patterns with JBoss/WildFly:

```bash
# Production deployment
mvn clean package -DskipTests=false
cp target/app-name-service.war $JBOSS_HOME/standalone/deployments/

# Health check verification
curl -H "Authorization: Basic $(echo -n 'health:check' | base64)" \
     http://server:8080/app-name-service/v1/health
```

## Best Practices

### Backend Best Practices

1. **Security**: Always validate client authentication, use parameterized queries
2. **Transaction Management**: Proper transaction boundaries, rollback on errors
3. **Error Handling**: Comprehensive error handling with proper HTTP status codes
4. **Logging**: Structured logging with trace IDs for request tracking
5. **Testing**: Unit tests with JUnit/Mockito, integration tests with TestContainers

This architecture provides a robust foundation for building scalable Java REST API backends, following established KWI back-office patterns and industry best practices.