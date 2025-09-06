# System Architecture

## Overview

This document defines the architectural patterns and design principles for building scalable, maintainable full-stack applications using React with TypeScript frontend and Java REST API backend, following KWI back-office patterns and micro-frontend architecture.

## Architecture Overview

### System Components

```
┌─────────────────────────────────────────────────────────────┐
│                Frontend (React/TypeScript)                  │
│                 SystemJS Module Federation                  │
├─────────────────────────────────────────────────────────────┤
│  • React 18 + TypeScript                                   │
│  • Redux Toolkit + Redux Persist                           │
│  • @kwi/ui-components design system                        │
│  • SystemJS module format                                  │
│  • Webpack 5 module federation                             │
└─────────────────────────────────────────────────────────────┘
                              │
                         HTTP/HTTPS
                              │
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

## Frontend Architecture (React/TypeScript)

### Micro-Frontend Integration Pattern

Following KWI back-office patterns for SystemJS module federation:

```javascript
// Webpack configuration for SystemJS module output
module.exports = {
  output: {
    filename: 'app-name.js',
    libraryTarget: 'system',
    externals: ['react', 'react-dom']
  },
  plugins: [
    new webpack.EnvironmentPlugin({
      REACT_APP_USE_PROXY: "true",
      REACT_APP_AUTH_HEADER: process.env.REACT_APP_AUTH_HEADER,
      REACT_APP_PROXY_PATH: '/common-bo-call/BackOfficeCallServlet'
    })
  ]
};
```

### Application Structure

```
src/
├── ui/                    # UI components and pages
│   ├── components/        # Reusable UI components
│   ├── pages/            # Route components
│   └── layout/           # Layout components
├── state/                # Redux store and slices
│   ├── store.ts          # Store configuration
│   └── slices/           # Redux slices
├── services/             # API service layer
├── router/               # Route configuration
├── utils/                # Utility functions
├── types/                # TypeScript type definitions
├── i18n/                 # Internationalization
└── main.tsx              # Application entry point
```

### Component Integration Pattern

```typescript
// Main application bootstrap
import {
    BackOfficeTheme,
    DeviceInfoProvider,
    ThemeProvider,
    TranslationsProvider,
    ConfigurationProvider,
    WorkflowModalProvider,
    ClientInfoProvider,
    AlertProvider,
    TelemetryProvider,
    ErrorProvider,
} from '@kwi/ui-components';

const Main: React.FC = () => {
    return (
        <ClientInfoProvider selector="#app-root">
            <ThemeProvider theme={BackOfficeTheme}>
                <DeviceInfoProvider>
                    <TranslationsProvider prefixes={['common.', 'backoffice.app']}>
                        <AlertProvider maxAlerts={3}>
                            <ConfigurationProvider configKeys={ConfigKeys}>
                                <ErrorProvider>
                                    <TelemetryProvider appName="backoffice-app">
                                        <WorkflowModalProvider>
                                            <App />
                                        </WorkflowModalProvider>
                                    </TelemetryProvider>
                                </ErrorProvider>
                            </ConfigurationProvider>
                        </AlertProvider>
                    </TranslationsProvider>
                </DeviceInfoProvider>
            </ThemeProvider>
        </ClientInfoProvider>
    );
};
```

### State Management Pattern

Using Redux Toolkit with Redux Persist for state management:

```typescript
// Store configuration
import { configureStore } from '@reduxjs/toolkit';
import { persistStore, persistReducer } from 'redux-persist';
import storage from 'redux-persist/lib/storage';

const persistConfig = {
    key: 'app-name',
    storage,
    whitelist: ['filters'] // Only persist certain slices
};

const rootReducer = {
    entities: entitiesSlice.reducer,
    filters: persistReducer(persistConfig, filtersSlice.reducer),
    ui: uiSlice.reducer
};

