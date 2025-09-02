# Elixir Code Style Guide

## Context

Elixir-specific code style guidelines for Phoenix applications and OTP systems. Follow these conventions to maintain consistent, readable, and idiomatic Elixir code.

## General Principles

### Code Organization
- Use 2 spaces for indentation (no tabs)
- Keep lines under 100 characters when possible
- Use Unix line endings (\n)
- Add a final newline to all files
- Remove trailing whitespace

### File Naming
- Use `snake_case` for file names
- Match module names to file paths: `MyApp.User.Server` → `lib/my_app/user/server.ex`
- Use descriptive names that reflect module responsibility

## Module Structure

### Module Declaration
```elixir
defmodule MyApp.User.Server do
  @moduledoc """
  GenServer managing user state with debounced persistence.
  
  Handles user session management, state changes, and automatic
  persistence to reduce database load.
  """
  
  use GenServer
  
  # Module attributes
  @idle_timeout :timer.minutes(30)
  @persist_interval :timer.seconds(30)
  
  # Type definitions
  @type state :: %__MODULE__{
    user_id: integer(),
    data: map(),
    dirty: boolean()
  }
  
  # Client API
  # ... (public functions)
  
  # Server callbacks
  # ... (GenServer callbacks)
  
  # Private functions
  # ... (helper functions)
end
```

### Section Ordering
1. `@moduledoc` and module declaration
2. `use`, `import`, `alias`, `require` statements
3. Module attributes (`@attribute`)
4. Type definitions (`@type`, `@typep`, `@opaque`)
5. Public API functions
6. Callback implementations (GenServer, behaviours)
7. Private functions

## Function Definitions

### Function Structure
```elixir
@doc """
Starts a user server for the given user ID.

Returns `{:ok, pid}` on success or `{:error, reason}` on failure.

## Examples

    iex> MyApp.User.Server.start_link(user_id: 123)
    {:ok, #PID<0.123.0>}

"""
@spec start_link(keyword()) :: GenServer.on_start()
def start_link(opts) do
  user_id = Keyword.fetch!(opts, :user_id)
  name = via_tuple(user_id)
  GenServer.start_link(__MODULE__, opts, name: name)
end
```

### Function Guidelines
- Use `@doc` for public functions, `@doc false` for internal public functions
- Include `@spec` for all public functions and complex private functions
- Provide examples in docstrings when helpful
- Use pattern matching in function heads when possible
- Keep functions focused on a single responsibility

### Pattern Matching
```elixir
# Good - Pattern match in function heads
def handle_info(:timeout, %{dirty: true} = state) do
  persist_state(state)
  {:stop, :normal, state}
end

def handle_info(:timeout, %{dirty: false} = state) do
  {:stop, :normal, state}
end

# Good - Use case for complex pattern matching
def process_event(event) do
  case event do
    %{type: :user_update, user_id: id, data: data} when is_integer(id) ->
      update_user(id, data)
    
    %{type: :user_delete, user_id: id} ->
      delete_user(id)
    
    _ ->
      {:error, :invalid_event}
  end
end
```

## Naming Conventions

### Variables and Functions
- Use `snake_case` for variables and function names
- Use descriptive names that indicate purpose
- Boolean functions should end with `?`
- Dangerous functions should end with `!`

```elixir
# Good
def user_active?(user_id), do: # ...
def delete_user!(user_id), do: # ...

# Bad
def userActive(userId), do: # ...
def deleteUser(userId), do: # ...
```

### Modules and Atoms
- Use `PascalCase` for module names
- Use descriptive atoms in lowercase with underscores
- Prefer existing atoms over creating new ones

```elixir
# Good
defmodule MyApp.UserManager do
  def create_user(attrs) do
    case validate_user(attrs) do
      :ok -> {:ok, user}
      {:error, :invalid_email} -> {:error, "Email is invalid"}
    end
  end
end

# Bad
defmodule MyApp.UserMgr do
  def createUser(attrs) do
    # ...
  end
end
```

## Data Structures

