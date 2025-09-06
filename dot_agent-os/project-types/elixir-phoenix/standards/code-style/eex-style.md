# EEx Template Style Guide

## Context

EEx (Embedded Elixir) template style guidelines for Phoenix applications. Follow these conventions to maintain consistent, readable, and maintainable templates with proper separation of concerns.

## General Principles

### Template Organization
- Use 2 spaces for indentation (consistent with Elixir)
- Keep lines under 100 characters when possible
- Separate logic from presentation
- Use descriptive variable names
- Prefer helper functions over complex template logic

### File Naming
- Use `snake_case` for template file names
- Match template names to their corresponding actions: `index.html.heex`, `show.html.heex`
- Use `.heex` extension for HEEx templates (Phoenix LiveView)
- Use `.eex` extension for traditional EEx templates

## Template Structure

### Basic Template Layout
```heex
<!-- templates/user/show.html.heex -->
<div class="user-profile">
  <header class="user-header">
    <h1 class="user-name"><%= @user.name %></h1>
    <p class="user-email"><%= @user.email %></p>
  </header>

  <section class="user-details">
    <%= render_user_details(@user) %>
  </section>

  <nav class="user-actions">
    <%= if can?(@current_user, :edit, @user) do %>
      <%= link "Edit Profile", to: Routes.user_path(@conn, :edit, @user), 
                class: "btn btn-primary" %>
    <% end %>
    
    <%= link "Back to Users", to: Routes.user_path(@conn, :index), 
              class: "btn btn-secondary" %>
  </nav>
</div>
```

### Section Organization
1. Layout wrapper elements
2. Header content (title, navigation)
3. Main content sections
4. Action buttons/links
5. Footer content

## Elixir Code in Templates

### Basic Syntax
```heex
<!-- Output expressions -->
<h1><%= @page_title %></h1>
<p>User count: <%= length(@users) %></p>

<!-- Execution expressions (no output) -->
<% current_time = DateTime.utc_now() %>

<!-- Comments -->
<%# This is a comment that won't appear in HTML %>
```

### Code Formatting
- Use spaces around `<%= %>` and `<% %>` delimiters
- Keep simple expressions inline
- Extract complex logic to helper functions
- Use meaningful variable names

```heex
<!-- Good -->
<div class="status <%= status_class(@user.status) %>">
  <%= humanize_status(@user.status) %>
</div>

<!-- Bad -->
<div class="status <%= if @user.status == :active, do: "text-green", else: "text-red" %>">
  <%= @user.status |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize() %>
</div>
```

## Control Flow

### Conditionals
```heex
<!-- Simple conditionals -->
<%= if @user.verified do %>
  <span class="badge badge-verified">Verified</span>
<% end %>

<!-- If-else -->
<%= if @user.avatar do %>
  <img src="<%= @user.avatar %>" alt="<%= @user.name %>" class="avatar">
<% else %>
  <div class="avatar-placeholder">
    <%= String.first(@user.name) %>
  </div>
<% end %>

<!-- Unless (use sparingly) -->
<%= unless @user.suspended do %>
  <button class="btn btn-primary">Contact User</button>
<% end %>

<!-- Case statements for multiple conditions -->
<div class="user-status">
  <%= case @user.status do %>
    <% :active -> %>
      <span class="status-active">Active</span>
    <% :suspended -> %>
      <span class="status-suspended">Suspended</span>
    <% :pending -> %>
      <span class="status-pending">Pending Verification</span>
    <% _ -> %>
      <span class="status-unknown">Unknown</span>
  <% end %>
</div>
```

