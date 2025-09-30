# System Architecture

## Overview

This document defines the architectural patterns and design principles for building scalable, maintainable React with TypeScript frontend applications, following KWI back-office patterns and micro-frontend architecture.

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
│                    Backend REST APIs                        │
│                   (External Services)                       │
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

## Best Practices

### Frontend Best Practices

1. **Component Design**: Use @kwi/ui-components design system consistently
2. **State Management**: Server state via React Query, client state via Redux
3. **Type Safety**: Strict TypeScript configuration, avoid `any`
4. **Performance**: Code splitting, memoization, virtual scrolling for large datasets
5. **Testing**: Unit tests with React Testing Library, integration tests, E2E with Cypress

### Integration Best Practices

1. **API Contracts**: Use OpenAPI/Swagger for API documentation
2. **Versioning**: Semantic versioning for frontend modules
3. **Monitoring**: Health checks, metrics, and observability
4. **Deployment**: Blue-green deployments, automated rollback procedures
5. **Security**: HTTPS, CORS configuration, input validation at all layers

This architecture provides a robust foundation for building scalable React/TypeScript frontend applications, following established KWI back-office patterns and industry best practices.