# Code Style Guide

## Context

Code style rules for React/TypeScript frontend and Java backend applications following KWI back-office patterns.

<conditional-block context-check="general-formatting">
IF this General Formatting section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using General Formatting rules already in context"
ELSE:
  READ: The following formatting rules

## General Formatting

### Indentation
- Use 2 spaces for indentation (never tabs) in frontend code
- Use 4 spaces for indentation in Java code
- Maintain consistent indentation throughout files
- Align nested structures for readability

## Frontend Code Style (React/TypeScript)

### Naming Conventions
- **Functions and Variables**: Use camelCase (e.g., `userProfile`, `calculateTotal`)
- **Components**: Use PascalCase (e.g., `UserProfile`, `PaymentProcessor`)
- **Constants**: Use UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT`)
- **Files**: Use kebab-case for files, PascalCase for component files (e.g., `user-service.ts`, `UserCard.tsx`)
- **Interfaces/Types**: Use PascalCase with descriptive names (e.g., `UserProfileProps`, `ApiResponse<T>`)

### TypeScript Specific Rules
- **Strict Configuration**: Use strict TypeScript settings
- **Type Definitions**: Prefer interfaces over types for object shapes
- **Generic Types**: Use meaningful generic parameter names (e.g., `<T>`, `<TData>`, `<TResponse>`)
- **Avoid Any**: Never use `any` type - use `unknown` or proper typing
- **Optional Properties**: Use `?` for optional properties, not `| undefined`

```typescript
// Good - Proper interface definition
interface UserProfileProps {
  user: User;
  onUpdate?: (user: User) => void;
  readonly?: boolean;
}

// Good - Generic with meaningful names
interface ApiResponse<TData> {
  data: TData;
  success: boolean;
  message: string;
}

// Bad - Using any
function processData(data: any) { ... }

// Good - Proper typing
function processData<T>(data: T): ProcessedData<T> { ... }
```

### React Component Style
- **Functional Components**: Always use functional components with hooks
- **Props Interface**: Define props interface above component
- **Default Props**: Use default parameters instead of defaultProps
- **Component Organization**: Export component at bottom of file

```typescript
interface UserCardProps {
  user: User;
  onEdit?: (user: User) => void;
  className?: string;
}

export const UserCard: React.FC<UserCardProps> = ({ 
  user, 
  onEdit,
  className = ''
}) => {
  const handleEdit = useCallback(() => {
    onEdit?.(user);
  }, [user, onEdit]);

  return (
    <Card className={className}>
      <CardHeader>
        <CardTitle>{user.name}</CardTitle>
      </CardHeader>
      <CardContent>
        <Text>{user.email}</Text>
      </CardContent>
      {onEdit && (
        <CardActions>
          <Button onClick={handleEdit}>Edit</Button>
        </CardActions>
      )}
    </Card>
  );
};
```

### Import Organization
- **Order**: React imports, third-party imports, internal imports, relative imports
- **Grouping**: Group imports with blank lines between categories
- **Naming**: Use descriptive import names, avoid default import renaming

```typescript
// React and hooks
import React, { useState, useCallback, useMemo } from 'react';

// Third-party libraries
import { useQuery, useMutation } from '@tanstack/react-query';
import { Card, CardHeader, CardTitle, Button } from '@kwi/ui-components';

// Internal services and types
import { UserService } from '../services/UserService';
import { User, UserFilters } from '../types/User';

// Relative imports
import { UserActions } from './UserActions';
import './UserCard.styles.css';
```

### Redux/State Management Style
- **Slice Naming**: Use descriptive slice names matching domain
- **Action Naming**: Use descriptive action names with present tense
- **State Shape**: Keep state flat and normalized when possible
- **Selectors**: Create memoized selectors for computed state

```typescript
interface UserState {
  users: User[];
  loading: boolean;
  error: string | null;
  filters: UserFilters;
}

export const userSlice = createSlice({
  name: 'users',
  initialState,
  reducers: {
    clearUsers: (state) => {
      state.users = [];
    },
    updateFilters: (state, action: PayloadAction<UserFilters>) => {
      state.filters = action.payload;
    },
    setError: (state, action: PayloadAction<string>) => {
      state.error = action.payload;
      state.loading = false;
    }
  }
});
```

## Backend Code Style (Java)

### Naming Conventions
- **Classes**: Use PascalCase (e.g., `UserService`, `EntityResource`)
- **Methods**: Use camelCase (e.g., `getUserById`, `validateRequest`)
- **Variables**: Use camelCase (e.g., `userList`, `clientId`)
- **Constants**: Use UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`, `DEFAULT_PAGE_SIZE`)
- **Packages**: Use lowercase with dots (e.g., `com.kwi.backoffice.api.service`)