### Loops and Iteration
```heex
<!-- Simple enumeration -->
<ul class="user-list">
  <%= for user <- @users do %>
    <li class="user-item">
      <%= link user.name, to: Routes.user_path(@conn, :show, user) %>
    </li>
  <% end %>
</ul>

<!-- With index -->
<ol class="numbered-list">
  <%= for {item, index} <- Enum.with_index(@items) do %>
    <li class="item-<%= index %>">
      <span class="item-number"><%= index + 1 %></span>
      <span class="item-content"><%= item.name %></span>
    </li>
  <% end %>
</ol>

<!-- Empty state handling -->
<%= if Enum.empty?(@posts) do %>
  <div class="empty-state">
    <p>No posts yet. <%= link "Create your first post!", to: Routes.post_path(@conn, :new) %></p>
  </div>
<% else %>
  <div class="posts-grid">
    <%= for post <- @posts do %>
      <%= render "post_card.html", post: post, conn: @conn %>
    <% end %>
  </div>
<% end %>
```

### Comprehensions
```heex
<!-- List comprehension -->
<div class="tag-cloud">
  <%= for tag <- @post.tags, tag.visible do %>
    <span class="tag tag-<%= tag.category %>">
      <%= tag.name %>
    </span>
  <% end %>
</div>

<!-- Map comprehension -->
<ul class="category-counts">
  <%= for {category, count} <- @category_counts do %>
    <li>
      <span class="category"><%= humanize(category) %>:</span>
      <span class="count"><%= count %></span>
    </li>
  <% end %>
</ul>
```

## Forms and Form Helpers

### Phoenix Form Helpers
```heex
<%= form_with @changeset, Routes.user_path(@conn, :create), [class: "user-form"], fn f -> %>
  <div class="form-group">
    <%= label f, :name, "Full Name", class: "form-label" %>
    <%= text_input f, :name, class: "form-control", placeholder: "Enter your name" %>
    <%= error_tag f, :name %>
  </div>

  <div class="form-group">
    <%= label f, :email, "Email Address", class: "form-label" %>
    <%= email_input f, :email, class: "form-control", required: true %>
    <%= error_tag f, :email %>
  </div>

  <div class="form-group">
    <%= label f, :role, "User Role", class: "form-label" %>
    <%= select f, :role, user_role_options(), 
          [prompt: "Select a role", class: "form-control"] %>
    <%= error_tag f, :role %>
  </div>

  <div class="form-actions">
    <%= submit "Create User", class: "btn btn-primary" %>
    <%= link "Cancel", to: Routes.user_path(@conn, :index), class: "btn btn-secondary" %>
  </div>
<% end %>
```

### Form Validation Display
```heex
<!-- Error summary -->
<%= if @changeset.errors != [] do %>
  <div class="alert alert-danger">
    <h4>Please fix the following errors:</h4>
    <ul>
      <%= for {field, {message, _}} <- @changeset.errors do %>
        <li><%= humanize(field) %>: <%= message %></li>
      <% end %>
    </ul>
  </div>
<% end %>

<!-- Individual field errors -->
<div class="form-group <%= if f.errors[:email], do: "has-error" %>">
  <%= label f, :email, class: "form-label" %>
  <%= email_input f, :email, class: "form-control" %>
  <%= if error = f.errors[:email] do %>
    <span class="error-message"><%= translate_error(error) %></span>
  <% end %>
</div>
```

## Partials and Components

### Rendering Partials
```heex
<!-- Simple partial -->
<%= render "user_card.html", user: @user %>

<!-- Partial with multiple assigns -->
<%= render "post_preview.html", 
    post: @post, 
    current_user: @current_user,
    show_actions: true %>

<!-- Partial with connection -->
<%= render "navigation.html", conn: @conn, active: :users %>
```

### Component Definition
```heex
<!-- templates/user/_user_card.html.heex -->
<div class="user-card" data-user-id="<%= @user.id %>">
  <div class="user-avatar">
    <%= if @user.avatar do %>
      <img src="<%= @user.avatar %>" alt="<%= @user.name %>">
    <% else %>
      <div class="avatar-placeholder">
        <%= avatar_initials(@user.name) %>
      </div>
    <% end %>
  </div>

  <div class="user-info">
    <h3 class="user-name">
      <%= link @user.name, to: Routes.user_path(@conn, :show, @user) %>
    </h3>
    
    <p class="user-email"><%= @user.email %></p>
    
    <%= if assigns[:show_role] do %>
      <span class="user-role badge badge-<%= @user.role %>">
        <%= humanize(@user.role) %>
      </span>
    <% end %>
  </div>

  <%= if assigns[:show_actions] && can?(@current_user, :manage, @user) do %>
    <div class="user-actions">
      <%= link "Edit", to: Routes.user_path(@conn, :edit, @user), 
                class: "btn btn-sm btn-outline" %>
    </div>
  <% end %>
</div>
```

