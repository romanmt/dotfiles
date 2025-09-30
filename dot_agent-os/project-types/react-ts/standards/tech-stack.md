# Tech Stack

## Context

Tech stack specifications for React/TypeScript frontend applications following KWI back-office patterns and micro-frontend architecture.

## Frontend Stack

### Core Framework
- **Framework**: React 18.3.1 with TypeScript
- **Build Tool**: Webpack 5 with SystemJS module federation
- **Module Format**: SystemJS for micro-frontend integration
- **Node Version**: 18+ (managed via asdf)
- **Package Manager**: npm

### State Management
- **Client State**: Redux Toolkit 2.x with Redux Persist 6.x
- **Server State**: React Query/TanStack Query for API state
- **Form State**: React Hook Form for form management
- **Local State**: useState/useReducer for component state

### UI and Styling
- **Design System**: @kwi/ui-components (KWI internal design system)
- **Theme**: BackOfficeTheme from @kwi/ui-components
- **Icons**: Design system icons or Font Awesome
- **Responsive Design**: Built into @kwi/ui-components
- **CSS**: CSS-in-JS via @kwi/ui-components or CSS modules

### Routing and Navigation
- **Router**: React Router DOM 6.x
- **Integration**: SystemJS module coordination with host application
- **Lazy Loading**: React.lazy for code splitting
- **Navigation**: Cross-origin communication for navigation events

### Development Tools
- **TypeScript**: 5.x (strict configuration)
- **Linting**: ESLint with TypeScript rules
- **Formatting**: Prettier integration
- **Testing**: React Testing Library, Jest, Cypress
- **Dev Server**: Webpack Dev Server with proxy configuration

### Integration Libraries
- **Authentication**: ClientInfoProvider from @kwi/ui-components
- **Internationalization**: TranslationsProvider with multi-language support
- **Configuration**: ConfigurationProvider for runtime configuration
- **Alerts**: AlertProvider for notifications
- **Error Handling**: ErrorProvider for global error handling
- **Analytics**: TelemetryProvider for usage tracking

### Build and Deployment
- **Build Output**: SystemJS module (`app-name.js`)
- **Asset Optimization**: Webpack 5 optimization and minification
- **Source Maps**: Generated for debugging in production
- **CDN Deployment**: Static asset deployment to CDN
- **Cache Busting**: Version-based cache management

## Integration Architecture

### Micro-Frontend Integration
- **Host Environment**: Embedded in existing JSP monolith
- **Module Loading**: SystemJS importmap registration
- **Shared Dependencies**: React and ReactDOM externalized
- **Context Sharing**: Authentication and theme context from host
- **Communication**: Cross-origin messaging for navigation

### API Integration
- **Protocol**: RESTful HTTP/HTTPS
- **Format**: JSON request/response bodies
- **Authentication**: Basic Auth headers
- **Error Handling**: Standardized ApiResponse wrapper format
- **Versioning**: URL path versioning (`/v1/`)
- **Documentation**: OpenAPI/Swagger generated documentation

### Development Environment Integration
- **Frontend Dev Server**: Webpack Dev Server on port 8002
- **Backend API**: External REST API services
- **Proxy Configuration**: Frontend proxy to backend for API calls
- **Hot Reloading**: Webpack HMR for frontend development

## Configuration Management

### Frontend Configuration
- **Environment Variables**: React environment variables with REACT_APP_ prefix
- **Runtime Configuration**: ConfigurationProvider with database-backed properties
- **Build Configuration**: Webpack environment-specific configurations
- **SystemJS Configuration**: Import map management and versioning

```javascript
// Development environment variables
REACT_APP_USE_PROXY=true
REACT_APP_AUTH_HEADER=Basic <credentials>
REACT_APP_PROXY_PATH=/common-bo-call/BackOfficeCallServlet
ENVIRONMENT=development
PUBLIC_PATH=/app-name/
```

## Deployment Architecture

### Frontend Deployment
- **Static Assets**: CDN deployment with versioned URLs
- **Module Registration**: Database registration of SystemJS modules
- **Cache Strategy**: Long-term caching with version-based invalidation
- **Load Balancer**: Nginx with HTTPS termination

### CI/CD Pipeline
- **Source Control**: Git with feature branch workflow
- **Build**: GitLab CI/CD
- **Testing**: Automated unit, integration, and E2E tests
- **Deployment**: Blue-green deployment strategy
- **Rollback**: Automated rollback procedures

## Development Tools and Workflow

### Frontend Development
```json
{
  "scripts": {
    "dev": "webpack serve --mode development",
    "build:dev": "webpack --mode development",
    "build:prod": "webpack --mode production",
    "test": "jest",
    "test:coverage": "jest --coverage",
    "lint": "eslint src --ext .ts,.tsx",
    "type-check": "tsc --noEmit"
  }
}
```

### Common Development Commands
```bash
# Frontend development
cd frontend && npm install && npm run dev

# Testing
npm run test:coverage  # Frontend tests
npm run test:e2e      # End-to-end tests

# Build for production
npm run build:prod
```

## Performance and Scalability

### Frontend Performance
- **Code Splitting**: Route-based and component-based lazy loading
- **Bundle Optimization**: Webpack optimization and tree shaking
- **Caching**: Service worker caching and HTTP cache headers
- **Virtual Scrolling**: For large data sets
- **Memoization**: React.memo, useMemo, and useCallback optimization

### Monitoring and Observability
- **Health Checks**: Application health status endpoints
- **Metrics**: Application metrics and performance monitoring
- **Logging**: Structured logging with trace correlation
- **Error Tracking**: Comprehensive error logging and alerting

This tech stack provides a comprehensive foundation for building scalable, maintainable React/TypeScript frontend applications, following established KWI patterns and industry best practices.