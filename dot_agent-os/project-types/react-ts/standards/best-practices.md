# Development Best Practices

## Context

Development guidelines for React/TypeScript frontend applications following KWI back-office patterns and micro-frontend architecture.

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

#### Test Pyramid
- **Maintain a healthy test pyramid**: 70% unit tests, 20% integration tests, 10% end-to-end tests
- **Coverage requirements**: Maintain ≥80% code coverage overall
- **Independent execution**: Each test type should be runnable independently
- **Self-contained**: Each test suite sets up required mocks/environments
- **Note**: Security and performance tests are separate categories (see dedicated sections below)

#### Test Commands Structure

```bash
# 1. Unit tests only
npm run test:unit

# 2. Integration tests only
npm run test:integration

# 3. E2E tests only
npm run test:e2e

# 4. All functional tests (unit + integration + e2e)
npm run test

# 5. Security tests (separate category)
npm run security:check

# 6. Performance tests (separate category, production-like environment)
npm run performance:test
```

**Package.json scripts**:
```json
{
  "scripts": {
    "test": "jest",
    "test:unit": "jest --testPathPattern='.*\\.test\\.(ts|tsx)$'",
    "test:integration": "jest --testPathPattern='.*\\.integration\\.test\\.(ts|tsx)$'",
    "test:e2e": "cypress run",
    "test:coverage": "jest --coverage",
    "security:check": "npm audit && npm run lint:security",
    "performance:test": "npm run build && npm run lighthouse && npm run analyze"
  }
}
```

#### Unit Testing
- Use React Testing Library for component testing
- Test user interactions, not implementation details
- Mock external dependencies appropriately
- Fast execution with no external dependencies

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

### Security Testing

#### OWASP Top 10 Compliance
- **Requirement**: All frontend applications must be tested for OWASP Top 10 vulnerabilities
- Test for frontend-specific security risks:
  - A01: Broken Access Control - Verify proper authorization checks
  - A02: Cryptographic Failures - Secure data transmission (HTTPS only)
  - A03: Injection - XSS prevention, input sanitization
  - A04: Insecure Design - Security by design principles
  - A05: Security Misconfiguration - CSP headers, secure cookies
  - A06: Vulnerable and Outdated Components - Dependency scanning
  - A07: Identification and Authentication Failures - Session management
  - A08: Software and Data Integrity Failures - Subresource integrity
  - A09: Security Logging and Monitoring Failures - Error tracking
  - A10: Server-Side Request Forgery (SSRF) - API request validation

#### Dependency Vulnerability Scanning
- **Tool**: npm audit (free, built into npm)
- **Commands**:

```bash
# Check for vulnerabilities
npm audit

# Automatically fix vulnerabilities
npm audit fix

# Review audit report
npm audit --json > audit-report.json
```

- **Integration**: Run in CI/CD pipeline on every build
- **Action**: Fail builds for high/critical vulnerabilities
- **Best Practices**:
  - Run `npm audit` before every commit
  - Keep dependencies up to date
  - Review security advisories regularly
  - Use `package-lock.json` for reproducible builds

#### Static Application Security Testing (SAST)

**ESLint Security Plugins** (free, open source)

Install security-focused ESLint plugins:
```bash
npm install --save-dev eslint-plugin-security eslint-plugin-no-unsanitized
```

**ESLint Configuration** (`.eslintrc.js`):
```javascript
module.exports = {
  extends: [
    'eslint:recommended',
    'plugin:react/recommended',
    'plugin:@typescript-eslint/recommended',
  ],
  plugins: [
    'security',
    'no-unsanitized',
  ],
  rules: {
    // Security rules
    'security/detect-object-injection': 'warn',
    'security/detect-non-literal-regexp': 'warn',
    'security/detect-unsafe-regex': 'error',
    'security/detect-buffer-noassert': 'error',
    'security/detect-child-process': 'error',
    'security/detect-disable-mustache-escape': 'error',
    'security/detect-eval-with-expression': 'error',
    'security/detect-no-csrf-before-method-override': 'error',
    'security/detect-possible-timing-attacks': 'warn',

    // XSS prevention
    'no-unsanitized/method': 'error',
    'no-unsanitized/property': 'error',

    // React security
    'react/no-danger': 'error',
    'react/no-danger-with-children': 'error',
  },
};
```

#### Content Security Policy (CSP)
- **Implementation**: Configure CSP headers in application
- **Example CSP**:
```javascript
const cspConfig = {
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'", "'unsafe-inline'"], // Minimize unsafe-inline
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", "data:", "https:"],
    connectSrc: ["'self'", "https://api.example.com"],
    fontSrc: ["'self'"],
    objectSrc: ["'none'"],
    mediaSrc: ["'self'"],
    frameSrc: ["'none'"],
  },
};
```

#### XSS Prevention
- **Input Sanitization**: Always sanitize user input before rendering
- **DOMPurify**: Use for HTML sanitization when needed
```typescript
import DOMPurify from 'dompurify';

const sanitizeHTML = (dirty: string): string => {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong'],
    ALLOWED_ATTR: []
  });
};
```
- **Avoid**: `dangerouslySetInnerHTML` unless absolutely necessary
- **React Safe Rendering**: Use React's built-in XSS protection

#### Security Testing Commands

```bash
# Run dependency vulnerability scan
npm audit

# Run security-focused linting
npm run lint:security

# Run all security checks (add to package.json)
npm run security:check
```