## HTML Structure and Semantics

### Semantic HTML
```heex
<!-- Use semantic elements -->
<article class="blog-post">
  <header class="post-header">
    <h1 class="post-title"><%= @post.title %></h1>
    <time class="post-date" datetime="<%= @post.published_at %>">
      <%= format_date(@post.published_at) %>
    </time>
  </header>

  <section class="post-content">
    <%= raw(@post.content_html) %>
  </section>

  <footer class="post-footer">
    <div class="post-meta">
      <span class="post-author">By <%= @post.author.name %></span>
      <span class="post-category">in <%= @post.category.name %></span>
    </div>
  </footer>
</article>
```

### Accessibility
```heex
<!-- Use proper labels and ARIA attributes -->
<form class="search-form" role="search">
  <div class="search-group">
    <label for="search-input" class="sr-only">Search posts</label>
    <input 
      id="search-input"
      name="q" 
      type="search" 
      placeholder="Search posts..." 
      class="search-input"
      aria-label="Search posts"
      value="<%= @query %>"
    >
    <button type="submit" class="search-button" aria-label="Submit search">
      <i class="icon-search" aria-hidden="true"></i>
    </button>
  </div>
</form>

<!-- Use proper heading hierarchy -->
<section class="user-profile">
  <h1>User Profile</h1>
  
  <section class="contact-info">
    <h2>Contact Information</h2>
    <!-- ... -->
  </section>
  
  <section class="preferences">
    <h2>Preferences</h2>
    <h3>Notification Settings</h3>
    <!-- ... -->
  </section>
</section>
```

## Data Attributes and JavaScript Integration

### Data Attributes
```heex
<!-- For JavaScript hooks -->
<div class="modal" 
     data-modal="user-settings"
     data-user-id="<%= @user.id %>"
     data-closable="true">
  <!-- modal content -->
</div>

<!-- For styling hooks -->
<div class="post-item" 
     data-post-status="<%= @post.status %>"
     data-post-id="<%= @post.id %>">
  <!-- post content -->
</div>

<!-- For LiveView -->
<button phx-click="delete-user" 
        phx-value-user-id="<%= @user.id %>"
        data-confirm="Are you sure you want to delete this user?"
        class="btn btn-danger">
  Delete User
</button>
```

## Security Considerations

### Output Escaping
```heex
<!-- Automatically escaped (safe) -->
<p><%= @user.bio %></p>

<!-- Raw HTML (be careful!) -->
<div class="content">
  <%= raw(@post.content_html) %>
</div>

<!-- Safe attribute interpolation -->
<img src="<%= @user.avatar_url %>" alt="<%= @user.name %>">

<!-- Dangerous - avoid unless absolutely necessary -->
<div class="<%= @dynamic_class %>">
  <%= raw(@unsafe_content) %>
</div>
```

### CSRF Protection
```heex
<!-- Forms automatically include CSRF tokens -->
<%= form_with @changeset, Routes.user_path(@conn, :create) do |f| %>
  <!-- form fields -->
<% end %>

<!-- For AJAX forms, include token manually -->
<form id="ajax-form" data-csrf-token="<%= get_csrf_token() %>">
  <!-- form fields -->
</form>
```

## Performance Considerations

