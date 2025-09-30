# Java Style Guide

## Java-Specific Rules

### Naming Conventions
- **Classes**: Use PascalCase (e.g., `UserService`, `EntityResource`)
- **Methods**: Use camelCase (e.g., `getUserById`, `validateRequest`)
- **Variables**: Use camelCase (e.g., `userList`, `clientId`)
- **Constants**: Use UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`, `DEFAULT_PAGE_SIZE`)
- **Packages**: Use lowercase with dots (e.g., `com.kwi.backoffice.api.service`)

### Class Organization
- **Order**: Constants, fields, constructors, public methods, private methods
- **Access Modifiers**: Use most restrictive access modifier possible
- **Final fields**: Mark immutable fields as final

```java
@ApplicationScoped
public class UserService {
    
    // Constants first
    private static final Logger LOGGER = LoggerFactory.getLogger(UserService.class);
    private static final int DEFAULT_PAGE_SIZE = 25;
    private static final String DEFAULT_SORT_FIELD = "createdDate";
    
    // Instance fields
    private final UserDAO userDAO;
    private final UserValidator userValidator;
    
    // Constructor
    @Inject
    public UserService(UserDAO userDAO, UserValidator userValidator) {
        this.userDAO = Objects.requireNonNull(userDAO, "UserDAO cannot be null");
        this.userValidator = Objects.requireNonNull(userValidator, "UserValidator cannot be null");
    }
    
    // Public methods
    @Transactional
    public PagedResponse<User> searchUsers(UserSearchRequest request, String clientId) {
        validateSearchRequest(request, clientId);
        
        List<User> users = userDAO.searchUsers(request, clientId);
        long totalCount = userDAO.countUsers(request, clientId);
        
        return createPagedResponse(users, request, totalCount);
    }
    
    // Private methods
    private void validateSearchRequest(UserSearchRequest request, String clientId) {
        Objects.requireNonNull(request, "Search request cannot be null");
        Objects.requireNonNull(clientId, "Client ID cannot be null");
        
        userValidator.validateSearchRequest(request);
    }
}
```

### Method Design
- **Single Responsibility**: Each method should have one clear purpose
- **Parameter Validation**: Always validate method parameters
- **Return Types**: Use specific return types, avoid raw types
- **Method Length**: Keep methods under 30 lines when possible

```java
// Good - Clear method with validation
@Transactional
public User createUser(User user, String clientId) {
    Objects.requireNonNull(user, "User cannot be null");
    Objects.requireNonNull(clientId, "Client ID cannot be null");
    
    validateUserForCreation(user);
    
    if (userDAO.existsByEmail(user.getEmail(), clientId)) {
        throw new IllegalArgumentException("User with email '" + user.getEmail() + "' already exists");
    }
    
    User newUser = buildUserForCreation(user, clientId);
    User createdUser = userDAO.create(newUser, clientId);
    
    LOGGER.info("User created successfully - id: {}, email: {}", 
               createdUser.getId(), createdUser.getEmail());
    
    return createdUser;
}

// Good - Helper methods for clarity
private void validateUserForCreation(User user) {
    userValidator.validateUser(user);
    
    if (StringUtils.isBlank(user.getEmail())) {
        throw new IllegalArgumentException("User email is required");
    }
    
    if (StringUtils.isBlank(user.getName())) {
        throw new IllegalArgumentException("User name is required");
    }
}

