# Development Best Practices

## Context

Development guidelines for React/TypeScript frontend and Java backend applications following KWI back-office patterns and micro-frontend architecture.

<conditional-block context-check="core-principles">
IF this Core Principles section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using Core Principles already in context"
ELSE:
  READ: The following principles

## Core Principles

### Keep It Simple
- Implement code in the fewest lines possible
- Avoid over-engineering solutions
- Choose straightforward approaches over clever ones
- Follow established KWI patterns rather than inventing new ones

### Optimize for Readability
- Prioritize code clarity over micro-optimizations
- Write self-documenting code with clear variable names
- Add comments for "why" not "what"
- Use TypeScript strictly to improve code readability

### DRY (Don't Repeat Yourself)
- Extract repeated business logic to private methods
- Extract repeated UI markup to reusable components using @kwi/ui-components
- Create utility functions for common operations
- Leverage KWI common libraries and patterns

### File Structure
- Keep files focused on a single responsibility
- Group related functionality together
- Use consistent naming conventions
- Follow established project structure patterns
</conditional-block>

## Frontend Best Practices (React/TypeScript)

### SystemJS Module Federation

#### Module Design Patterns
- Build as SystemJS modules with shared externals (React, ReactDOM)
- Use @kwi/ui-components design system for consistency
- Implement proper error boundaries for module isolation
- Follow KWI back-office integration patterns

```typescript
// Proper SystemJS module entry point
import { BackOfficeTheme, ThemeProvider } from '@kwi/ui-components';

const Main: React.FC = () => {
    return (
        <ClientInfoProvider selector="#app-root">
            <ThemeProvider theme={BackOfficeTheme}>
                <App />
            </ThemeProvider>
        </ClientInfoProvider>
    );
};

// Export for SystemJS
if (typeof window !== 'undefined') {
    const rootElement = document.getElementById('app-root');
    if (rootElement) {
        const root = ReactDOM.createRoot(rootElement);
        root.render(<Main />);
    }
}
```

#### Configuration Management
- Use ConfigurationProvider from @kwi/ui-components
- Define clear configuration keys with TypeScript constants
- Support runtime configuration via database properties
- Handle missing configuration gracefully with sensible defaults

```typescript
export const ConfigKeys = {
    API_ENDPOINT: 'app.name.api.endpoint',
    DEFAULT_PAGE_SIZE: 'app.name.pagination.default.size',
    ENABLE_ADVANCED_FEATURES: 'app.name.features.advanced'
} as const;

// Usage with proper error handling
const configs = useConfigurations();
const pageSize = configs.get(ConfigKeys.DEFAULT_PAGE_SIZE, '25');
```

### State Management

#### Redux Toolkit Patterns
- Use createSlice for state management
- Implement Redux Persist for selective state persistence
- Separate server state (React Query) from client state (Redux)
- Use proper TypeScript typing for all state

```typescript
// Proper slice definition with TypeScript
export interface EntityState {
    entities: Entity[];
    loading: boolean;
    error: string | null;
    filters: EntityFilters;
}

export const entitySlice = createSlice({
    name: 'entities',
    initialState,
    reducers: {
        clearEntities: (state) => {
            state.entities = [];
        },
        setFilters: (state, action: PayloadAction<EntityFilters>) => {
            state.filters = action.payload;
        }
    },
    extraReducers: (builder) => {
        builder
            .addCase(fetchEntities.pending, (state) => {
                state.loading = true;
                state.error = null;
            })
            .addCase(fetchEntities.fulfilled, (state, action) => {
                state.loading = false;
                state.entities = action.payload.items;
            })
    }
});
```

#### API State Management
- Use React Query for server state management
- Implement proper cache invalidation strategies
- Handle loading and error states consistently
- Use optimistic updates where appropriate

```typescript
// Service layer with React Query
export const useEntities = (filters: EntityFilters) => {
    return useQuery({
        queryKey: ['entities', filters],
        queryFn: () => EntityService.searchEntities(filters),
        staleTime: 5 * 60 * 1000, // 5 minutes
        retry: 3
    });
};

export const useCreateEntity = () => {
    const queryClient = useQueryClient();
    
    return useMutation({
        mutationFn: EntityService.createEntity,
        onSuccess: () => {
            // Invalidate and refetch entities
            queryClient.invalidateQueries(['entities']);
        },
        onError: (error) => {
            // Handle error with user feedback
            console.error('Failed to create entity:', error);
        }
    });
};
```

### Component Design

#### Component Architecture
- Use functional components with hooks
- Implement proper prop types with TypeScript
- Follow single responsibility principle
- Use @kwi/ui-components for consistent UI

