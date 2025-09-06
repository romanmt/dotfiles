# JavaScript Style Guide

## JavaScript-Specific Rules

### Variable Declarations
- **const by default**: Use `const` for values that don't change
- **let for reassignment**: Use `let` when reassignment is needed
- **Never use var**: Avoid `var` - use `const` or `let`
- **Block scope**: Prefer block-scoped declarations

```javascript
// Good
const API_BASE_URL = 'https://api.example.com';
const users = await fetchUsers();
let currentPage = 1;

// Bad
var API_BASE_URL = 'https://api.example.com';
var users = await fetchUsers();
```

### Function Declarations
- **Arrow functions**: Use arrow functions for callbacks and short functions
- **Function expressions**: Use function declarations for main functions
- **Async/await**: Prefer async/await over Promises chains

```javascript
// Good - Arrow functions for callbacks
const processUsers = (users) => {
  return users
    .filter(user => user.active)
    .map(user => ({ ...user, processed: true }));
};

// Good - Function declaration for main functions
function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// Good - Async/await
async function fetchUserData(userId) {
  try {
    const response = await fetch(`/api/users/${userId}`);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Failed to fetch user:', error);
    throw error;
  }
}
```

### Object and Array Handling
- **Destructuring**: Use destructuring for object and array extraction
- **Spread operator**: Use spread operator for copying and merging
- **Object shorthand**: Use object property shorthand when possible

```javascript
// Good - Destructuring
const { name, email, ...rest } = user;
const [first, second, ...remaining] = items;

// Good - Spread operator
const updatedUser = { ...user, lastLogin: new Date() };
const allItems = [...existingItems, ...newItems];

// Good - Object shorthand
const createUser = (name, email) => ({
  name,
  email,
  createdAt: new Date(),
  active: true
});
```

### Array Methods
- **Functional methods**: Use map, filter, reduce instead of loops when appropriate
- **Method chaining**: Chain array methods for readable data transformations
- **Early returns**: Use early returns in array callbacks when possible

```javascript
// Good - Functional array operations
const activeUsers = users
  .filter(user => user.active)
  .map(user => ({
    id: user.id,
    name: user.name,
    email: user.email
  }))
  .sort((a, b) => a.name.localeCompare(b.name));

// Good - Reduce for complex transformations
const usersByDepartment = users.reduce((acc, user) => {
  if (!acc[user.department]) {
    acc[user.department] = [];
  }
  acc[user.department].push(user);
  return acc;
}, {});
```

### Error Handling
- **Try-catch blocks**: Use try-catch for async operations
- **Error objects**: Create meaningful error objects
- **Error propagation**: Properly propagate errors up the call stack

```javascript
// Good - Comprehensive error handling
async function saveUser(userData) {
  try {
    // Validate input
    if (!userData.email) {
      throw new ValidationError('Email is required', 'email');
    }

    // Perform operation
    const response = await UserService.createUser(userData);
    
    if (!response.success) {
      throw new ApiError(response.message, response.code);
    }

    return response.data;
    
  } catch (error) {
    // Log error with context
    console.error('Failed to save user:', {
      userData: userData.email, // Don't log sensitive data
      error: error.message,
      timestamp: new Date().toISOString()
    });
    
    // Re-throw for caller to handle
    throw error;
  }
}

// Custom error classes
class ValidationError extends Error {
  constructor(message, field) {
    super(message);
    this.name = 'ValidationError';
    this.field = field;
  }
}

class ApiError extends Error {
  constructor(message, code) {
    super(message);
    this.name = 'ApiError';
    this.code = code;
  }
}
```

### Promises and Async Operations
- **Promise chaining**: Keep promise chains readable
- **Promise.all**: Use Promise.all for concurrent operations
- **Error handling**: Always handle promise rejections

```javascript
// Good - Concurrent operations
async function loadUserDashboard(userId) {
  try {
    const [user, orders, notifications] = await Promise.all([
      UserService.getUser(userId),
      OrderService.getUserOrders(userId),
      NotificationService.getUserNotifications(userId)
    ]);

    return {
      user: user.data,
      orders: orders.data,
      notifications: notifications.data
    };
  } catch (error) {
    console.error('Failed to load dashboard:', error);
    throw new Error('Dashboard loading failed');
  }
}

// Good - Sequential operations when needed
async function processUserWorkflow(userId) {
  const user = await UserService.getUser(userId);
  const permissions = await PermissionService.getUserPermissions(user.role);
  const profile = await ProfileService.buildUserProfile(user, permissions);
  
  return profile;
}
```

