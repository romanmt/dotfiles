# Development Best Practices

## Context

Global development guidelines for Agent OS projects.

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

### Optimize for Readability
- Prioritize code clarity over micro-optimizations
- Write self-documenting code with clear variable names
- Add comments for "why" not "what"

### DRY (Don't Repeat Yourself)
- Extract repeated business logic to private methods
- Extract repeated UI markup to reusable components
- Create utility functions for common operations

### File Structure
- Keep files focused on a single responsibility
- Group related functionality together
- Use consistent naming conventions

### Migrations
- Migrations should always include and up and a down function
- never use models in migrations, stick to SQL

### Structure
- Use onion architecture. 
- Separate business logic from other code
- Implement business logic as pure functions with no sideffects
- Avoid mutable state

### Performance
- Write code that takes advantage of mutlicore architecture
- Leverage concurrent programming
- Make sure that code is efficient

### Storage
- Where possible, manage data in memory using genservers and write to the database using a debounced scheme. 
- The database should be primarily used for state restore after server restarts or crashes. 

### Stability
- Leverage OPT features like supervisors to create product stability

### Testing
- Add tests for every feature.
- Maintain a healthy test pyramid. 70% unit tests, 20% integration tests, 10% e2e tests.


</conditional-block>

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
- Select the most popular and actively maintained option
- Check the library's GitHub repository for:
  - Recent commits (within last 6 months)
  - Active issue resolution
  - Number of stars/downloads
  - Clear documentation
</conditional-block>