```typescript
interface EntityCardProps {
    entity: Entity;
    onEdit?: (entity: Entity) => void;
    onDelete?: (entityId: string) => void;
    readonly?: boolean;
}

export const EntityCard: React.FC<EntityCardProps> = ({
    entity,
    onEdit,
    onDelete,
    readonly = false
}) => {
    const handleEdit = useCallback(() => {
        onEdit?.(entity);
    }, [entity, onEdit]);

    return (
        <Card>
            <CardHeader>
                <CardTitle>{entity.name}</CardTitle>
            </CardHeader>
            <CardContent>
                <Text>{entity.description}</Text>
            </CardContent>
            {!readonly && (
                <CardActions>
                    <Button onClick={handleEdit}>Edit</Button>
                    <Button variant="danger" onClick={() => onDelete?.(entity.id)}>
                        Delete
                    </Button>
                </CardActions>
            )}
        </Card>
    );
};
```

#### Performance Optimization
- Use React.memo for expensive components
- Implement useMemo and useCallback appropriately
- Use code splitting with lazy loading
- Implement virtual scrolling for large datasets

```typescript
// Memoized component
export const EntityList = React.memo<EntityListProps>(({ entities, onEntityAction }) => {
    const memoizedColumns = useMemo(() => [
        { field: 'name', headerName: 'Name', flex: 1 },
        { field: 'status', headerName: 'Status', width: 120 },
        { 
            field: 'actions', 
            headerName: 'Actions', 
            width: 150,
            renderCell: (params) => <EntityActions entity={params.row} />
        }
    ], []);

    return (
        <DataGrid
            rows={entities}
            columns={memoizedColumns}
            loading={loading}
        />
    );
});
```

### Testing Strategy

#### Unit Testing
- Use React Testing Library for component testing
- Test user interactions, not implementation details
- Mock external dependencies appropriately
- Maintain high test coverage (>80%)

```typescript
// Proper component testing
describe('EntityCard', () => {
    const mockEntity = {
        id: '1',
        name: 'Test Entity',
        description: 'Test Description',
        status: 'ACTIVE'
    };

    it('renders entity information correctly', () => {
        render(<EntityCard entity={mockEntity} />);
        
        expect(screen.getByText('Test Entity')).toBeInTheDocument();
        expect(screen.getByText('Test Description')).toBeInTheDocument();
    });

    it('calls onEdit when edit button is clicked', async () => {
        const mockOnEdit = jest.fn();
        const user = userEvent.setup();
        
        render(<EntityCard entity={mockEntity} onEdit={mockOnEdit} />);
        
        await user.click(screen.getByText('Edit'));
        
        expect(mockOnEdit).toHaveBeenCalledWith(mockEntity);
    });
});
```

#### Integration Testing
- Use MSW (Mock Service Worker) for API mocking
- Test complete user workflows
- Verify error handling scenarios
- Test accessibility compliance

## Backend Best Practices (Java/JAX-RS)

### Architecture Patterns

#### Layered Architecture
- Follow clear separation: Resource → Service → DAO
- Use dependency injection with @Inject
- Implement proper transaction boundaries with @Transactional
- Follow KWI common persistence patterns

```java
@Path("/entities")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class EntityResource {
    
    @Inject
    private EntityService entityService;
    
    @Inject
    private ApiSecurityAuthenticator securityAuthenticator;
    
    @GET
    public Response searchEntities(
            @BeanParam @Valid EntitySearchRequest request,
            @Context HttpHeaders headers) {
        
        String traceId = UUID.randomUUID().toString();
        
        try {
            String clientId = securityAuthenticator.authenticateRequest(headers);
            PagedResponse<Entity> result = entityService.searchEntities(request, clientId);
            
            ApiResponse<PagedResponse<Entity>> response = ApiResponse.success(result);
            response.setTraceId(traceId);
            
            return Response.ok(response).build();
            
        } catch (SecurityException e) {
            ApiResponse<?> response = ApiResponse.error("Unauthorized");
            response.setTraceId(traceId);
            return Response.status(Response.Status.UNAUTHORIZED).entity(response).build();
        }
    }
}
```

#### Service Layer Design
- Keep business logic in service classes
- Use proper validation with javax.validation
- Implement comprehensive error handling
- Follow transaction management best practices

```java
@ApplicationScoped
public class EntityService {
    
    @Inject
    private EntityDAO entityDAO;
    
    @Inject
    private EntityValidator entityValidator;
    
    @Transactional
    public Entity createEntity(Entity entity, String clientId) {
        // Validate input
        entityValidator.validateEntity(entity);
        
        // Check business rules
        if (entityDAO.existsByName(entity.getName(), clientId)) {
            throw new IllegalArgumentException("Entity with name '" + entity.getName() + "' already exists");
        }
        
        // Set audit fields
        entity.setId(generateEntityId());
        entity.setCreatedDate(LocalDateTime.now());
        entity.setCreatedBy(clientId);
        entity.setLastModifiedDate(LocalDateTime.now());
        entity.setLastModifiedBy(clientId);
        
        // Persist entity
        return entityDAO.create(entity, clientId);
    }
    
    private String generateEntityId() {
        return "ENT" + UUID.randomUUID().toString().replaceAll("-", "").substring(0, 10).toUpperCase();
    }
}
```

