defmodule PhoenixAppWeb.GamePlayerLive do
  use PhoenixAppWeb, :live_view
  # Note: Game functionality simplified

  on_mount {PhoenixAppWeb.UserAuth, :require_authenticated_user}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to player-specific events
      Phoenix.PubSub.subscribe(PhoenixApp.PubSub, "player:#{socket.assigns.current_user.id}")
      Phoenix.PubSub.subscribe(PhoenixApp.PubSub, "game:global")
      
      # Update player status
      :timer.send_interval(10000, self(), :update_player_data)
    end
    
    user = socket.assigns.current_user
    
    {:ok, assign(socket,
      user: user,
      page_title: "Game Dashboard",
      character: get_character_data(user && user.id),
      inventory: get_inventory(user && user.id),
      quests: get_active_quests(user && user.id),
      guild: get_guild_info(user && user.id),
      friends: get_friends_list(user && user.id),
      chat_messages: [],
      server_status: get_server_status(),
      selected_tab: "character"
    )}
  end

  @impl true
  def handle_info(:update_player_data, socket) do
    user_id = socket.assigns.user.id
    {:noreply, assign(socket,
      character: get_character_data(user_id),
      inventory: get_inventory(user_id),
      quests: get_active_quests(user_id),
      server_status: get_server_status()
    )}
  end

  @impl true
  def handle_info({:system_message, message}, socket) do
    chat_message = %{
      type: "system",
      message: message,
      timestamp: DateTime.utc_now() |> DateTime.to_time() |> Time.to_string()
    }
    
    chat_messages = [chat_message | socket.assigns.chat_messages] |> Enum.take(50)
    {:noreply, assign(socket, chat_messages: chat_messages)}
  end

  @impl true
  def handle_info({:player_message, from, message}, socket) do
    chat_message = %{
      type: "player",
      from: from,
      message: message,
      timestamp: DateTime.utc_now() |> DateTime.to_time() |> Time.to_string()
    }
    
    chat_messages = [chat_message | socket.assigns.chat_messages] |> Enum.take(50)
    {:noreply, assign(socket, chat_messages: chat_messages)}
  end

  @impl true
  def handle_event("select_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, selected_tab: tab)}
  end

  @impl true
  def handle_event("send_chat", %{"message" => message}, socket) when message != "" do
    user = socket.assigns.user
    Phoenix.PubSub.broadcast(PhoenixApp.PubSub, "game:global", 
      {:player_message, user.email, message})
    {:noreply, socket}
  end

  @impl true
  def handle_event("send_chat", _params, socket), do: {:noreply, socket}

  @impl true
  def handle_event("use_item", %{"item_id" => item_id}, socket) do
    case use_item(socket.assigns.user.id, item_id) do
      :ok ->
        {:noreply, put_flash(socket, :info, "Item used successfully")}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Cannot use item: #{reason}")}
    end
  end

  @impl true
  def handle_event("accept_quest", %{"quest_id" => quest_id}, socket) do
    case accept_quest(socket.assigns.user.id, quest_id) do
      :ok ->
        {:noreply, put_flash(socket, :info, "Quest accepted!")}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Cannot accept quest: #{reason}")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="game-player-dashboard">
      <div class="dashboard-header">
        <h1>🎮 EQEmu Dashboard</h1>
        <div class="server-info">
          <span class={"server-status #{@server_status.status}"}><%= @server_status.status %></span>
          <span class="player-count"><%= @server_status.players %> players online</span>
        </div>
        <div class="user-info">
          Welcome, <%= @user.email %> | <a href="/logout">Logout</a>
        </div>
      </div>

      <!-- Character Quick Stats -->
      <div class="character-summary">
        <div class="character-avatar">
          <div class="avatar-placeholder">
            <%= String.first(@character.name) %>
          </div>
        </div>
        <div class="character-info">
          <h2><%= @character.name %></h2>
          <p>Level <%= @character.level %> <%= @character.class %></p>
          <div class="health-mana-bars">
            <div class="stat-bar health">
              <label>Health</label>
              <div class="bar">
                <div class="fill" style={"width: #{@character.health_percent}%"}></div>
              </div>
              <span><%= @character.health %>/<%= @character.max_health %></span>
            </div>
            <div class="stat-bar mana">
              <label>Mana</label>
              <div class="bar">
                <div class="fill" style={"width: #{@character.mana_percent}%"}></div>
              </div>
              <span><%= @character.mana %>/<%= @character.max_mana %></span>
            </div>
          </div>
        </div>
        <div class="character-stats">
          <div class="stat">
            <span class="stat-label">XP</span>
            <span class="stat-value"><%= @character.experience %>/<%= @character.next_level_xp %></span>
          </div>
          <div class="stat">
            <span class="stat-label">Gold</span>
            <span class="stat-value"><%= @character.gold %></span>
          </div>
          <div class="stat">
            <span class="stat-label">Location</span>
            <span class="stat-value"><%= @character.current_zone %></span>
          </div>
        </div>
      </div>

      <!-- Navigation Tabs -->
      <div class="dashboard-tabs">
        <button class={"tab #{if @selected_tab == "character", do: "active"}"} 
                phx-click="select_tab" phx-value-tab="character">
          ⚔️ Character
        </button>
        <button class={"tab #{if @selected_tab == "inventory", do: "active"}"} 
                phx-click="select_tab" phx-value-tab="inventory">
          🎒 Inventory
        </button>
        <button class={"tab #{if @selected_tab == "quests", do: "active"}"} 
                phx-click="select_tab" phx-value-tab="quests">
          📜 Quests
        </button>
        <button class={"tab #{if @selected_tab == "guild", do: "active"}"} 
                phx-click="select_tab" phx-value-tab="guild">
          🏰 Guild
        </button>
        <button class={"tab #{if @selected_tab == "social", do: "active"}"} 
                phx-click="select_tab" phx-value-tab="social">
          👥 Social
        </button>
      </div>

      <!-- Tab Content -->
      <div class="tab-content">
        <%= if @selected_tab == "character" do %>
          <div class="character-details">
            <div class="stats-grid">
              <div class="stat-group">
                <h3>⚔️ Combat Stats</h3>
                <div class="stat-item">
                  <span>Attack Power</span>
                  <span><%= @character.attack_power %></span>
                </div>
                <div class="stat-item">
                  <span>Defense</span>
                  <span><%= @character.defense %></span>
                </div>
                <div class="stat-item">
                  <span>Critical Hit</span>
                  <span><%= @character.crit_chance %>%</span>
                </div>
                <div class="stat-item">
                  <span>Attack Speed</span>
                  <span><%= @character.attack_speed %></span>
                </div>
              </div>
              
              <div class="stat-group">
                <h3>🛡️ Attributes</h3>
                <div class="stat-item">
                  <span>Strength</span>
                  <span><%= @character.strength %></span>
                </div>
                <div class="stat-item">
                  <span>Agility</span>
                  <span><%= @character.agility %></span>
                </div>
                <div class="stat-item">
                  <span>Intelligence</span>
                  <span><%= @character.intelligence %></span>
                </div>
                <div class="stat-item">
                  <span>Vitality</span>
                  <span><%= @character.vitality %></span>
                </div>
              </div>
            </div>
          </div>

        <% end %>

        <%= if @selected_tab == "inventory" do %>
          <div class="inventory-grid">
            <%= for item <- @inventory do %>
              <div class={"inventory-slot #{item.rarity}"}>
                <div class="item-icon"><%= item.icon %></div>
                <div class="item-info">
                  <div class="item-name"><%= item.name %></div>
                  <%= if item.quantity > 1 do %>
                    <div class="item-quantity"><%= item.quantity %></div>
                  <% end %>
                </div>
                <%= if item.usable do %>
                  <button class="use-item-btn" phx-click="use_item" phx-value-item_id={item.id}>
                    Use
                  </button>
                <% end %>
              </div>
            <% end %>
            
            <!-- Empty slots -->
            <%= for _i <- 1..max(0, 40 - length(@inventory)) do %>
              <div class="inventory-slot empty"></div>
            <% end %>
          </div>

        <% end %>

        <%= if @selected_tab == "quests" do %>
          <div class="quests-container">
            <h3>📜 Active Quests</h3>
            <%= for quest <- @quests do %>
              <div class="quest-item">
                <div class="quest-header">
                  <h4><%= quest.title %></h4>
                  <span class={"quest-difficulty #{quest.difficulty}"}><%= quest.difficulty %></span>
                </div>
                <p class="quest-description"><%= quest.description %></p>
                <div class="quest-progress">
                  <div class="progress-bar">
                    <div class="progress-fill" style={"width: #{quest.progress_percent}%"}></div>
                  </div>
                  <span><%= quest.progress %>/<%= quest.total %></span>
                </div>
                <div class="quest-rewards">
                  <span>Rewards: <%= quest.xp_reward %> XP, <%= quest.gold_reward %> Gold</span>
                </div>
              </div>
            <% end %>
          </div>

        <% end %>

        <%= if @selected_tab == "guild" do %>
          <div class="guild-info">
            <%= if @guild do %>
              <div class="guild-header">
                <h3>🏰 <%= @guild.name %></h3>
                <span class="guild-level">Level <%= @guild.level %></span>
              </div>
              <p><%= @guild.description %></p>
              <div class="guild-stats">
                <div class="guild-stat">
                  <span>Members</span>
                  <span><%= @guild.member_count %>/50</span>
                </div>
                <div class="guild-stat">
                  <span>Your Rank</span>
                  <span><%= @guild.your_rank %></span>
                </div>
              </div>
            <% else %>
              <div class="no-guild">
                <h3>🏰 No Guild</h3>
                <p>You're not currently a member of any guild.</p>
                <button class="btn btn-primary">Find Guild</button>
              </div>
            <% end %>
          </div>

        <% end %>

        <%= if @selected_tab == "social" do %>
          <div class="social-container">
            <div class="friends-list">
              <h3>👥 Friends (<%= length(@friends) %>)</h3>
              <%= for friend <- @friends do %>
                <div class="friend-item">
                  <div class="friend-avatar"><%= String.first(friend.name) %></div>
                  <div class="friend-info">
                    <div class="friend-name"><%= friend.name %></div>
                    <div class={"friend-status #{friend.status}"}><%= friend.status %></div>
                  </div>
                  <%= if friend.status == "online" do %>
                    <button class="btn btn-sm">Message</button>
                  <% end %>
                </div>
              <% end %>
            </div>
            
            <div class="chat-container">
              <h3>💬 Global Chat</h3>
              <div class="chat-messages" id="chat-messages">
                <%= for message <- Enum.reverse(@chat_messages) do %>
                  <div class={"chat-message #{message.type}"}>
                    <span class="message-time"><%= message.timestamp %></span>
                    <%= if message.type == "system" do %>
                      <span class="system-message">🔔 <%= message.message %></span>
                    <% else %>
                      <span class="player-name"><%= message.from %>:</span>
                      <span class="message-text"><%= message.message %></span>
                    <% end %>
                  </div>
                <% end %>
              </div>
              <form phx-submit="send_chat" class="chat-input">
                <input type="text" name="message" placeholder="Type your message..." 
                       autocomplete="off" class="form-control">
                <button type="submit" class="btn btn-primary">Send</button>
              </form>
            </div>
          </div>

        <% end %>
      </div>
    </div>

    <style>
      .game-player-dashboard {
        background: #0f1419;
        color: white;
        min-height: 100vh;
        font-family: 'Segoe UI', Arial, sans-serif;
        padding: 20px;
      }

      .dashboard-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        padding-bottom: 15px;
        border-bottom: 2px solid #2c3e50;
      }

      .dashboard-header h1 {
        color: #2ecc71;
        margin: 0;
      }

      .server-info {
        display: flex;
        gap: 15px;
        align-items: center;
      }

      .server-status.online { color: #2ecc71; }
      .server-status.offline { color: #e74c3c; }

      .user-info a {
        color: #3498db;
        text-decoration: none;
      }

      .character-summary {
        display: flex;
        gap: 20px;
        background: #1a1a2e;
        padding: 20px;
        border-radius: 10px;
        margin-bottom: 20px;
        border: 1px solid #444;
      }

      .character-avatar {
        flex-shrink: 0;
      }

      .avatar-placeholder {
        width: 80px;
        height: 80px;
        background: linear-gradient(135deg, #2ecc71, #27ae60);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 2em;
        font-weight: bold;
        color: white;
      }

      .character-info {
        flex: 1;
      }

      .character-info h2 {
        margin: 0 0 5px 0;
        color: #2ecc71;
      }

      .health-mana-bars {
        margin-top: 15px;
      }

      .stat-bar {
        display: flex;
        align-items: center;
        gap: 10px;
        margin: 8px 0;
      }

      .stat-bar label {
        min-width: 60px;
        font-size: 0.9em;
      }

      .bar {
        flex: 1;
        height: 20px;
        background: #2c3e50;
        border-radius: 10px;
        overflow: hidden;
      }

      .health .fill { background: linear-gradient(90deg, #e74c3c, #c0392b); }
      .mana .fill { background: linear-gradient(90deg, #3498db, #2980b9); }

      .character-stats {
        display: flex;
        flex-direction: column;
        gap: 10px;
        min-width: 150px;
      }

      .stat {
        display: flex;
        justify-content: space-between;
      }

      .stat-label {
        color: #bdc3c7;
      }

      .dashboard-tabs {
        display: flex;
        gap: 5px;
        margin-bottom: 20px;
      }

      .tab {
        padding: 12px 20px;
        background: #2c3e50;
        border: none;
        border-radius: 8px 8px 0 0;
        color: #bdc3c7;
        cursor: pointer;
        transition: all 0.3s;
      }

      .tab.active {
        background: #1a1a2e;
        color: #2ecc71;
        border-bottom: 2px solid #2ecc71;
      }

      .tab-content {
        background: #1a1a2e;
        padding: 20px;
        border-radius: 0 10px 10px 10px;
        border: 1px solid #444;
        min-height: 400px;
      }

      .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 20px;
      }

      .stat-group h3 {
        color: #2ecc71;
        margin-bottom: 15px;
      }

      .stat-item {
        display: flex;
        justify-content: space-between;
        padding: 8px 0;
        border-bottom: 1px solid #444;
      }

      .inventory-grid {
        display: grid;
        grid-template-columns: repeat(8, 1fr);
        gap: 5px;
        max-width: 600px;
      }

      .inventory-slot {
        aspect-ratio: 1;
        background: #2c3e50;
        border: 2px solid #444;
        border-radius: 5px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        position: relative;
        cursor: pointer;
      }

      .inventory-slot.empty {
        opacity: 0.3;
      }

      .inventory-slot.common { border-color: #95a5a6; }
      .inventory-slot.uncommon { border-color: #2ecc71; }
      .inventory-slot.rare { border-color: #3498db; }
      .inventory-slot.epic { border-color: #9b59b6; }
      .inventory-slot.legendary { border-color: #f39c12; }

      .item-icon {
        font-size: 1.5em;
        margin-bottom: 5px;
      }

      .item-name {
        font-size: 0.7em;
        text-align: center;
      }

      .item-quantity {
        position: absolute;
        bottom: 2px;
        right: 2px;
        background: #e74c3c;
        color: white;
        border-radius: 50%;
        width: 16px;
        height: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.6em;
      }

      .quest-item {
        background: #2c3e50;
        padding: 15px;
        border-radius: 8px;
        margin-bottom: 15px;
        border: 1px solid #444;
      }

      .quest-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 10px;
      }

      .quest-difficulty.easy { color: #2ecc71; }
      .quest-difficulty.medium { color: #f39c12; }
      .quest-difficulty.hard { color: #e74c3c; }

      .progress-bar {
        flex: 1;
        height: 20px;
        background: #34495e;
        border-radius: 10px;
        overflow: hidden;
        margin-right: 10px;
      }

      .progress-fill {
        height: 100%;
        background: linear-gradient(90deg, #2ecc71, #27ae60);
      }

      .social-container {
        display: grid;
        grid-template-columns: 1fr 2fr;
        gap: 20px;
      }

      .friend-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px;
        background: #2c3e50;
        border-radius: 5px;
        margin-bottom: 10px;
      }

      .friend-avatar {
        width: 40px;
        height: 40px;
        background: #3498db;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;
      }

      .friend-status.online { color: #2ecc71; }
      .friend-status.offline { color: #95a5a6; }

      .chat-container {
        background: #2c3e50;
        border-radius: 8px;
        padding: 15px;
      }

      .chat-messages {
        height: 300px;
        overflow-y: auto;
        background: #34495e;
        padding: 10px;
        border-radius: 5px;
        margin-bottom: 10px;
      }

      .chat-message {
        margin-bottom: 8px;
        font-size: 0.9em;
      }

      .chat-message.system {
        color: #f39c12;
      }

      .message-time {
        color: #95a5a6;
        font-size: 0.8em;
        margin-right: 8px;
      }

      .player-name {
        color: #3498db;
        font-weight: bold;
        margin-right: 5px;
      }

      .chat-input {
        display: flex;
        gap: 10px;
      }

      .form-control {
        flex: 1;
        padding: 8px;
        background: #34495e;
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
      }

      .btn-primary { background: #3498db; color: white; }
      .btn-sm { padding: 5px 10px; font-size: 0.8em; }
    </style>
    """
  end

  # Helper functions
  defp get_character_data(_user_id) do
    %{
      name: "DragonSlayer",
      level: 45,
      class: "Warrior",
      health: 850,
      max_health: 1000,
      health_percent: 85,
      mana: 200,
      max_mana: 300,
      mana_percent: 67,
      experience: 125000,
      next_level_xp: 150000,
      gold: 2450,
      current_zone: "Darkwood Forest",
      attack_power: 245,
      defense: 180,
      crit_chance: 15.5,
      attack_speed: 1.2,
      strength: 85,
      agility: 42,
      intelligence: 28,
      vitality: 78
    }
  end

  defp get_inventory(_user_id) do
    [
      %{id: 1, name: "Health Potion", icon: "🧪", quantity: 5, rarity: "common", usable: true},
      %{id: 2, name: "Mana Potion", icon: "💙", quantity: 3, rarity: "common", usable: true},
      %{id: 3, name: "Dragon Sword", icon: "⚔️", quantity: 1, rarity: "epic", usable: false},
      %{id: 4, name: "Steel Armor", icon: "🛡️", quantity: 1, rarity: "uncommon", usable: false},
      %{id: 5, name: "Magic Ring", icon: "💍", quantity: 1, rarity: "rare", usable: false},
      %{id: 6, name: "Ancient Scroll", icon: "📜", quantity: 2, rarity: "legendary", usable: true},
    ]
  end

  defp get_active_quests(_user_id) do
    [
      %{
        id: 1,
        title: "The Lost Artifact",
        description: "Find the ancient artifact hidden in the Crystal Caves.",
        difficulty: "medium",
        progress: 2,
        total: 5,
        progress_percent: 40,
        xp_reward: 5000,
        gold_reward: 500
      },
      %{
        id: 2,
        title: "Dragon Hunt",
        description: "Defeat the ancient dragon terrorizing the northern villages.",
        difficulty: "hard",
        progress: 1,
        total: 1,
        progress_percent: 0,
        xp_reward: 15000,
        gold_reward: 2000
      }
    ]
  end

  defp get_guild_info(_user_id) do
    %{
      name: "Dragon Hunters",
      level: 12,
      description: "Elite guild focused on challenging content and helping members grow.",
      member_count: 35,
      your_rank: "Officer"
    }
  end

  defp get_friends_list(_user_id) do
    [
      %{name: "MysticMage", status: "online"},
      %{name: "ShadowRogue", status: "online"},
      %{name: "HolyPriest", status: "offline"},
      %{name: "WarriorX", status: "offline"},
    ]
  end

  defp get_server_status do
    %{
      status: "online",
      players: 247
    }
  end

  defp use_item(_user_id, _item_id), do: :ok
  defp accept_quest(_user_id, _quest_id), do: :ok
end