### Class Organization
- **Order**: Constants, fields, constructors, public methods, private methods
- **Annotations**: Use appropriate annotations (@Inject, @ApplicationScoped, etc.)
- **Access Modifiers**: Use most restrictive access modifier possible

```java
@ApplicationScoped
public class UserService {
    
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);
    private static final int DEFAULT_PAGE_SIZE = 25;
    
    @Inject
    private UserDAO userDAO;
    
    @Inject
    private UserValidator userValidator;
    
    // Constructor (if needed)
    public UserService() {}
    
    // Public methods
    @Transactional
    public PagedResponse<User> searchUsers(UserSearchRequest request, String clientId) {
        logger.debug("Searching users with criteria: {}", request);
        
        validateSearchRequest(request);
        
        List<User> users = userDAO.searchUsers(request, clientId);
        long totalCount = userDAO.countUsers(request, clientId);
        
        return createPagedResponse(users, request, totalCount);
    }
    
    // Private methods
    private void validateSearchRequest(UserSearchRequest request) {
        userValidator.validateSearchRequest(request);
    }
    
    private PagedResponse<User> createPagedResponse(List<User> users, 
                                                  UserSearchRequest request, 
                                                  long totalCount) {
        PaginationInfo pagination = new PaginationInfo(
            request.getPage(), 
            request.getSize(), 
            totalCount
        );
        return new PagedResponse<>(users, pagination);
    }
}
```

### Exception Handling
- **Specific Exceptions**: Use specific exception types, not generic Exception
- **Logging**: Log exceptions at appropriate level with context
- **Resource Cleanup**: Always clean up resources in finally blocks or try-with-resources

```java
@GET
@Path("/{userId}")
public Response getUser(@PathParam("userId") String userId,
                       @Context HttpHeaders headers) {
    
    String traceId = UUID.randomUUID().toString();
    logger.info("Getting user - userId: {}, traceId: {}", userId, traceId);
    
    try {
        String clientId = securityAuthenticator.authenticateRequest(headers);
        User user = userService.getUser(userId, clientId);
        
        if (user == null) {
            ApiResponse<?> response = ApiResponse.error("User not found");
            response.setTraceId(traceId);
            return Response.status(Response.Status.NOT_FOUND).entity(response).build();
        }
        
        ApiResponse<User> response = ApiResponse.success(user);
        response.setTraceId(traceId);
        return Response.ok(response).build();
        
    } catch (SecurityException e) {
        logger.error("Authentication failed - traceId: {}", traceId, e);
        ApiResponse<?> response = ApiResponse.error("Unauthorized");
        response.setTraceId(traceId);
        return Response.status(Response.Status.UNAUTHORIZED).entity(response).build();
        
    } catch (Exception e) {
        logger.error("Error getting user - userId: {}, traceId: {}", userId, traceId, e);
        ApiResponse<?> response = ApiResponse.error("Internal server error");
        response.setTraceId(traceId);
        return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(response).build();
    }
}
```

### Database Access Style
- **Connection Management**: Always use try-with-resources or proper cleanup
- **Parameterized Queries**: Always use parameterized queries to prevent SQL injection
- **Transaction Management**: Use @Transactional appropriately
- **Error Handling**: Proper SQLException handling with rollback

```java
public List<User> searchUsers(UserSearchRequest request, String clientId) {
    Connection connection = null;
    try {
        connection = getConnection(clientId);
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT * FROM users WHERE client_id = ?");
        
        List<Object> parameters = new ArrayList<>();
        parameters.add(clientId);
        
        if (StringUtils.isNotBlank(request.getQuery())) {
            sql.append(" AND (name ILIKE ? OR email ILIKE ?)");
            String searchTerm = "%" + request.getQuery() + "%";
            parameters.add(searchTerm);
            parameters.add(searchTerm);
        }
        
        sql.append(" ORDER BY ").append(request.getSortBy())
           .append(" ").append(request.getSortDirection());
        sql.append(" LIMIT ? OFFSET ?");
        parameters.add(request.getSize());
        parameters.add((request.getPage() - 1) * request.getSize());
        
        try (PreparedStatement stmt = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < parameters.size(); i++) {
                stmt.setObject(i + 1, parameters.get(i));
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                return mapResultSet(rs);
            }
        }
        
    } catch (SQLException e) {
        logger.error("Error searching users for client: {}", clientId, e);
        rollbackTransaction(connection);
        throw new RuntimeException("Database error", e);
    } finally {
        closeConnection(connection);
    }
}
```

