defmodule PhoenixAppWeb.GameAdminLive do
  use PhoenixAppWeb, :live_view
  alias PhoenixApp.{Accounts, GameCMS}
  alias PhoenixApp.GameCMS.{Character, Item, Quest, Guild}

  on_mount {PhoenixAppWeb.UserAuth, :require_admin_user}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    
    if connected?(socket) do
      # Subscribe to game events
      Phoenix.PubSub.subscribe(PhoenixApp.PubSub, "game:admin")
      Phoenix.PubSub.subscribe(PhoenixApp.PubSub, "game:stats")
      
      # Start periodic updates
      :timer.send_interval(5000, self(), :update_stats)
    end
    
    {:ok, assign(socket, 
      user: user,
      page_title: "Game Administration",
      active_players: get_active_players(),
      game_servers: get_game_servers(),
      server_stats: get_server_stats(),
      recent_events: get_recent_events()
    )}
  end

  @impl true
  def handle_info(:update_stats, socket) do
    {:noreply, assign(socket,
      server_stats: get_server_stats(),
      recent_events: get_recent_events()
    )}
  end

  @impl true
  def handle_info({:game_event, event}, socket) do
    recent_events = [event | socket.assigns.recent_events] |> Enum.take(50)
    {:noreply, assign(socket, recent_events: recent_events)}
  end

  @impl true
  def handle_event("restart_server", %{"server_id" => server_id}, socket) do
    case restart_game_server(server_id) do
      :ok ->
        {:noreply, socket
         |> put_flash(:info, "Server restart initiated")
         |> assign(game_servers: get_game_servers())}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to restart server: #{reason}")}
    end
  end

  @impl true
  def handle_event("kick_player", %{"player_id" => player_id}, socket) do
    case kick_player(player_id) do
      :ok ->
        {:noreply, socket
         |> put_flash(:info, "Player kicked successfully")
         |> assign(active_players: get_active_players())}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to kick player: #{reason}")}
    end
  end

  @impl true
  def handle_event("broadcast_message", %{"message" => message}, socket) do
    Phoenix.PubSub.broadcast(PhoenixApp.PubSub, "game:global", {:system_message, message})
    {:noreply, socket
     |> put_flash(:info, "Message broadcasted to all players")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="game-admin-dashboard">
      <div class="admin-header">
        <h1>🎮 Game Administration Dashboard</h1>
        <div class="admin-user">
          Welcome, <%= @user.email %> | <a href="/logout">Logout</a>
        </div>
      </div>

      <!-- Server Status Cards -->
      <div class="stats-grid">
        <div class="stat-card players">
          <h3>🎯 Active Players</h3>
          <div class="stat-number"><%= length(@active_players) %></div>
          <div class="stat-label">Currently Online</div>
        </div>
        
        <div class="stat-card servers">
          <h3>🖥️ Game Servers</h3>
          <div class="stat-number"><%= length(@game_servers) %></div>
          <div class="stat-label">Running Instances</div>
        </div>
        
        <div class="stat-card memory">
          <h3>💾 Memory Usage</h3>
          <div class="stat-number"><%= @server_stats.memory_mb %>MB</div>
          <div class="stat-label">System Memory</div>
        </div>
        
        <div class="stat-card uptime">
          <h3>⏱️ Uptime</h3>
          <div class="stat-number"><%= @server_stats.uptime_hours %>h</div>
          <div class="stat-label">Server Uptime</div>
        </div>
      </div>

      <!-- Game Servers Management -->
      <div class="admin-section">
        <h2>🖥️ Game Servers</h2>
        <div class="servers-grid">
          <%= for server <- @game_servers do %>
            <div class="server-card">
              <div class="server-header">
                <h4><%= server.name %></h4>
                <span class={"server-status #{server.status}"}><%= server.status %></span>
              </div>
              <div class="server-stats">
                <div>Players: <%= server.player_count %>/100</div>
                <div>Load: <%= server.cpu_usage %>%</div>
                <div>Memory: <%= server.memory_usage %>MB</div>
              </div>
              <div class="server-actions">
                <button phx-click="restart_server" phx-value-server_id={server.id} 
                        class="btn btn-warning">Restart</button>
              </div>
            </div>
          <% end %>
        </div>
      </div>

      <!-- Active Players -->
      <div class="admin-section">
        <h2>👥 Active Players</h2>
        <div class="players-table">
          <table>
            <thead>
              <tr>
                <th>Player</th>
                <th>Level</th>
                <th>Location</th>
                <th>Online Time</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <%= for player <- @active_players do %>
                <tr>
                  <td>
                    <div class="player-info">
                      <span class="player-name"><%= player.username %></span>
                      <span class="player-class"><%= player.character_class %></span>
                    </div>
                  </td>
                  <td><%= player.level %></td>
                  <td><%= player.current_zone %></td>
                  <td><%= player.online_time %></td>
                  <td>
                    <button phx-click="kick_player" phx-value-player_id={player.id} 
                            class="btn btn-sm btn-danger">Kick</button>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>

      <!-- System Messages -->
      <div class="admin-section">
        <h2>📢 Broadcast Message</h2>
        <form phx-submit="broadcast_message">
          <div class="form-group">
            <input type="text" name="message" placeholder="Enter system message..." 
                   class="form-control" required>
            <button type="submit" class="btn btn-primary">Broadcast</button>
          </div>
        </form>
      </div>

      <!-- Recent Events -->
      <div class="admin-section">
        <h2>📋 Recent Events</h2>
        <div class="events-log">
          <%= for event <- Enum.take(@recent_events, 20) do %>
            <div class="event-item">
              <span class="event-time"><%= event.timestamp %></span>
              <span class={"event-type #{event.type}"}><%= event.type %></span>
              <span class="event-message"><%= event.message %></span>
            </div>
          <% end %>
        </div>
      </div>
    </div>

    <style>
      .game-admin-dashboard {
        padding: 20px;
        background: #0f1419;
        color: white;
        min-height: 100vh;
        font-family: 'Segoe UI', Arial, sans-serif;
      }

      .admin-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 30px;
        padding-bottom: 20px;
        border-bottom: 2px solid #2c3e50;
      }

      .admin-header h1 {
        color: #2ecc71;
        margin: 0;
      }

      .admin-user a {
        color: #3498db;
        text-decoration: none;
      }

      .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
      }

      .stat-card {
        background: linear-gradient(135deg, #2c3e50, #34495e);
        padding: 20px;
        border-radius: 10px;
        text-align: center;
        border: 1px solid #444;
      }

      .stat-card.players { border-left: 4px solid #2ecc71; }
      .stat-card.servers { border-left: 4px solid #3498db; }
      .stat-card.memory { border-left: 4px solid #e74c3c; }
      .stat-card.uptime { border-left: 4px solid #f39c12; }

      .stat-number {
        font-size: 2.5em;
        font-weight: bold;
        margin: 10px 0;
      }

      .stat-label {
        color: #bdc3c7;
        font-size: 0.9em;
      }

      .admin-section {
        background: #1a1a2e;
        padding: 20px;
        border-radius: 10px;
        margin-bottom: 20px;
        border: 1px solid #444;
      }

      .admin-section h2 {
        color: #2ecc71;
        margin-bottom: 20px;
      }

      .servers-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 15px;
      }

      .server-card {
        background: #2c3e50;
        padding: 15px;
        border-radius: 8px;
        border: 1px solid #444;
      }

      .server-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 10px;
      }

      .server-status.online { color: #2ecc71; }
      .server-status.offline { color: #e74c3c; }
      .server-status.maintenance { color: #f39c12; }

      .server-stats div {
        margin: 5px 0;
        font-size: 0.9em;
        color: #bdc3c7;
      }

      .players-table {
        overflow-x: auto;
      }

      .players-table table {
        width: 100%;
        border-collapse: collapse;
      }

      .players-table th,
      .players-table td {
        padding: 12px;
        text-align: left;
        border-bottom: 1px solid #444;
      }

      .players-table th {
        background: #2c3e50;
        color: #2ecc71;
      }

      .player-info {
        display: flex;
        flex-direction: column;
      }

      .player-name {
        font-weight: bold;
      }

      .player-class {
        font-size: 0.8em;
        color: #bdc3c7;
      }

      .form-group {
        display: flex;
        gap: 10px;
        align-items: center;
      }

      .form-control {
        flex: 1;
        padding: 10px;
        background: #2c3e50;
        border: 1px solid #444;
        border-radius: 5px;
        color: white;
      }

      .btn {
        padding: 8px 16px;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        font-weight: bold;
        text-decoration: none;
        display: inline-block;
      }

      .btn-primary { background: #3498db; color: white; }
      .btn-warning { background: #f39c12; color: white; }
      .btn-danger { background: #e74c3c; color: white; }
      .btn-sm { padding: 5px 10px; font-size: 0.8em; }

      .events-log {
        max-height: 400px;
        overflow-y: auto;
        background: #2c3e50;
        padding: 15px;
        border-radius: 5px;
      }

      .event-item {
        display: flex;
        gap: 15px;
        padding: 8px 0;
        border-bottom: 1px solid #444;
      }

      .event-time {
        color: #bdc3c7;
        font-size: 0.8em;
        min-width: 80px;
      }

      .event-type {
        font-weight: bold;
        min-width: 100px;
      }

      .event-type.player_join { color: #2ecc71; }
      .event-type.player_leave { color: #e74c3c; }
      .event-type.combat { color: #f39c12; }
      .event-type.quest { color: #9b59b6; }
      .event-type.system { color: #3498db; }
    </style>
    """
  end

  # Helper functions
  defp get_active_players do
    [
      %{id: 1, username: "DragonSlayer", character_class: "Warrior", level: 45, current_zone: "Darkwood Forest", online_time: "2h 15m"},
      %{id: 2, username: "MysticMage", character_class: "Mage", level: 38, current_zone: "Crystal Caves", online_time: "1h 42m"},
      %{id: 3, username: "ShadowRogue", character_class: "Rogue", level: 52, current_zone: "Ancient Ruins", online_time: "3h 8m"},
      %{id: 4, username: "HolyPriest", character_class: "Priest", level: 41, current_zone: "Temple District", online_time: "45m"},
    ]
  end

  defp get_server_stats do
    %{
      memory_mb: 1250,
      uptime_hours: 72,
      cpu_usage: 15.8,
      active_connections: 247
    }
  end

  defp get_recent_events do
    [
      %{timestamp: "08:21:15", type: "player_join", message: "DragonSlayer joined the server"},
      %{timestamp: "08:20:42", type: "combat", message: "Epic battle in Darkwood Forest"},
      %{timestamp: "08:19:33", type: "quest", message: "Quest 'Ancient Artifact' completed by MysticMage"},
      %{timestamp: "08:18:21", type: "player_leave", message: "WarriorX left the server"},
      %{timestamp: "08:17:45", type: "system", message: "Server maintenance completed"},
    ]
  end

  defp get_game_servers do
    [
      %{id: 1, name: "Main Server", status: "online", player_count: 87, cpu_usage: 15, memory_usage: 1200},
      %{id: 2, name: "PvP Server", status: "online", player_count: 45, cpu_usage: 12, memory_usage: 800},
      %{id: 3, name: "RP Server", status: "maintenance", player_count: 0, cpu_usage: 0, memory_usage: 200},
    ]
  end

  defp restart_game_server(server_id) do
    # Implement actual server restart logic
    :ok
  end

  defp kick_player(player_id) do
    # Implement actual player kick logic
    :ok
  end
end