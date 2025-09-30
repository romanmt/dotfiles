# Code Style Guide

## Context

Code style guidelines for React/TypeScript frontend development following KWI back-office patterns and industry best practices.

## General Code Style

### Formatting
- **Indentation**: 2 spaces (no tabs)
- **Line Length**: Maximum 100 characters
- **Braces**: K&R style (opening brace on same line)
- **Whitespace**: One blank line between functions, consistent spacing

### Comments
- **Purpose**: Explain "why", not "what"
- **JSDoc**: Use for public functions and complex logic
- **Inline Comments**: Use sparingly, only when code intent is not obvious
- **TODO Comments**: Include issue reference when applicable

## TypeScript-Specific Guidelines

For detailed TypeScript coding standards, see [typescript-style.md](code-style/typescript-style.md)

Key highlights:
- Use interfaces over type aliases for object shapes
- Prefer strict TypeScript configuration, avoid `any`
- Use meaningful generic parameter names
- Implement proper type guards for runtime type checking
- Use utility types (Partial, Pick, Omit) appropriately
- Proper event handler typing for React components

## Code Organization

### File Structure
```
src/
├── ui/              # UI components and pages
├── state/           # Redux store and slices
├── services/        # API service layer
├── router/          # Route configuration
├── utils/           # Utility functions
├── types/           # TypeScript type definitions
└── i18n/            # Internationalization
```

### Component Organization
1. Imports (React, libraries, components, types, styles)
2. Type definitions and interfaces
3. Component definition
4. Hooks and state
5. Event handlers
6. Render logic
7. Export

## Best Practices

### Component Design
- Use functional components with hooks
- Implement proper TypeScript prop types
- Follow single responsibility principle
- Use @kwi/ui-components for consistency

### State Management
- Server state via React Query
- Client state via Redux Toolkit
- Local component state with useState/useReducer
- Implement Redux Persist for persistence

### Performance
- Use React.memo for expensive components
- Implement useMemo and useCallback appropriately
- Code splitting with lazy loading
- Virtual scrolling for large datasets

### Testing
- Write unit tests for all components
- Test user interactions, not implementation
- Mock external dependencies with MSW
- Maintain >80% code coverage

These style guidelines ensure consistent, maintainable React/TypeScript code following KWI patterns and industry standards.