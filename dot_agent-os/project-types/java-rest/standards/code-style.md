# Code Style Guide

## Context

Code style guidelines for Java REST API backend development following KWI back-office patterns and industry best practices.

## General Code Style

### Formatting
- **Indentation**: 4 spaces (no tabs)
- **Line Length**: Maximum 120 characters
- **Braces**: K&R style (opening brace on same line)
- **Whitespace**: One blank line between methods, two between classes

### Comments
- **Purpose**: Explain "why", not "what"
- **Javadoc**: Required for all public classes and methods
- **Inline Comments**: Use sparingly, only when code intent is not obvious
- **TODO Comments**: Include issue reference when applicable

## Java-Specific Guidelines

For detailed Java coding standards, see [java-style.md](code-style/java-style.md)

Key highlights:
- Use PascalCase for classes, camelCase for methods/variables
- Follow layered architecture: Resource → Service → DAO
- Implement proper exception handling with trace IDs
- Use parameterized queries for database access
- Follow bean validation patterns with javax.validation
- Use SLF4J for structured logging

## Code Organization

### Package Structure
```
com.kwi.backoffice.api.appname/
├── application/      # JAX-RS configuration
├── model/           # Domain models
├── request/         # Request DTOs
├── response/        # Response DTOs
├── resource/        # REST endpoints
├── service/         # Business logic
├── dao/             # Data access
└── util/            # Utilities
```

### Class Organization
1. Constants
2. Instance fields
3. Constructors
4. Public methods
5. Private methods

## Best Practices

### Resource Layer
- Use JAX-RS annotations consistently
- Implement comprehensive error handling
- Generate trace IDs for all requests
- Validate authentication on all endpoints

### Service Layer
- Keep business logic in service classes
- Use @Transactional for database operations
- Validate inputs thoroughly
- Implement proper audit trail fields

### Data Access Layer
- Extend BaseDAO for common functionality
- Use try-with-resources for connections
- Implement parameterized queries only
- Handle transactions with proper rollback

### Security
- Always authenticate requests
- Use client-specific database connections
- Log security events
- Validate and sanitize all inputs

### Testing
- Write unit tests for all business logic
- Use Mockito for mocking dependencies
- Test error scenarios and edge cases
- Maintain >80% code coverage

These style guidelines ensure consistent, maintainable Java REST API code following KWI patterns and industry standards.