### Event Handling
- **Event delegation**: Use event delegation for dynamic content
- **Prevent defaults**: Explicitly prevent default behavior when needed
- **Cleanup**: Remove event listeners to prevent memory leaks

```javascript
// Good - Event handler with proper cleanup
function setupFormHandlers(formElement) {
  const handleSubmit = async (event) => {
    event.preventDefault();
    
    const formData = new FormData(event.target);
    const data = Object.fromEntries(formData.entries());
    
    try {
      await submitForm(data);
      showSuccessMessage('Form submitted successfully');
    } catch (error) {
      showErrorMessage('Failed to submit form');
    }
  };

  const handleInputChange = (event) => {
    const { name, value } = event.target;
    validateField(name, value);
  };

  // Add listeners
  formElement.addEventListener('submit', handleSubmit);
  formElement.addEventListener('input', handleInputChange);

  // Return cleanup function
  return () => {
    formElement.removeEventListener('submit', handleSubmit);
    formElement.removeEventListener('input', handleInputChange);
  };
}
```

### Module Imports/Exports
- **Named exports**: Prefer named exports over default exports
- **Import organization**: Group imports logically
- **Dynamic imports**: Use dynamic imports for code splitting

```javascript
// Good - Named exports
export const UserService = {
  getUser,
  createUser,
  updateUser,
  deleteUser
};

export const UserValidator = {
  validateEmail,
  validatePassword,
  validateProfile
};

// Good - Import organization
import React from 'react';
import { useState, useEffect, useCallback } from 'react';

import { Button, Card, Modal } from '@kwi/ui-components';
import { useQuery, useMutation } from '@tanstack/react-query';

import { UserService } from '../services/UserService';
import { formatDate, formatCurrency } from '../utils/formatters';

import './UserProfile.css';

// Good - Dynamic imports
const LazyReportsModule = React.lazy(() => 
  import('./ReportsModule').then(module => ({
    default: module.ReportsModule
  }))
);
```

### Debugging and Development
- **Console methods**: Use appropriate console methods
- **Descriptive logging**: Include context in log messages
- **Development guards**: Use environment checks for debug code

```javascript
// Good - Contextual logging
function processApiResponse(response, context) {
  console.group(`Processing API Response: ${context.operation}`);
  console.log('Request URL:', context.url);
  console.log('Response Status:', response.status);
  console.log('Response Data:', response.data);
  console.groupEnd();

  if (!response.success) {
    console.warn('API operation failed:', {
      operation: context.operation,
      error: response.error,
      timestamp: new Date().toISOString()
    });
  }
}

// Good - Development guards
if (process.env.NODE_ENV === 'development') {
  console.debug('Debug mode enabled');
  window.debugUtils = { UserService, ValidationUtils };
}
```

### Performance Considerations
- **Debouncing**: Debounce expensive operations
- **Memoization**: Cache expensive calculations
- **Lazy evaluation**: Defer expensive operations until needed

```javascript
// Good - Debounced search
function createDebouncedSearch(searchFn, delay = 300) {
  let timeoutId;
  
  return function debouncedSearch(...args) {
    clearTimeout(timeoutId);
    
    return new Promise((resolve, reject) => {
      timeoutId = setTimeout(async () => {
        try {
          const result = await searchFn(...args);
          resolve(result);
        } catch (error) {
          reject(error);
        }
      }, delay);
    });
  };
}

// Good - Simple memoization
function createMemoizedFunction(fn) {
  const cache = new Map();
  
  return function memoized(...args) {
    const key = JSON.stringify(args);
    
    if (cache.has(key)) {
      return cache.get(key);
    }
    
    const result = fn(...args);
    cache.set(key, result);
    return result;
  };
}
```

These JavaScript style guidelines ensure clean, readable, and maintainable code following modern ES6+ standards and best practices.