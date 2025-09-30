# Development Best Practices

## Context

Development guidelines for Java REST API backend applications following KWI back-office patterns.

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
- Use proper Java conventions

### DRY (Don't Repeat Yourself)
- Extract repeated business logic to private methods
- Create utility functions for common operations
- Leverage KWI common libraries and patterns

### File Structure
- Keep files focused on a single responsibility
- Group related functionality together
- Use consistent naming conventions
- Follow established project structure patterns
</conditional-block>

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

#### Test Pyramid
- **Maintain a healthy test pyramid**: 70% unit tests, 20% integration tests, 10% end-to-end tests
- **Coverage requirements**: Maintain ≥80% code coverage overall
- **Independent execution**: Each test type should be runnable independently
- **Self-contained**: Each test suite sets up required mocks/environments
- **Note**: Security and performance tests are separate categories (see dedicated sections below)

#### Test Commands Structure

```bash
# 1. Unit tests only (no database required)
mvn test

# 2. Integration tests only (requires database)
mvn test -Pintegration-tests

# 3. E2E tests only (requires full environment)
mvn test -Pe2e-tests

# 4. All functional tests (unit + integration + e2e)
mvn test -Pall-tests

# 5. Security tests (separate category)
mvn clean verify -Psecurity-checks

# 6. Performance tests (separate category, dedicated environment)
mvn jmeter:jmeter -Pperformance-tests
```

#### Unit Testing with JUnit 4
- Follow KWI patterns with JUnit 4, Mockito, and PowerMock
- Test business logic thoroughly
- Mock external dependencies
- Fast execution (no I/O operations)
- No database or external service dependencies

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

### Security Testing

#### OWASP Top 10 Compliance
- **Requirement**: All applications must be tested for OWASP Top 10 vulnerabilities
- Test for common security risks:
  - A01: Broken Access Control
  - A02: Cryptographic Failures
  - A03: Injection (SQL, LDAP, etc.)
  - A04: Insecure Design
  - A05: Security Misconfiguration
  - A06: Vulnerable and Outdated Components
  - A07: Identification and Authentication Failures
  - A08: Software and Data Integrity Failures
  - A09: Security Logging and Monitoring Failures
  - A10: Server-Side Request Forgery (SSRF)

#### Dependency Vulnerability Scanning
- **Tool**: OWASP Dependency-Check Maven plugin (free, open source)
- **Configuration**: Add to `pom.xml`:

```xml
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>8.4.0</version>
    <configuration>
        <failBuildOnCVSS>7</failBuildOnCVSS>
        <suppressionFile>dependency-check-suppressions.xml</suppressionFile>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>check</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

- **Run command**: `mvn dependency-check:check`
- **Integration**: Include in CI/CD pipeline for every build
- **Action**: Fail builds for CVE scores >= 7 (configurable)

#### Static Application Security Testing (SAST)

**SpotBugs with Security Plugin**
- Free, open source static analysis tool
- Configuration in `pom.xml`:

```xml
<plugin>
    <groupId>com.github.spotbugs</groupId>
    <artifactId>spotbugs-maven-plugin</artifactId>
    <version>4.7.3.6</version>
    <dependencies>
        <dependency>
            <groupId>com.h3xstream.findsecbugs</groupId>
            <artifactId>findsecbugs-plugin</artifactId>
            <version>1.12.0</version>
        </dependency>
    </dependencies>
    <configuration>
        <effort>Max</effort>
        <threshold>Low</threshold>
        <failOnError>true</failOnError>
        <plugins>
            <plugin>
                <groupId>com.h3xstream.findsecbugs</groupId>
                <artifactId>findsecbugs-plugin</artifactId>
                <version>1.12.0</version>
            </plugin>
        </plugins>
    </configuration>
</plugin>
```

**PMD Security Rules**
- Free, open source code analyzer
- Configuration in `pom.xml`:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-pmd-plugin</artifactId>
    <version>3.21.0</version>
    <configuration>
        <rulesets>
            <ruleset>/rulesets/java/security.xml</ruleset>
            <ruleset>/rulesets/java/basic.xml</ruleset>
        </rulesets>
        <failOnViolation>true</failOnViolation>
    </configuration>
</plugin>
```

#### Security Testing Commands

```bash
# Run dependency vulnerability scan
mvn dependency-check:check

# Run SpotBugs security analysis
mvn spotbugs:check

# Run PMD security analysis
mvn pmd:check

# Run all security checks
mvn clean verify -Psecurity-checks
```

#### Security Testing in CI/CD
- Run security scans on every commit
- Block merges if high-severity vulnerabilities found
- Generate security reports for review
- Maintain suppression files for false positives

### Performance Testing

**Note**: Performance tests are separate from the standard test pyramid and require dedicated performance test environments.

#### Load Testing
- **Tools**: JMeter or Gatling (both free, open source)
- **Purpose**: Validate system behavior under expected load
- **Scenarios**:
  - Normal load: Expected concurrent users
  - Peak load: Maximum expected concurrent users
  - Sustained load: Extended duration testing (hours)

**JMeter Example Configuration**:
```xml
<!-- Add JMeter plugin to pom.xml -->
<plugin>
    <groupId>com.lazerycode.jmeter</groupId>
    <artifactId>jmeter-maven-plugin</artifactId>
    <version>3.7.0</version>
    <executions>
        <execution>
            <id>performance-test</id>
            <goals>
                <goal>jmeter</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

#### Stress Testing
- **Purpose**: Identify system breaking points
- **Scenarios**:
  - Gradually increase load beyond peak capacity
  - Identify resource bottlenecks
  - Test system recovery after stress

#### Database Performance
- **Query Profiling**: Use PostgreSQL EXPLAIN ANALYZE
- **Connection Pool Monitoring**: Track pool utilization
- **Slow Query Logging**: Identify queries > threshold
- **Index Optimization**: Ensure proper indexing for common queries

#### API Performance Requirements
- **Response Time SLAs**:
  - Read operations: < 200ms (95th percentile)
  - Write operations: < 500ms (95th percentile)
  - Search operations: < 1000ms (95th percentile)
- **Throughput**: Define requests per second targets
- **Error Rate**: < 0.1% under normal load

#### Performance Testing Environment
- **Requirements**:
  - Production-like infrastructure
  - Representative data volumes
  - Isolated from development/QA environments
  - Monitoring and observability tools enabled
- **Data**: Use anonymized production data or realistic synthetic data

#### Performance Test Commands

```bash
# Run JMeter performance tests
mvn jmeter:jmeter -Pperformance-tests

# Run Gatling performance tests
mvn gatling:test -Pperformance-tests

# Generate performance reports
mvn jmeter:results
```

#### Performance Testing Best Practices
- Establish performance baselines
- Run tests regularly (weekly or per release)
- Monitor trends over time
- Test individual endpoints and full workflows
- Include database query performance metrics
- Validate caching strategies
- Test connection pool configurations

#### Performance Test Profile
```xml
<!-- Maven profile for performance testing -->
<profile>
    <id>performance-tests</id>
    <build>
        <plugins>
            <plugin>
                <groupId>com.lazerycode.jmeter</groupId>
                <artifactId>jmeter-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</profile>
```

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

These best practices ensure high-quality, maintainable, and secure Java REST API backend applications, following established KWI patterns and industry standards.