# TypeScript Style Guide

## TypeScript-Specific Rules

### Type Definitions
- **Interfaces over Types**: Prefer interfaces for object shapes
- **Meaningful Names**: Use descriptive names for generic types
- **Strict Configuration**: Always use strict TypeScript settings
- **Avoid Any**: Never use `any` - use `unknown` or proper typing

### Naming Conventions
- **Interfaces**: Use PascalCase with descriptive names (e.g., `UserProfileProps`, `ApiResponse<T>`)
- **Type Aliases**: Use PascalCase (e.g., `UserStatus`, `ErrorType`)
- **Generic Parameters**: Use meaningful names (e.g., `<TData>`, `<TResponse>`, `<TEntity>`)
- **Enums**: Use PascalCase for enum name and values (e.g., `UserStatus.ACTIVE`)

### Interface Definitions
```typescript
// Good - Clear interface with optional properties
interface UserProfileProps {
  user: User;
  onUpdate?: (user: User) => void;
  onDelete?: (userId: string) => void;
  readonly?: boolean;
  className?: string;
}

// Good - Generic interface with constraints
interface ApiResponse<TData = unknown> {
  data: TData;
  success: boolean;
  message: string;
  timestamp: string;
}

// Bad - Using any type
interface BadProps {
  data: any;
  callback: any;
}
```

### Type Guards and Narrowing
```typescript
// Good - Type guard functions
function isUser(obj: unknown): obj is User {
  return typeof obj === 'object' && 
         obj !== null && 
         'id' in obj && 
         'name' in obj;
}

// Good - Using type guards
function processUserData(data: unknown) {
  if (isUser(data)) {
    // TypeScript now knows data is User
    console.log(data.name); // Safe to access
  }
}
```

### Utility Types
```typescript
// Good - Using utility types
type PartialUser = Partial<User>;
type UserKeys = keyof User;
type UserEmail = Pick<User, 'email'>;
type UserWithoutId = Omit<User, 'id'>;

// Good - Creating custom utility types
type NonNullable<T> = T extends null | undefined ? never : T;
type ApiResponseData<T> = T extends ApiResponse<infer U> ? U : never;
```

### Enum Usage
```typescript
// Good - String enums for better debugging
enum UserStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  PENDING = 'PENDING',
  SUSPENDED = 'SUSPENDED'
}

// Good - Const assertions for immutable objects
const CONFIG = {
  API_TIMEOUT: 5000,
  MAX_RETRIES: 3,
  DEFAULT_PAGE_SIZE: 25
} as const;

type ConfigKey = keyof typeof CONFIG;
```

### Function Typing
```typescript
// Good - Explicit return types for public functions
export function calculateTotal(items: CartItem[]): number {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}

// Good - Generic function with constraints
function mapResponse<TInput, TOutput>(
  data: TInput[],
  mapper: (item: TInput) => TOutput
): TOutput[] {
  return data.map(mapper);
}

// Good - Async function typing
async function fetchUserData(userId: string): Promise<User | null> {
  try {
    const response = await UserService.getUser(userId);
    return response.data;
  } catch (error) {
    console.error('Failed to fetch user:', error);
    return null;
  }
}
```

### React Component Typing
```typescript
// Good - Functional component with proper typing
interface ButtonProps {
  children: React.ReactNode;
  onClick?: (event: React.MouseEvent<HTMLButtonElement>) => void;
  disabled?: boolean;
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'small' | 'medium' | 'large';
}

export const Button: React.FC<ButtonProps> = ({
  children,
  onClick,
  disabled = false,
  variant = 'primary',
  size = 'medium'
}) => {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={`btn btn-${variant} btn-${size}`}
    >
      {children}
    </button>
  );
};
```

### Event Handler Typing
```typescript
// Good - Proper event handler typing
interface FormProps {
  onSubmit: (data: FormData) => void;
  onFieldChange: (field: string, value: string) => void;
}

const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
  event.preventDefault();
  const formData = new FormData(event.currentTarget);
  // Process form data
};

const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
  const { name, value } = event.target;
  onFieldChange(name, value);
};
```

### Error Handling Types
```typescript
// Good - Discriminated unions for error handling
type Result<T, E = Error> = 
  | { success: true; data: T }
  | { success: false; error: E };

// Usage
async function fetchData(url: string): Promise<Result<ApiResponse, string>> {
  try {
    const response = await fetch(url);
    const data = await response.json();
    return { success: true, data };
  } catch (error) {
    return { success: false, error: error.message };
  }
}

// Good - Custom error types
class ValidationError extends Error {
  constructor(
    message: string,
    public field: string,
    public code: string
  ) {
    super(message);
    this.name = 'ValidationError';
  }
}
```

### Module Declaration and Exports
```typescript
// Good - Explicit module exports
export type { User, UserProfile, UserFilters };
export { UserService, UserValidator };
export { default as UserCard } from './UserCard';

// Good - Namespace declaration when needed
declare namespace KWI {
  interface UIComponents {
    Button: React.ComponentType<ButtonProps>;
    Card: React.ComponentType<CardProps>;
  }
  
  interface Config {
    apiBaseUrl: string;
    timeout: number;
  }
}
```

### Advanced TypeScript Patterns
```typescript
// Good - Mapped types
type Optional<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;
type RequiredFields<T, K extends keyof T> = T & Required<Pick<T, K>>;

// Good - Template literal types
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';
type Endpoint<T extends string> = `/${T}`;
type ApiEndpoint<T extends string> = `/api/v1${Endpoint<T>}`;

// Good - Conditional types
type NonEmptyArray<T> = [T, ...T[]];
type ArrayElement<T> = T extends (infer U)[] ? U : never;
```

### TSConfig Recommendations
```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "noImplicitReturns": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": false,
    "allowUnusedLabels": false,
    "allowUnreachableCode": false
  }
}
```

These TypeScript style guidelines ensure type safety, code clarity, and maintainability while following modern TypeScript best practices.