### Database Access Patterns

#### JNDI Connection Management
- Use KWI ConnectionFactory for client-specific connections
- Implement proper connection lifecycle management
- Use parameterized queries for SQL injection prevention
- Follow transaction rollback patterns

```java
@ApplicationScoped
public class EntityDAO extends BaseDAO {
    
    public List<Entity> searchEntities(EntitySearchRequest request, String clientId, int offset, int limit) {
        Connection connection = null;
        try {
            connection = getConnection(clientId);
            
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT * FROM entities WHERE client_id = ?");
            
            List<Object> parameters = new ArrayList<>();
            parameters.add(clientId);
            
            if (StringUtils.isNotBlank(request.getQuery())) {
                sql.append(" AND (name ILIKE ? OR description ILIKE ?)");
                String searchTerm = "%" + request.getQuery() + "%";
                parameters.add(searchTerm);
                parameters.add(searchTerm);
            }
            
            sql.append(" ORDER BY ").append(request.getSortBy()).append(" ").append(request.getSortDirection());
            sql.append(" LIMIT ? OFFSET ?");
            parameters.add(limit);
            parameters.add(offset);
            
            try (PreparedStatement stmt = connection.prepareStatement(sql.toString())) {
                for (int i = 0; i < parameters.size(); i++) {
                    stmt.setObject(i + 1, parameters.get(i));
                }
                
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

### Security Implementation

#### Authentication Integration
- Follow KWI ApiSecurityAuthenticator patterns
- Implement proper Basic Auth validation
- Use client-specific database connections
- Log security events appropriately

```java
@ApplicationScoped
public class ApiSecurityAuthenticator {
    
    private static final Logger logger = LoggerFactory.getLogger(ApiSecurityAuthenticator.class);
    
    public String authenticateRequest(HttpHeaders headers) throws SecurityException {
        List<String> authHeaders = headers.getRequestHeader("Authorization");
        
        if (authHeaders == null || authHeaders.isEmpty()) {
            logger.warn("Missing authorization header");
            throw new SecurityException("Authorization header is required");
        }
        
        String authHeader = authHeaders.get(0);
        
        if (!authHeader.startsWith("Basic ")) {
            logger.warn("Invalid authorization header format");
            throw new SecurityException("Invalid authorization format");
        }
        
        String[] credentials = decodeBasicAuth(authHeader.substring(6));
        
        if (credentials.length != 2) {
            logger.warn("Invalid credentials format");
            throw new SecurityException("Invalid credentials");
        }
        
        String clientId = credentials[0];
        String password = credentials[1];
        
        if (!validateCredentials(clientId, password)) {
            logger.warn("Authentication failed for client: {}", clientId);
            throw new SecurityException("Authentication failed");
        }
        
        logger.debug("Authentication successful for client: {}", clientId);
        return clientId;
    }
}
```

### Error Handling and Logging

#### Comprehensive Error Handling
- Use standardized response formats
- Implement proper exception mapping
- Log errors with trace IDs for debugging
- Provide user-friendly error messages

```java
// Global exception handler
@Provider
public class GlobalExceptionMapper implements ExceptionMapper<Exception> {
    
    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionMapper.class);
    
    @Override
    public Response toResponse(Exception exception) {
        String traceId = UUID.randomUUID().toString();
        
        if (exception instanceof SecurityException) {
            logger.warn("Security exception - traceId: {}", traceId, exception);
            ApiResponse<?> response = ApiResponse.error("Unauthorized");
            response.setTraceId(traceId);
            return Response.status(Response.Status.UNAUTHORIZED).entity(response).build();
            
        } else if (exception instanceof IllegalArgumentException) {
            logger.warn("Validation exception - traceId: {}", traceId, exception);
            ApiResponse<?> response = ApiResponse.error("Validation error: " + exception.getMessage());
            response.setTraceId(traceId);
            return Response.status(Response.Status.BAD_REQUEST).entity(response).build();
            
        } else {
            logger.error("Unexpected exception - traceId: {}", traceId, exception);
            ApiResponse<?> response = ApiResponse.error("Internal server error");
            response.setTraceId(traceId);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(response).build();
        }
    }
}
```

#### Structured Logging
- Use SLF4J with Logback for logging
- Include trace IDs for request correlation
- Log at appropriate levels (DEBUG, INFO, WARN, ERROR)
- Include contextual information in log messages

```java
public class EntityService {
    