private User buildUserForCreation(User user, String clientId) {
    LocalDateTime now = LocalDateTime.now();
    String userId = generateUserId();
    
    return User.builder()
        .id(userId)
        .name(user.getName())
        .email(user.getEmail())
        .status(UserStatus.ACTIVE)
        .createdDate(now)
        .lastModifiedDate(now)
        .createdBy(clientId)
        .lastModifiedBy(clientId)
        .build();
}
```

### Exception Handling
- **Specific Exceptions**: Use specific exception types
- **Resource Cleanup**: Always clean up resources properly
- **Logging Context**: Include relevant context in exception logs

```java
@GET
@Path("/{userId}")
public Response getUser(@PathParam("userId") String userId,
                       @Context HttpHeaders headers) {
    
    String traceId = UUID.randomUUID().toString();
    LOGGER.info("Getting user - userId: {}, traceId: {}", userId, traceId);
    
    try {
        // Validate input
        if (StringUtils.isBlank(userId)) {
            throw new IllegalArgumentException("User ID cannot be empty");
        }
        
        // Authenticate request
        String clientId = securityAuthenticator.authenticateRequest(headers);
        
        // Perform operation
        User user = userService.getUser(userId, clientId);
        
        if (user == null) {
            LOGGER.warn("User not found - userId: {}, clientId: {}, traceId: {}", 
                       userId, clientId, traceId);
            return createNotFoundResponse(traceId);
        }
        
        ApiResponse<User> response = ApiResponse.success(user);
        response.setTraceId(traceId);
        
        LOGGER.debug("User retrieved successfully - userId: {}, traceId: {}", userId, traceId);
        return Response.ok(response).build();
        
    } catch (SecurityException e) {
        LOGGER.error("Authentication failed - userId: {}, traceId: {}", userId, traceId, e);
        return createUnauthorizedResponse(traceId);
        
    } catch (IllegalArgumentException e) {
        LOGGER.error("Invalid request - userId: {}, traceId: {}", userId, traceId, e);
        return createBadRequestResponse(e.getMessage(), traceId);
        
    } catch (Exception e) {
        LOGGER.error("Unexpected error - userId: {}, traceId: {}", userId, traceId, e);
        return createInternalErrorResponse(traceId);
    }
}

// Helper methods for response creation
private Response createNotFoundResponse(String traceId) {
    ApiResponse<?> response = ApiResponse.error("User not found");
    response.setTraceId(traceId);
    return Response.status(Response.Status.NOT_FOUND).entity(response).build();
}
```

### Database Access Patterns
- **Connection Management**: Use try-with-resources or proper cleanup
- **Parameterized Queries**: Always use parameterized queries
- **Transaction Handling**: Proper transaction management with rollback

```java
public List<User> searchUsers(UserSearchRequest request, String clientId) {
    Objects.requireNonNull(request, "Search request cannot be null");
    Objects.requireNonNull(clientId, "Client ID cannot be null");
    
    Connection connection = null;
    try {
        connection = getConnection(clientId);
        
        String sql = buildSearchQuery(request);
        List<Object> parameters = buildQueryParameters(request, clientId);
        
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            setQueryParameters(stmt, parameters);
            
            try (ResultSet rs = stmt.executeQuery()) {
                List<User> users = mapResultSetToUsers(rs);
                LOGGER.debug("Found {} users for client: {}", users.size(), clientId);
                return users;
            }
        }
        
    } catch (SQLException e) {
        LOGGER.error("Database error searching users for client: {}", clientId, e);
        rollbackTransaction(connection);
        throw new RuntimeException("Failed to search users", e);
    } finally {
        closeConnection(connection);
    }
}

// Helper methods for query building
private String buildSearchQuery(UserSearchRequest request) {
    StringBuilder sql = new StringBuilder();
    sql.append("SELECT * FROM users WHERE client_id = ?");
    
    if (StringUtils.isNotBlank(request.getQuery())) {
        sql.append(" AND (name ILIKE ? OR email ILIKE ?)");
    }
    
    if (request.getStatus() != null) {
        sql.append(" AND status = ?");
    }
    
    sql.append(" ORDER BY ").append(request.getSortBy())
       .append(" ").append(request.getSortDirection());
    sql.append(" LIMIT ? OFFSET ?");
    
    return sql.toString();
}

private List<Object> buildQueryParameters(UserSearchRequest request, String clientId) {
    List<Object> parameters = new ArrayList<>();
    parameters.add(clientId);
    
    if (StringUtils.isNotBlank(request.getQuery())) {
        String searchTerm = "%" + request.getQuery().toLowerCase() + "%";
        parameters.add(searchTerm);
        parameters.add(searchTerm);
    }
    
    if (request.getStatus() != null) {
        parameters.add(request.getStatus().name());
    }
    
    parameters.add(request.getSize());
    parameters.add((request.getPage() - 1) * request.getSize());
    
    return parameters;
}
```

### Bean Validation
- **Annotation Usage**: Use javax.validation annotations appropriately
- **Custom Validators**: Create custom validators for business rules
- **Validation Groups**: Use validation groups for different scenarios

```java
public class User {
    
    @NotNull(message = "User ID cannot be null")
    @Size(max = 20, message = "User ID cannot exceed 20 characters")
    private String id;
    
    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    private String name;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    @Size(max = 255, message = "Email cannot exceed 255 characters")
    private String email;
    
    @NotNull(message = "Status is required")
    private UserStatus status;
    
