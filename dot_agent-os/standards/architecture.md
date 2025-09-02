# System Architecture

## Overview

This document defines the architectural patterns and design principles for building scalable, fault-tolerant applications using OTP (Open Telecom Platform) principles in Elixir/Phoenix.

## Multi-Tenant OTP Design

### Core Principles

- **Process per Entity**: Each user and venue has a dedicated GenServer for state management
- **In-Memory State**: Primary state lives in memory for fast access and low latency
- **Debounced Persistence**: Database writes are debounced to reduce I/O overhead
- **Dynamic Supervision**: Processes are started on-demand and supervised dynamically
- **Process Registry**: Use Registry for dynamic process discovery without atoms
- **Fault Tolerance**: Leverage supervisors for automatic restart and state recovery

### Process Hierarchy

```
Application Supervisor
├── Core Services
│   ├── Repo (Database)
│   ├── PubSub
│   └── Registry (named: GigbookApp.Registry)
│
├── Dynamic Supervisors
│   ├── UserSupervisor (DynamicSupervisor)
│   │   └── UserServer.{user_id} (GenServer per user)
│   │
│   └── VenueSupervisor (DynamicSupervisor)
│       └── VenueServer.{venue_id} (GenServer per venue)
│
└── Web Endpoint
    └── LiveViews (interact with GenServers)
```

## Implementation Patterns

### Process Naming Convention

Use Registry-based naming to avoid atom exhaustion:

```elixir
# Starting a process
{:ok, pid} = DynamicSupervisor.start_child(
  UserSupervisor,
  {UserServer, user_id: user_id}
)

# Process registration
def start_link(opts) do
  user_id = Keyword.fetch!(opts, :user_id)
  name = {:via, Registry, {GigbookApp.Registry, {:user, user_id}}}
  GenServer.start_link(__MODULE__, opts, name: name)
end

# Finding a process
def get_server(user_id) do
  case Registry.lookup(GigbookApp.Registry, {:user, user_id}) do
    [{pid, _}] -> {:ok, pid}
    [] -> {:error, :not_found}
  end
end
```

### State Management Pattern

```elixir
defmodule GigbookApp.Users.UserServer do
  use GenServer
  
  @idle_timeout :timer.minutes(30)
  @persist_interval :timer.seconds(30)
  
  defstruct [:user_id, :state, :dirty, :last_persisted]
  
  # Client API
  def start_link(opts) do
    user_id = Keyword.fetch!(opts, :user_id)
    name = via_tuple(user_id)
    GenServer.start_link(__MODULE__, opts, name: name)
  end
  
  # Server Callbacks
  def init(opts) do
    user_id = Keyword.fetch!(opts, :user_id)
    
    # Restore state from database
    state = load_state_from_db(user_id)
    
    # Schedule periodic persistence
    Process.send_after(self(), :persist, @persist_interval)
    
    {:ok, %__MODULE__{
      user_id: user_id,
      state: state,
      dirty: false,
      last_persisted: DateTime.utc_now()
    }, @idle_timeout}
  end
  
  def handle_info(:persist, state) do
    state = maybe_persist(state)
    Process.send_after(self(), :persist, @persist_interval)
    {:noreply, state, @idle_timeout}
  end
  
  def handle_info(:timeout, state) do
    # Persist before shutting down due to inactivity
    final_state = force_persist(state)
    {:stop, :normal, final_state}
  end
  
  defp maybe_persist(%{dirty: true} = state) do
    # Persist to database
    save_to_db(state)
    %{state | dirty: false, last_persisted: DateTime.utc_now()}
  end
  defp maybe_persist(state), do: state
  
  defp via_tuple(user_id) do
    {:via, Registry, {GigbookApp.Registry, {:user, user_id}}}
  end
end
```

### Supervisor Configuration

```elixir
defmodule GigbookApp.Application do
  use Application
  
  def start(_type, _args) do
    children = [
      # Core services
      GigbookApp.Repo,
      GigbookAppWeb.Telemetry,
      {Phoenix.PubSub, name: GigbookApp.PubSub},
      
      # Process registry
      {Registry, keys: :unique, name: GigbookApp.Registry},
      
      # Dynamic supervisors
      {DynamicSupervisor, name: GigbookApp.UserSupervisor, strategy: :one_for_one},
      {DynamicSupervisor, name: GigbookApp.VenueSupervisor, strategy: :one_for_one},
      
      # Web endpoint
      GigbookAppWeb.Endpoint
    ]
    
    opts = [strategy: :one_for_one, name: GigbookApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

### LiveView Integration

LiveViews interact with GenServers for real-time state:

```elixir
defmodule GigbookAppWeb.VenueLive.Show do
  use GigbookAppWeb, :live_view
  
  def mount(%{"id" => venue_id}, _session, socket) do
    # Ensure GenServer is running
    {:ok, server} = GigbookApp.Venues.ensure_venue_server(venue_id)
    
    # Subscribe to changes
    Phoenix.PubSub.subscribe(GigbookApp.PubSub, "venue:#{venue_id}")
    
    # Get current state
    venue_state = GigbookApp.Venues.get_venue_state(venue_id)
    
    {:ok, assign(socket, venue: venue_state, venue_id: venue_id)}
  end
  
  def handle_info({:venue_updated, venue_state}, socket) do
    {:noreply, assign(socket, venue: venue_state)}
  end