### Structs
```elixir
defmodule MyApp.User do
  @type t :: %__MODULE__{
    id: integer() | nil,
    name: String.t(),
    email: String.t(),
    inserted_at: DateTime.t() | nil,
    updated_at: DateTime.t() | nil
  }
  
  defstruct [
    :id,
    :name, 
    :email,
    :inserted_at,
    :updated_at
  ]
  
  @doc "Creates a new user struct with current timestamps"
  @spec new(map()) :: t()
  def new(attrs \\ %{}) do
    now = DateTime.utc_now()
    
    struct!(__MODULE__, Map.merge(attrs, %{
      inserted_at: now,
      updated_at: now
    }))
  end
end
```

### Maps and Keyword Lists
```elixir
# Use keyword lists for function options
def start_server(user_id, opts \\ []) do
  timeout = Keyword.get(opts, :timeout, 5000)
  registry = Keyword.get(opts, :registry, MyApp.Registry)
  # ...
end

# Use maps for structured data
user_attrs = %{
  name: "John Doe",
  email: "john@example.com",
  age: 30
}

# Use consistent formatting for multi-line structures
config = %{
  database: %{
    hostname: "localhost",
    port: 5432,
    username: "postgres"
  },
  redis: %{
    host: "localhost",
    port: 6379
  }
}
```

## Error Handling

### Return Values
- Use `{:ok, result}` and `{:error, reason}` tuples consistently
- Use `!` versions for functions that should raise on error
- Provide meaningful error messages

```elixir
@doc "Fetches user by ID, returns error tuple on failure"
@spec get_user(integer()) :: {:ok, User.t()} | {:error, :not_found}
def get_user(id) do
  case Repo.get(User, id) do
    nil -> {:error, :not_found}
    user -> {:ok, user}
  end
end

@doc "Fetches user by ID, raises on failure"
@spec get_user!(integer()) :: User.t()
def get_user!(id) do
  case get_user(id) do
    {:ok, user} -> user
    {:error, reason} -> raise "User not found: #{reason}"
  end
end
```

### With Statements
```elixir
def create_user_with_profile(user_attrs, profile_attrs) do
  with {:ok, user} <- create_user(user_attrs),
       {:ok, profile} <- create_profile(user.id, profile_attrs),
       {:ok, _} <- send_welcome_email(user) do
    {:ok, %{user: user, profile: profile}}
  else
    {:error, :invalid_user} ->
      {:error, "User data is invalid"}
    
    {:error, :invalid_profile} ->
      {:error, "Profile data is invalid"}
    
    {:error, :email_failed} ->
      Logger.warn("Welcome email failed for user #{user.id}")
      {:ok, %{user: user, profile: profile}}
  end
end
```

## GenServer Patterns

### State Management
```elixir
defmodule MyApp.User.Server do
  defstruct [
    :user_id,
    :data,
    dirty: false,
    last_persisted: nil
  ]
  
  # Always specify timeout to prevent memory leaks
  def init(opts) do
    user_id = Keyword.fetch!(opts, :user_id)
    data = load_user_data(user_id)
    
    schedule_persistence()
    
    state = %__MODULE__{
      user_id: user_id,
      data: data,
      last_persisted: DateTime.utc_now()
    }
    
    {:ok, state, @idle_timeout}
  end
  
  def handle_call({:update, changes}, _from, state) do
    new_data = Map.merge(state.data, changes)
    new_state = %{state | data: new_data, dirty: true}
    
    {:reply, :ok, new_state, @idle_timeout}
  end
  
  def handle_info(:persist, state) do
    state = maybe_persist(state)
    schedule_persistence()
    {:noreply, state, @idle_timeout}
  end
  
  # Always handle timeout to prevent memory leaks
  def handle_info(:timeout, state) do
    state = force_persist(state)
    {:stop, :normal, state}
  end
end
```

## Testing Guidelines

### Test Structure
```elixir
defmodule MyApp.UserTest do
  use ExUnit.Case, async: true
  use MyApp.DataCase
  
  alias MyApp.User
  
  describe "new/1" do
    test "creates user struct with defaults" do
      user = User.new(%{name: "John", email: "john@example.com"})
      
      assert user.name == "John"
      assert user.email == "john@example.com"
      assert user.inserted_at
      assert user.updated_at
    end
    
    test "handles empty attributes" do
      user = User.new()
      
      assert user.inserted_at
      assert user.updated_at
    end
  end
  
  describe "validate/1" do
    test "returns ok for valid user" do
      attrs = %{name: "John Doe", email: "john@example.com"}
      
      assert User.validate(attrs) == :ok
    end
    
    test "returns error for invalid email" do
      attrs = %{name: "John", email: "invalid"}
      
      assert {:error, :invalid_email} = User.validate(attrs)
    end
  end
end
```