### Efficient Rendering
```heex
<!-- Avoid N+1 queries - preload in controller -->
<ul class="user-posts">
  <%= for post <- @user.posts do %>
    <li><%= post.title %> - <%= post.category.name %></li>
  <% end %>
</ul>

<!-- Use helper functions for complex logic -->
<div class="user-status">
  <%= user_status_badge(@user) %>
</div>

<!-- Cache expensive computations -->
<%= if assigns[:show_stats] do %>
  <div class="user-stats">
    <%= render_user_stats(@user) %>
  </div>
<% end %>
```

### Lazy Loading
```heex
<!-- Conditional rendering for expensive operations -->
<%= if assigns[:load_comments] do %>
  <section class="comments">
    <%= render "comments.html", comments: @post.comments %>
  </section>
<% else %>
  <button class="load-comments" data-post-id="<%= @post.id %>">
    Load Comments (<%= @post.comment_count %>)
  </button>
<% end %>
```

## CSS Classes and Styling

### CSS Class Conventions
```heex
<!-- Use BEM-style naming -->
<div class="user-card user-card--featured">
  <div class="user-card__header">
    <h3 class="user-card__title"><%= @user.name %></h3>
  </div>
  
  <div class="user-card__body">
    <p class="user-card__description"><%= @user.bio %></p>
  </div>
  
  <div class="user-card__actions">
    <button class="btn btn--primary btn--small">Follow</button>
  </div>
</div>

<!-- State-based classes -->
<div class="post-item <%= post_state_class(@post) %>">
  <!-- content -->
</div>

<!-- Utility classes -->
<div class="d-flex align-items-center justify-content-between mb-4">
  <h2 class="mb-0"><%= @page_title %></h2>
  <div class="text-muted"><%= @post_count %> posts</div>
</div>
```

## Common Anti-Patterns to Avoid

### Bad Practices
```heex
<!-- DON'T: Complex logic in templates -->
<%= if @user.role == :admin && @user.active && @user.permissions |> Enum.member?(:manage_users) do %>
  <!-- admin content -->
<% end %>

<!-- DO: Use helper functions -->
<%= if can_manage_users?(@user) do %>
  <!-- admin content -->
<% end %>

<!-- DON'T: Inline styles -->
<div style="color: <%= if @user.active, do: 'green', else: 'red' %>;">
  <%= @user.name %>
</div>

<!-- DO: CSS classes with helper functions -->
<div class="user-name <%= user_status_class(@user) %>">
  <%= @user.name %>
</div>

<!-- DON'T: Deep nesting -->
<%= if @current_user do %>
  <%= if @current_user.verified do %>
    <%= if can?(@current_user, :access, @resource) do %>
      <!-- deeply nested content -->
    <% end %>
  <% end %>
<% end %>

<!-- DO: Use helper functions or early returns -->
<%= if user_can_access?(@current_user, @resource) do %>
  <!-- content -->
<% end %>
```

## Testing Templates

### Template Testing Strategies
- Test complex helper functions in unit tests
- Use integration tests for full template rendering
- Test accessibility with automated tools
- Validate HTML structure in tests

```elixir
# In your test file
test "renders user profile correctly", %{conn: conn} do
  user = insert(:user, name: "John Doe", email: "john@example.com")
  
  conn = get(conn, Routes.user_path(conn, :show, user))
  
  assert html_response(conn, 200) =~ "John Doe"
  assert html_response(conn, 200) =~ "john@example.com"
  assert html_response(conn, 200) =~ "user-profile"
end
```

## Documentation

- Document complex template logic with comments
- Explain non-obvious template patterns
- Document expected assigns for partial templates
- Include usage examples for reusable components

```heex
<%# 
  User card component
  
  Required assigns:
  - @user: User struct with name, email, avatar fields
  - @conn: Phoenix connection for routing
  
  Optional assigns:
  - @show_actions: boolean, shows edit/delete buttons if true
  - @current_user: User struct, used for permission checks
%>
<div class="user-card">
  <!-- component content -->
</div>
```

Following these guidelines will help maintain consistent, secure, and performant EEx templates that are easy to read, test, and maintain.