**Package.json scripts**:
```json
{
  "scripts": {
    "lint:security": "eslint --ext .ts,.tsx src --config .eslintrc.security.js",
    "security:check": "npm audit && npm run lint:security",
    "security:fix": "npm audit fix && npm run lint:security --fix"
  }
}
```

#### Security Testing in CI/CD
- Run `npm audit` on every commit
- Run security linting as part of PR checks
- Block merges if critical vulnerabilities found
- Generate security reports for review
- Monitor dependency updates for security patches

#### Additional Security Best Practices
- **Authentication**: Never store tokens in localStorage (use httpOnly cookies)
- **API Keys**: Never commit API keys or secrets to version control
- **HTTPS Only**: Enforce HTTPS in production
- **Secure Headers**: Implement security headers (X-Frame-Options, X-Content-Type-Options, etc.)
- **CORS**: Configure CORS policies appropriately
- **Error Messages**: Don't expose sensitive information in error messages

### Performance Testing

**Note**: Performance tests are separate from the standard test pyramid and require production-like environments.

#### Lighthouse CI
- **Tool**: Lighthouse CI (free, open source by Google)
- **Purpose**: Automated performance, accessibility, and best practices auditing
- **Installation**:

```bash
npm install --save-dev @lhci/cli
```

**Lighthouse CI Configuration** (`lighthouserc.js`):
```javascript
module.exports = {
  ci: {
    collect: {
      startServerCommand: 'npm run start',
      url: ['http://localhost:3000'],
      numberOfRuns: 3,
    },
    assert: {
      preset: 'lighthouse:recommended',
      assertions: {
        'categories:performance': ['error', { minScore: 0.9 }],
        'categories:accessibility': ['error', { minScore: 0.9 }],
        'categories:best-practices': ['error', { minScore: 0.9 }],
        'categories:seo': ['error', { minScore: 0.8 }],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};
```

#### Core Web Vitals
- **Metrics to Monitor**:
  - **LCP (Largest Contentful Paint)**: < 2.5s (good)
  - **FID (First Input Delay)**: < 100ms (good)
  - **CLS (Cumulative Layout Shift)**: < 0.1 (good)
  - **FCP (First Contentful Paint)**: < 1.8s (good)
  - **TTI (Time to Interactive)**: < 3.8s (good)

**Testing Core Web Vitals**:
```javascript
// Use web-vitals library
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

function sendToAnalytics(metric) {
  console.log(metric);
  // Send to analytics endpoint
}

getCLS(sendToAnalytics);
getFID(sendToAnalytics);
getFCP(sendToAnalytics);
getLCP(sendToAnalytics);
getTTFB(sendToAnalytics);
```

#### Bundle Size Analysis
- **Tool**: webpack-bundle-analyzer (free)
- **Installation**:

```bash
npm install --save-dev webpack-bundle-analyzer
```

**Webpack Configuration**:
```javascript
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;

module.exports = {
  plugins: [
    new BundleAnalyzerPlugin({
      analyzerMode: 'static',
      openAnalyzer: false,
      reportFilename: 'bundle-report.html',
    }),
  ],
};
```

**Bundle Size Limits**:
- Main bundle: < 250KB (gzipped)
- Individual chunks: < 100KB (gzipped)
- Total initial load: < 500KB (gzipped)

#### Rendering Performance
- **Component Performance**: Use React DevTools Profiler
- **Unnecessary Re-renders**: Identify with React DevTools
- **Memoization**: Verify proper use of React.memo, useMemo, useCallback
- **Code Splitting**: Ensure routes are lazy-loaded
- **Virtual Scrolling**: Verify for large lists (>100 items)

#### Performance Acceptance Criteria
- **Lighthouse Scores**:
  - Performance: ≥ 90
  - Accessibility: ≥ 90
  - Best Practices: ≥ 90
  - SEO: ≥ 80
- **Load Time**: < 3s on 3G connection
- **Time to Interactive**: < 5s
- **Bundle Size**: Within defined limits

#### Performance Testing Environment
- **Requirements**:
  - Production build (`npm run build`)
  - Production-like server configuration
  - Realistic network throttling (3G/4G simulation)
  - Representative data volumes
  - CDN simulation if applicable
- **Network Conditions**: Test on various network speeds (Fast 3G, Slow 3G, 4G)

#### Performance Test Commands

```bash
# Run Lighthouse CI
npm run lighthouse

# Analyze bundle size
npm run analyze

# Run all performance tests
npm run performance:test
```

**Package.json scripts**:
```json
{
  "scripts": {
    "lighthouse": "lhci autorun",
    "analyze": "webpack --profile --json > stats.json && webpack-bundle-analyzer stats.json",
    "performance:test": "npm run build && npm run lighthouse && npm run analyze"
  }
}
```

#### Performance Testing Best Practices
- Run performance tests on every release
- Establish performance budgets for bundle sizes
- Monitor performance metrics in production
- Test on various devices (desktop, mobile, tablet)
- Use real user monitoring (RUM) in production
- Set up performance regression alerts
- Test with and without caching
- Profile component render times regularly

#### Performance Monitoring in Production
- Use TelemetryProvider from @kwi/ui-components for metrics collection
- Track Core Web Vitals in production
- Monitor bundle sizes over time
- Set up alerts for performance degradation
- Analyze user experience metrics by device/browser

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

#### Evaluation Criteria
- Select the most popular and actively maintained option
- Check the library's repository for:
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
- Follow principle of least privilege for API access
- Regular security audits and dependency updates

These best practices ensure high-quality, maintainable, and secure React/TypeScript frontend applications, following established KWI patterns and industry standards.