    private static final Logger logger = LoggerFactory.getLogger(EntityService.class);
    
    @Transactional
    public Entity createEntity(Entity entity, String clientId) {
        String traceId = UUID.randomUUID().toString();
        logger.info("Creating entity - name: {}, clientId: {}, traceId: {}", 
                   entity.getName(), clientId, traceId);
        
        try {
            Entity created = performCreate(entity, clientId);
            logger.info("Entity created successfully - id: {}, traceId: {}", 
                       created.getId(), traceId);
            return created;
            
        } catch (Exception e) {
            logger.error("Failed to create entity - name: {}, clientId: {}, traceId: {}", 
                        entity.getName(), clientId, traceId, e);
            throw e;
        }
    }
}
```

### Testing Strategy

#### Unit Testing with JUnit 4
- Follow KWI patterns with JUnit 4, Mockito, and PowerMock
- Test business logic thoroughly
- Mock external dependencies
- Maintain high test coverage

```java
@RunWith(MockitoJUnitRunner.class)
public class EntityServiceTest {
    
    @Mock
    private EntityDAO entityDAO;
    
    @Mock
    private EntityValidator entityValidator;
    
    @InjectMocks
    private EntityService entityService;
    
    private Entity testEntity;
    private String clientId = "TEST_CLIENT";
    
    @Before
    public void setUp() {
        testEntity = new Entity();
        testEntity.setName("Test Entity");
        testEntity.setDescription("Test Description");
    }
    
    @Test
    public void testCreateEntity_Success() {
        // Arrange
        doNothing().when(entityValidator).validateEntity(testEntity);
        when(entityDAO.existsByName("Test Entity", clientId)).thenReturn(false);
        when(entityDAO.create(any(Entity.class), eq(clientId))).thenReturn(testEntity);
        
        // Act
        Entity result = entityService.createEntity(testEntity, clientId);
        
        // Assert
        assertNotNull(result);
        assertNotNull(result.getId());
        assertNotNull(result.getCreatedDate());
        assertEquals(clientId, result.getCreatedBy());
        verify(entityValidator).validateEntity(testEntity);
        verify(entityDAO).create(any(Entity.class), eq(clientId));
    }
    
    @Test(expected = IllegalArgumentException.class)
    public void testCreateEntity_DuplicateName() {
        // Arrange
        doNothing().when(entityValidator).validateEntity(testEntity);
        when(entityDAO.existsByName("Test Entity", clientId)).thenReturn(true);
        
        // Act
        entityService.createEntity(testEntity, clientId);
        
        // Assert - exception should be thrown
    }
}
```

#### Integration Testing
- Use TestContainers for database testing
- Test REST endpoints with REST Assured
- Verify complete request/response flows
- Test error scenarios and edge cases

<conditional-block context-check="dependencies" task-condition="choosing-external-library">
IF current task involves choosing an external library:
  IF Dependencies section already read in current context:
    SKIP: Re-reading this section
    NOTE: "Using Dependencies guidelines already in context"
  ELSE:
    READ: The following guidelines
ELSE:
  SKIP: Dependencies section not relevant to current task

## Dependencies

### Choose Libraries Wisely
When adding third-party dependencies:

#### Frontend Dependencies
- Prefer @kwi/ui-components over external UI libraries
- Use established libraries: React Query for server state, Redux Toolkit for client state
- Check library compatibility with SystemJS module federation
- Verify library size impact on bundle size

#### Backend Dependencies
- Follow KWI common library patterns
- Use established Java libraries: Jackson for JSON, SLF4J for logging
- Prefer libraries that work well with JBoss/WildFly
- Check for security vulnerabilities in dependencies

#### Evaluation Criteria
- Select the most popular and actively maintained option
- Check the library's GitHub repository for:
  - Recent commits (within last 6 months)
  - Active issue resolution
  - Number of stars/downloads
  - Clear documentation
  - License compatibility
</conditional-block>

## Deployment and DevOps

### Build and Deployment
- Use established CI/CD pipelines following KWI patterns
- Implement proper environment configuration
- Use blue-green deployments for zero-downtime updates
- Maintain proper versioning and rollback procedures

### Monitoring and Observability
- Implement health check endpoints
- Use structured logging with trace correlation
- Monitor application metrics and performance
- Set up alerting for critical errors and performance degradation

### Security Best Practices
- Always validate and sanitize input data
- Use HTTPS for all communications
- Implement proper CORS configuration
- Follow principle of least privilege for database access
- Regular security audits and dependency updates

These best practices ensure high-quality, maintainable, and secure React/TypeScript frontend applications with Java REST API backends, following established KWI patterns and industry standards.