### Test Naming
- Use descriptive test names that explain the scenario
- Group related tests with `describe` blocks
- Use `setup` for common test data preparation

## Phoenix-Specific Guidelines

### Controllers
```elixir
defmodule MyAppWeb.UserController do
  use MyAppWeb, :controller
  
  alias MyApp.Users
  alias MyApp.User
  
  def index(conn, params) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    users = Users.list_users(page: page, per_page: 20)
    
    render(conn, "index.html", users: users)
  end
  
  def create(conn, %{"user" => user_params}) do
    case Users.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully")
        |> redirect(to: Routes.user_path(conn, :show, user))
      
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
```

### Context Modules
```elixir
defmodule MyApp.Users do
  @moduledoc """
  Context module for user management operations.
  """
  
  import Ecto.Query
  alias MyApp.{Repo, User}
  
  @doc """
  Returns paginated list of users.
  """
  @spec list_users(keyword()) :: [User.t()]
  def list_users(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 20)
    
    User
    |> order_by([u], desc: u.inserted_at)
    |> limit(^per_page)
    |> offset(^((page - 1) * per_page))
    |> Repo.all()
  end
  
  @doc """
  Creates a user with the given attributes.
  """
  @spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
```

## Performance Guidelines

### Database Queries
```elixir
# Good - Use preload for associations
def get_user_with_posts(id) do
  User
  |> preload(:posts)
  |> Repo.get(id)
end

# Good - Use select for specific fields
def list_user_names do
  User
  |> select([u], {u.id, u.name})
  |> Repo.all()
end

# Bad - N+1 queries
def list_users_with_post_count do
  users = Repo.all(User)
  
  Enum.map(users, fn user ->
    post_count = Repo.aggregate(Post, :count, :id, where: [user_id: user.id])
    Map.put(user, :post_count, post_count)
  end)
end
```

### Process Management
```elixir
# Use Registry for dynamic process names
def start_user_server(user_id) do
  name = {:via, Registry, {MyApp.Registry, {:user_server, user_id}}}
  DynamicSupervisor.start_child(MyApp.UserSupervisor, {UserServer, name: name, user_id: user_id})
end

# Implement proper timeouts
def call_user_server(user_id, message, timeout \\ 5000) do
  case get_user_server(user_id) do
    {:ok, pid} -> GenServer.call(pid, message, timeout)
    {:error, :not_found} -> {:error, :server_not_found}
  end
end
```

## Code Formatting

Use `mix format` with these `.formatter.exs` settings:

```elixir
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 100,
  import_deps: [:ecto, :phoenix]
]
```

## Common Anti-Patterns to Avoid

### Bad Practices
```elixir
# Don't use ! for non-raising functions
def save_user!(user), do: Repo.insert(user)  # Bad - doesn't raise

# Don't ignore pattern matching opportunities
def process_result(result) do  # Bad
  if result == :ok do
    handle_success()
  else
    handle_error(result)
  end
end

# Good
def process_result(:ok), do: handle_success()
def process_result({:error, reason}), do: handle_error(reason)

# Don't nest deeply
def complex_operation(data) do  # Bad
  if valid?(data) do
    if authorized?(data.user) do
      if available?(data.resource) do
        perform_operation(data)
      else
        {:error, :unavailable}
      end
    else
      {:error, :unauthorized}
    end
  else
    {:error, :invalid}
  end
end

# Good - Use with
def complex_operation(data) do
  with :ok <- validate(data),
       :ok <- authorize(data.user),
       :ok <- check_availability(data.resource) do
    perform_operation(data)
  else
    {:error, reason} -> {:error, reason}
  end
end
```

## Documentation Standards

- Use `@moduledoc` for all public modules
- Use `@doc` for all public functions
- Include `@spec` for type safety
- Provide usage examples for complex functions
- Document expected return values and error conditions
- Use consistent terminology throughout the codebase

Following these guidelines will help maintain a clean, consistent, and maintainable Elixir codebase that follows community best practices and OTP principles.