    @Past(message = "Created date must be in the past")
    private LocalDateTime createdDate;
    
    // Constructors, getters, setters...
}

// Custom validator
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = StrongPasswordValidator.class)
public @interface StrongPassword {
    String message() default "Password must contain at least 8 characters with uppercase, lowercase, and numbers";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}

public class StrongPasswordValidator implements ConstraintValidator<StrongPassword, String> {
    
    @Override
    public boolean isValid(String password, ConstraintValidatorContext context) {
        if (password == null) {
            return false;
        }
        
        return password.length() >= 8 &&
               password.matches(".*[A-Z].*") &&
               password.matches(".*[a-z].*") &&
               password.matches(".*\\d.*");
    }
}
```

### Logging Best Practices
- **Appropriate Levels**: Use correct logging levels (DEBUG, INFO, WARN, ERROR)
- **Structured Messages**: Include relevant context in log messages
- **Performance**: Use parameterized logging to avoid string concatenation

```java
public class UserService {
    
    private static final Logger LOGGER = LoggerFactory.getLogger(UserService.class);
    
    @Transactional
    public User updateUser(String userId, User updatedUser, String clientId) {
        LOGGER.info("Updating user - userId: {}, clientId: {}", userId, clientId);
        
        try {
            User existingUser = userDAO.findById(userId, clientId);
            if (existingUser == null) {
                LOGGER.warn("User not found for update - userId: {}, clientId: {}", userId, clientId);
                throw new IllegalArgumentException("User not found: " + userId);
            }
            
            LOGGER.debug("Existing user found - userId: {}, version: {}", 
                        existingUser.getId(), existingUser.getVersion());
            
            User userToUpdate = mergeUserUpdates(existingUser, updatedUser, clientId);
            User savedUser = userDAO.update(userToUpdate, clientId);
            
            LOGGER.info("User updated successfully - userId: {}, version: {}", 
                       savedUser.getId(), savedUser.getVersion());
            
            return savedUser;
            
        } catch (Exception e) {
            LOGGER.error("Failed to update user - userId: {}, clientId: {}", userId, clientId, e);
            throw e;
        }
    }
}
```

### Builder Pattern
- **Complex Objects**: Use builder pattern for objects with many fields
- **Immutable Objects**: Create immutable objects when possible
- **Validation**: Validate in builder's build() method

```java
public class User {
    private final String id;
    private final String name;
    private final String email;
    private final UserStatus status;
    private final LocalDateTime createdDate;
    private final LocalDateTime lastModifiedDate;
    
    private User(Builder builder) {
        this.id = Objects.requireNonNull(builder.id, "ID cannot be null");
        this.name = Objects.requireNonNull(builder.name, "Name cannot be null");
        this.email = Objects.requireNonNull(builder.email, "Email cannot be null");
        this.status = Objects.requireNonNull(builder.status, "Status cannot be null");
        this.createdDate = Objects.requireNonNull(builder.createdDate, "Created date cannot be null");
        this.lastModifiedDate = Objects.requireNonNull(builder.lastModifiedDate, "Modified date cannot be null");
    }
    
    public static Builder builder() {
        return new Builder();
    }
    
    public static class Builder {
        private String id;
        private String name;
        private String email;
        private UserStatus status;
        private LocalDateTime createdDate;
        private LocalDateTime lastModifiedDate;
        
        public Builder id(String id) {
            this.id = id;
            return this;
        }
        
        public Builder name(String name) {
            this.name = name;
            return this;
        }
        
        public Builder email(String email) {
            this.email = email;
            return this;
        }
        
        public Builder status(UserStatus status) {
            this.status = status;
            return this;
        }
        
        public Builder createdDate(LocalDateTime createdDate) {
            this.createdDate = createdDate;
            return this;
        }
        
        public Builder lastModifiedDate(LocalDateTime lastModifiedDate) {
            this.lastModifiedDate = lastModifiedDate;
            return this;
        }
        
        public User build() {
            // Validation can be added here
            if (StringUtils.isBlank(id)) {
                throw new IllegalArgumentException("User ID is required");
            }
            if (StringUtils.isBlank(name)) {
                throw new IllegalArgumentException("User name is required");
            }
            
            return new User(this);
        }
    }
    
    // Getters only (immutable)
    public String getId() { return id; }
    public String getName() { return name; }
    public String getEmail() { return email; }
    // ... other getters
}
```

These Java style guidelines ensure clean, readable, and maintainable code following established Java best practices and KWI patterns.