end
```

## Debounced Persistence Strategy

### Write Patterns

1. **Immediate Writes**: Critical data (payments, bookings) write immediately
2. **Debounced Writes**: Non-critical updates batch every 30 seconds
3. **Shutdown Writes**: Always persist before process termination
4. **Crash Recovery**: Reload from last persisted state on restart

### Implementation Example

```elixir
defmodule GigbookApp.PersistenceHelper do
  @moduledoc """
  Helper functions for debounced persistence pattern
  """
  
  def schedule_persistence(delay \\ :timer.seconds(30)) do
    Process.send_after(self(), :persist, delay)
  end
  
  def persist_if_dirty(%{dirty: true} = state, persist_fn) do
    case persist_fn.(state) do
      :ok -> 
        %{state | dirty: false, last_persisted: DateTime.utc_now()}
      {:error, reason} ->
        # Log error, keep dirty flag
        Logger.error("Persistence failed: #{inspect(reason)}")
        state
    end
  end
  def persist_if_dirty(state, _), do: state
  
  def mark_dirty(state) do
    %{state | dirty: true}
  end
end
```

## Process Lifecycle Management

### Starting Processes

Processes start on-demand when accessed:

```elixir
defmodule GigbookApp.Venues do
  def ensure_venue_server(venue_id) do
    case get_venue_server(venue_id) do
      {:ok, pid} -> {:ok, pid}
      {:error, :not_found} -> start_venue_server(venue_id)
    end
  end
  
  defp start_venue_server(venue_id) do
    spec = {GigbookApp.Venues.VenueServer, venue_id: venue_id}
    DynamicSupervisor.start_child(GigbookApp.VenueSupervisor, spec)
  end
end
```

### Process Timeouts

- **Active Timeout**: 30 minutes of inactivity
- **Persist Before Timeout**: Always save state before shutdown
- **Graceful Shutdown**: Handle `:timeout` message properly

### Crash Recovery

When a process crashes:
1. Supervisor restarts it automatically
2. New process loads state from database
3. Continues operation with minimal disruption

## Scalability Considerations

### Horizontal Scaling

- **Process Distribution**: Use `libcluster` for node discovery
- **Global Registry**: Use `Horde` or `Swarm` for distributed registry
- **State Handoff**: Implement state migration between nodes

### Performance Optimization

- **ETS Tables**: Use for read-heavy, shared state
- **Process Pooling**: Pool database connections and external API clients
- **Lazy Loading**: Start processes only when needed
- **Batch Operations**: Group database writes for efficiency

## Testing Strategies

### Unit Testing GenServers

```elixir
defmodule GigbookApp.UserServerTest do
  use ExUnit.Case, async: true
  
  setup do
    # Start GenServer in test
    {:ok, server} = start_supervised({UserServer, user_id: 1})
    %{server: server}
  end
  
  test "updates state and marks dirty", %{server: server} do
    assert :ok = UserServer.update(server, %{name: "Test"})
    assert %{dirty: true} = :sys.get_state(server)
  end
end
```

### Integration Testing

- Test supervisor restart behavior
- Verify persistence on timeout
- Validate PubSub notifications
- Test concurrent access patterns

## Migration Path

For existing CRUD applications:

1. **Phase 1**: Add Registry and DynamicSupervisors
2. **Phase 2**: Implement GenServers for new features
3. **Phase 3**: Gradually migrate existing features
4. **Phase 4**: Add debounced persistence
5. **Phase 5**: Optimize for distribution

## Best Practices

1. **Always supervise** GenServers for fault tolerance
2. **Use timeouts** to prevent memory leaks from idle processes
3. **Persist critical data immediately**, batch the rest
4. **Test crash scenarios** to ensure recovery works
5. **Monitor process counts** to detect leaks
6. **Use telemetry** for observability
7. **Document process interactions** in your modules
8. **Keep GenServer state minimal** - only what changes frequently
9. **Use ETS for read-heavy shared data**
10. **Profile under load** to find bottlenecks

## Common Pitfalls to Avoid

1. **Atom exhaustion**: Use Registry instead of dynamic atoms
2. **Memory leaks**: Set idle timeouts on all GenServers
3. **Lost updates**: Always persist before shutdown
4. **Race conditions**: Use GenServer serialization
5. **Bottlenecks**: Don't route everything through single process
6. **Over-engineering**: Start simple, optimize based on metrics

## References

- [Elixir GenServer Documentation](https://hexdocs.pm/elixir/GenServer.html)
- [OTP Design Principles](https://www.erlang.org/doc/design_principles/des_princ.html)
- [The Little Elixir & OTP Guidebook](https://www.manning.com/books/the-little-elixir-and-otp-guidebook)
- [Designing for Scalability with Erlang/OTP](https://www.oreilly.com/library/view/designing-for-scalability/9781449361556/)