export const store = configureStore({
    reducer: rootReducer,
    middleware: (getDefaultMiddleware) =>
        getDefaultMiddleware({
            serializableCheck: {
                ignoredActions: [FLUSH, REHYDRATE, PAUSE, PERSIST, PURGE, REGISTER],
            },
        }),
});
```

### Service Layer Pattern

```typescript
// Base API service following KWI patterns
export class BaseService {
    private static baseUrl = Env.datasourceSettings.baseUrl || '/api-service/v1';
    
    protected static async request<T>(
        endpoint: string,
        options: RequestInit = {}
    ): Promise<T> {
        const url = `${this.baseUrl}${endpoint}`;
        
        const defaultOptions: RequestInit = {
            headers: {
                'Content-Type': 'application/json',
                ...Env.authHeaders,
                ...options.headers
            }
        };
        
        const config = { ...defaultOptions, ...options };
        
        try {
            const response = await fetch(url, config);
            
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
            return await response.json();
        } catch (error) {
            console.error('API request failed:', error);
            throw error;
        }
    }
}
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

### Frontend Authentication Integration

```typescript
// Authentication context from host application
export const useAuth = () => {
    const authContext = useContext(ClientInfoContext);
    
    return {
        user: authContext.user,
        token: authContext.token,
        isAuthenticated: authContext.isAuthenticated,
        hasPermission: (permission: string) => 
            authContext.user?.permissions?.includes(permission) || false
    };
};

// API service with authentication
class ApiClient {
    async request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
        const authHeaders = Env.authHeaders;
        
        const config: RequestInit = {
            ...options,
            headers: {
                'Content-Type': 'application/json',
                ...authHeaders,
                ...options.headers,
            },
        };
        
        const response = await fetch(`${this.baseURL}${endpoint}`, config);
        
        if (response.status === 401) {
            // Handle authentication failure
            throw new Error('Unauthorized');
        }
        
        return response.json();
    }
}
```

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

### Frontend Configuration

```typescript
// Configuration keys following KWI patterns
export const ConfigKeys = {
    API_ENDPOINT: 'app.name.api.endpoint',
    DEFAULT_PAGE_SIZE: 'app.name.pagination.default.size',
    ENABLE_ADVANCED_FEATURES: 'app.name.features.advanced',
    MAX_UPLOAD_SIZE: 'app.name.upload.max.size'
} as const;

// Usage in components
const configs = useConfigurations();
const apiEndpoint = configs.get(ConfigKeys.API_ENDPOINT);
```

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

### SystemJS Module Deployment

```javascript
// Production SystemJS import map
{
  "imports": {
    "react": "https://cdn.kwi.com/react/18.3.1/react.production.min.js",
    "react-dom": "https://cdn.kwi.com/react-dom/18.3.1/react-dom.production.min.js",
    "@kwi/app-name": "https://cdn.kwi.com/app-name/v1.0.0/app-name.js"
  }
}
```

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

### Frontend Best Practices

1. **Component Design**: Use @kwi/ui-components design system consistently
2. **State Management**: Server state via React Query, client state via Redux
3. **Type Safety**: Strict TypeScript configuration, avoid `any`
4. **Performance**: Code splitting, memoization, virtual scrolling for large datasets
5. **Testing**: Unit tests with React Testing Library, integration tests, E2E with Cypress

### Backend Best Practices

1. **Security**: Always validate client authentication, use parameterized queries
2. **Transaction Management**: Proper transaction boundaries, rollback on errors
3. **Error Handling**: Comprehensive error handling with proper HTTP status codes
4. **Logging**: Structured logging with trace IDs for request tracking
5. **Testing**: Unit tests with JUnit/Mockito, integration tests with TestContainers

### Integration Best Practices

1. **API Contracts**: Use OpenAPI/Swagger for API documentation
2. **Versioning**: Semantic versioning for both frontend and backend
3. **Monitoring**: Health checks, metrics, and observability
4. **Deployment**: Blue-green deployments, automated rollback procedures
5. **Security**: HTTPS, CORS configuration, input validation at all layers

This architecture provides a robust foundation for building scalable React/TypeScript frontend applications with Java REST API backends, following established KWI back-office patterns and industry best practices.