### String Formatting and Comments
- **String Literals**: Use double quotes for strings
- **String Interpolation**: Use MessageFormat or String.format for complex formatting
- **Comments**: Add brief comments above non-obvious business logic
- **JavaDoc**: Use JavaDoc for public APIs and complex methods

```java
/**
 * Searches for users based on the provided criteria.
 * 
 * @param request the search criteria
 * @param clientId the client identifier for data isolation
 * @return paginated response containing matching users
 * @throws SecurityException if client authentication fails
 * @throws IllegalArgumentException if request validation fails
 */
@Transactional
public PagedResponse<User> searchUsers(UserSearchRequest request, String clientId) {
    // Validate request parameters before processing
    if (request == null) {
        throw new IllegalArgumentException("Search request cannot be null");
    }
    
    logger.debug("Searching users with criteria: {}", request);
    
    // Perform the search operation
    List<User> users = userDAO.searchUsers(request, clientId);
    long totalCount = userDAO.countUsers(request, clientId);
    
    return createPagedResponse(users, request, totalCount);
}
```

### Code Comments
- Add brief comments above non-obvious business logic
- Document complex algorithms or calculations
- Explain the "why" behind implementation choices
- Never remove existing comments unless removing the associated code
- Update comments when modifying code to maintain accuracy
- Keep comments concise and relevant
</conditional-block>

<conditional-block task-condition="html-css-tailwind" context-check="html-css-style">
IF current task involves writing or updating HTML, CSS, or styling:
  IF html-style.md AND css-style.md already in context:
    SKIP: Re-reading these files
    NOTE: "Using HTML/CSS style guides already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get HTML formatting rules from code-style/html-style.md"
        REQUEST: "Get CSS and styling rules from code-style/css-style.md"
        PROCESS: Returned style rules
      ELSE:
        READ the following style guides (only if not already in context):
        - @.agent-os/standards/code-style/html-style.md (if not in context)
        - @.agent-os/standards/code-style/css-style.md (if not in context)
    </context_fetcher_strategy>
ELSE:
  SKIP: HTML/CSS style guides not relevant to current task
</conditional-block>

<conditional-block task-condition="javascript-typescript" context-check="javascript-typescript-style">
IF current task involves writing or updating JavaScript or TypeScript:
  IF javascript-style.md AND typescript-style.md already in context:
    SKIP: Re-reading these files
    NOTE: "Using JavaScript/TypeScript style guides already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get JavaScript style rules from code-style/javascript-style.md"
        REQUEST: "Get TypeScript style rules from code-style/typescript-style.md"
        PROCESS: Returned style rules
      ELSE:
        READ the following style guides (only if not already in context):
        - @.agent-os/standards/code-style/javascript-style.md (if not in context)
        - @.agent-os/standards/code-style/typescript-style.md (if not in context)
    </context_fetcher_strategy>
ELSE:
  SKIP: JavaScript/TypeScript style guides not relevant to current task
</conditional-block>

## ESLint and Prettier Configuration

### Frontend Linting Configuration
```json
{
  "extends": [
    "@typescript-eslint/recommended",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended",
    "prettier"
  ],
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unused-vars": "error",
    "react/prop-types": "off",
    "react/react-in-jsx-scope": "off",
    "react-hooks/rules-of-hooks": "error",
    "react-hooks/exhaustive-deps": "warn"
  }
}
```

### Prettier Configuration
```json
{
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "semi": true,
  "singleQuote": true,
  "quoteProps": "as-needed",
  "trailingComma": "es5",
  "bracketSpacing": true,
  "bracketSameLine": false,
  "arrowParens": "always"
}
```

## Java Formatting (Backend)

### IDE Configuration
- **Indentation**: 4 spaces (never tabs)
- **Line Length**: 120 characters maximum
- **Braces**: Always use braces, opening brace on same line
- **Imports**: Organize imports, remove unused imports

### Checkstyle Configuration (Optional)
```xml
<!-- checkstyle.xml -->
<module name="Checker">
    <module name="TreeWalker">
        <module name="Indentation">
            <property name="basicOffset" value="4"/>
        </module>
        <module name="LineLength">
            <property name="max" value="120"/>
        </module>
        <module name="LeftCurly"/>
        <module name="RightCurly"/>
        <module name="UnusedImports"/>
        <module name="RedundantImport"/>
    </module>
</module>
```

This code style guide ensures consistent, readable, and maintainable code across React/TypeScript frontend and Java backend applications, following KWI patterns and industry best practices.