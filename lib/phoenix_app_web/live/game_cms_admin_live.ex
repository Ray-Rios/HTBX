defmodule PhoenixAppWeb.GameCmsAdminLive do
  use PhoenixAppWeb, :live_view
  alias PhoenixApp.{Accounts, GameCMS}
  alias PhoenixApp.GameCMS.{Character, Item, Quest, Guild}

  @impl true
  def mount(_params, session, socket) do
    case session["user_token"] do
      nil ->
        {:ok, redirect(socket, to: "/login")}
      
      token ->
        user = Accounts.get_user_by_session_token(token)
        if user && user.role == :admin do
          if connected?(socket) do
            Phoenix.PubSub.subscribe(PhoenixApp.PubSub, "game:admin")
            :timer.send_interval(30000, self(), :update_stats)
          end
          
          {:ok, assign(socket, 
            user: user,
            page_title: "Game CMS Administration",
            active_tab: "dashboard",
            characters: GameCMS.list_characters(),
            items: GameCMS.list_items(),
            quests: GameCMS.list_quests(),
            guilds: GameCMS.list_guilds(),
            game_stats: GameCMS.get_game_stats(),
            recent_events: GameCMS.list_game_events(),
            chat_messages: GameCMS.list_chat_messages(20),
            # Forms
            character_form: to_form(%{}),
            item_form: to_form(%{}),
            quest_form: to_form(%{}),
            guild_form: to_form(%{}),
            # Edit states
            editing_character: nil,
            editing_item: nil,
            editing_quest: nil,
            editing_guild: nil,
            # Filters
            character_filter: "",
            item_filter: "",
            quest_filter: ""
          )}
        else
          {:ok, redirect(socket, to: "/unauthorized")}
        end
    end
  end

  @impl true
  def handle_info(:update_stats, socket) do
    {:noreply, assign(socket,
      game_stats: GameCMS.get_game_stats(),
      recent_events: GameCMS.list_game_events(),
      chat_messages: GameCMS.list_chat_messages(20)
    )}
  end

  # Tab Navigation
  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, active_tab: tab)}
  end

  # Character CRUD
  @impl true
  def handle_event("new_character", _params, socket) do
    {:noreply, assign(socket, 
      editing_character: :new,
      character_form: to_form(%{})
    )}
  end

  @impl true
  def handle_event("edit_character", %{"id" => id}, socket) do
    character = GameCMS.get_character!(String.to_integer(id))
    form = to_form(Map.from_struct(character))
    
    {:noreply, assign(socket, 
      editing_character: character,
      character_form: form
    )}
  end

  @impl true
  def handle_event("save_character", %{"character" => params}, socket) do
    case socket.assigns.editing_character do
      :new ->
        case GameCMS.create_character(params) do
          {:ok, _character} ->
            {:noreply, socket
             |> put_flash(:info, "Character created successfully")
             |> assign(
               characters: GameCMS.list_characters(),
               editing_character: nil,
               character_form: to_form(%{})
             )}
          {:error, changeset} ->
            {:noreply, socket
             |> put_flash(:error, "Failed to create character")
             |> assign(character_form: to_form(changeset))}
        end
      
      character ->
        case GameCMS.update_character(character, params) do
          {:ok, _character} ->
            {:noreply, socket
             |> put_flash(:info, "Character updated successfully")
             |> assign(
               characters: GameCMS.list_characters(),
               editing_character: nil,
               character_form: to_form(%{})
             )}
          {:error, changeset} ->
            {:noreply, socket
             |> put_flash(:error, "Failed to update character")
             |> assign(character_form: to_form(changeset))}
        end
    end
  end

  @impl true
  def handle_event("delete_character", %{"id" => id}, socket) do
    character = GameCMS.get_character!(String.to_integer(id))
    
    case GameCMS.delete_character(character) do
      {:ok, _character} ->
        {:noreply, socket
         |> put_flash(:info, "Character deleted successfully")
         |> assign(characters: GameCMS.list_characters())}
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete character")}
    end
  end

  # Item CRUD
  @impl true
  def handle_event("new_item", _params, socket) do
    {:noreply, assign(socket, 
      editing_item: :new,
      item_form: to_form(%{})
    )}
  end

  @impl true
  def handle_event("edit_item", %{"id" => id}, socket) do
    item = GameCMS.get_item!(String.to_integer(id))
    form = to_form(Map.from_struct(item))
    
    {:noreply, assign(socket, 
      editing_item: item,
      item_form: form
    )}
  end

  @impl true
  def handle_event("save_item", %{"item" => params}, socket) do
    case socket.assigns.editing_item do
      :new ->
        case GameCMS.create_item(params) do
          {:ok, _item} ->
            {:noreply, socket
             |> put_flash(:info, "Item created successfully")
             |> assign(
               items: GameCMS.list_items(),
               editing_item: nil,
               item_form: to_form(%{})
             )}
          {:error, changeset} ->
            {:noreply, socket
             |> put_flash(:error, "Failed to create item")
             |> assign(item_form: to_form(changeset))}
        end
      
      item ->
        case GameCMS.update_item(item, params) do
          {:ok, _item} ->
            {:noreply, socket
             |> put_flash(:info, "Item updated successfully")
             |> assign(
               items: GameCMS.list_items(),
               editing_item: nil,
               item_form: to_form(%{})
             )}
          {:error, changeset} ->
            {:noreply, socket
             |> put_flash(:error, "Failed to update item")
             |> assign(item_form: to_form(changeset))}
        end
    end
  end

  @impl true
  def handle_event("delete_item", %{"id" => id}, socket) do
    item = GameCMS.get_item!(String.to_integer(id))
    
    case GameCMS.delete_item(item) do
      {:ok, _item} ->
        {:noreply, socket
         |> put_flash(:info, "Item deleted successfully")
         |> assign(items: GameCMS.list_items())}
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete item")}
    end
  end

  @impl true
  def handle_event("cancel_edit", _params, socket) do
    {:noreply, assign(socket,
      editing_character: nil,
      editing_item: nil,
      editing_quest: nil,
      editing_guild: nil,
      character_form: to_form(%{}),
      item_form: to_form(%{}),
      quest_form: to_form(%{}),
      guild_form: to_form(%{})
    )}
  end

  # System actions
  @impl true
  def handle_event("broadcast_message", %{"message" => message}, socket) do
    GameCMS.create_chat_message(%{
      message: message,
      channel: "system",
      message_type: "system",
      user_id: socket.assigns.user.id
    })
    
    Phoenix.PubSub.broadcast(PhoenixApp.PubSub, "game:global", {:system_message, message})
    {:noreply, socket
     |> put_flash(:info, "Message broadcasted to all players")
     |> assign(chat_messages: GameCMS.list_chat_messages(20))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="game-cms-admin">
      <div class="admin-header">
        <h1>🎮 Game CMS Administration</h1>
        <div class="admin-user">
          Welcome, <%= @user.email %> | 
          <a href="/game" target="_blank">Player View</a> | 
          <a href="/logout">Logout</a>
        </div>
      </div>

      <!-- Navigation Tabs -->
      <div class="admin-tabs">
        <button class={"tab #{if @active_tab == "dashboard", do: "active"}"} 
                phx-click="switch_tab" phx-value-tab="dashboard">
          📊 Dashboard
        </button>
        <button class={"tab #{if @active_tab == "characters", do: "active"}"} 
                phx-click="switch_tab" phx-value-tab="characters">
          ⚔️ Characters
        </button>
        <button class={"tab #{if @active_tab == "items", do: "active"}"} 
                phx-click="switch_tab" phx-value-tab="items">
          🎒 Items
        </button>
        <button class={"tab #{if @active_tab == "quests", do: "active"}"} 
                phx-click="switch_tab" phx-value-tab="quests">
          📜 Quests
        </button>
        <button class={"tab #{if @active_tab == "guilds", do: "active"}"} 
                phx-click="switch_tab" phx-value-tab="guilds">
          🏰 Guilds
        </button>
        <button class={"tab #{if @active_tab == "chat", do: "active"}"} 
                phx-click="switch_tab" phx-value-tab="chat">
          💬 Chat
        </button>
        <button class={"tab #{if @active_tab == "graphql", do: "active"}"} 
                phx-click="switch_tab" phx-value-tab="graphql">
          🔗 GraphQL
        </button>
      </div>

      <!-- Tab Content -->
      <div class="tab-content">
        <%= if @active_tab == "dashboard" do %>
          <%= render_dashboard(assigns) %>
        <% end %>

        <%= if @active_tab == "characters" do %>
          <%= render_characters(assigns) %>
        <% end %>

        <%= if @active_tab == "items" do %>
          <%= render_items(assigns) %>
        <% end %>

        <%= if @active_tab == "quests" do %>
          <%= render_quests(assigns) %>
        <% end %>

        <%= if @active_tab == "guilds" do %>
          <%= render_guilds(assigns) %>
        <% end %>

        <%= if @active_tab == "chat" do %>
          <%= render_chat(assigns) %>
        <% end %>

        <%= if @active_tab == "graphql" do %>
          <%= render_graphql(assigns) %>
        <% end %>
      </div>
    </div>

    <style>
      .game-cms-admin {
        background: #0f1419;
        color: white;
        min-height: 100vh;
        font-family: 'Segoe UI', Arial, sans-serif;
        padding: 20px;
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
        margin: 0 5px;
      }

      .admin-tabs {
        display: flex;
        gap: 5px;
        margin-bottom: 20px;
        border-bottom: 1px solid #2c3e50;
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

      .tab:hover:not(.active) {
        background: #34495e;
        color: white;
      }

      .tab-content {
        background: #1a1a2e;
        padding: 20px;
        border-radius: 0 10px 10px 10px;
        border: 1px solid #444;
        min-height: 600px;
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

      .stat-number {
        font-size: 2.5em;
        font-weight: bold;
        margin: 10px 0;
        color: #2ecc71;
      }

      .stat-label {
        color: #bdc3c7;
        font-size: 0.9em;
      }

      .crud-section {
        margin-bottom: 30px;
      }

      .crud-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
      }

      .crud-header h2 {
        color: #2ecc71;
        margin: 0;
      }

      .btn {
        padding: 8px 16px;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        font-weight: bold;
        text-decoration: none;
        display: inline-block;
        transition: all 0.3s;
      }

      .btn-primary { background: #3498db; color: white; }
      .btn-success { background: #2ecc71; color: white; }
      .btn-warning { background: #f39c12; color: white; }
      .btn-danger { background: #e74c3c; color: white; }
      .btn-secondary { background: #95a5a6; color: white; }

      .btn:hover {
        transform: translateY(-1px);
        opacity: 0.9;
      }

      .btn-sm {
        padding: 5px 10px;
        font-size: 0.8em;
      }

      .data-table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 20px;
      }

      .data-table th,
      .data-table td {
        padding: 12px;
        text-align: left;
        border-bottom: 1px solid #444;
      }

      .data-table th {
        background: #2c3e50;
        color: #2ecc71;
        font-weight: bold;
      }

      .data-table tr:hover {
        background: rgba(52, 152, 219, 0.1);
      }

      .form-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 20px;
        margin-bottom: 20px;
      }

      .form-group {
        margin-bottom: 15px;
      }

      .form-group label {
        display: block;
        margin-bottom: 5px;
        color: #bdc3c7;
        font-weight: bold;
      }

      .form-control {
        width: 100%;
        padding: 10px;
        background: #2c3e50;
        border: 1px solid #444;
        border-radius: 5px;
        color: white;
        font-size: 14px;
      }

      .form-control:focus {
        outline: none;
        border-color: #2ecc71;
        box-shadow: 0 0 5px rgba(46, 204, 113, 0.3);
      }

      select.form-control {
        cursor: pointer;
      }

      textarea.form-control {
        resize: vertical;
        min-height: 80px;
      }

      .form-actions {
        display: flex;
        gap: 10px;
        margin-top: 20px;
      }

      .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.8);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
      }

      .modal {
        background: #1a1a2e;
        padding: 30px;
        border-radius: 10px;
        border: 1px solid #444;
        max-width: 600px;
        width: 90%;
        max-height: 80vh;
        overflow-y: auto;
      }

      .modal h3 {
        color: #2ecc71;
        margin-bottom: 20px;
      }

      .rarity-common { color: #95a5a6; }
      .rarity-uncommon { color: #2ecc71; }
      .rarity-rare { color: #3498db; }
      .rarity-epic { color: #9b59b6; }
      .rarity-legendary { color: #f39c12; }
      .rarity-artifact { color: #e74c3c; }

      .difficulty-easy { color: #2ecc71; }
      .difficulty-medium { color: #f39c12; }
      .difficulty-hard { color: #e74c3c; }
      .difficulty-expert { color: #9b59b6; }
      .difficulty-legendary { color: #f1c40f; }

      .graphql-section {
        background: #2c3e50;
        padding: 20px;
        border-radius: 8px;
        margin-bottom: 20px;
      }

      .graphql-section h3 {
        color: #2ecc71;
        margin-bottom: 15px;
      }

      .code-block {
        background: #1a1a1a;
        padding: 15px;
        border-radius: 5px;
        font-family: 'Courier New', monospace;
        font-size: 14px;
        overflow-x: auto;
        border: 1px solid #444;
      }

      .alert {
        padding: 12px 16px;
        border-radius: 5px;
        margin-bottom: 20px;
      }

      .alert-info {
        background: rgba(52, 152, 219, 0.2);
        border: 1px solid #3498db;
        color: #3498db;
      }

      .alert-success {
        background: rgba(46, 204, 113, 0.2);
        border: 1px solid #2ecc71;
        color: #2ecc71;
      }

      .alert-warning {
        background: rgba(243, 156, 18, 0.2);
        border: 1px solid #f39c12;
        color: #f39c12;
      }

      .alert-error {
        background: rgba(231, 76, 60, 0.2);
        border: 1px solid #e74c3c;
        color: #e74c3c;
      }
    </style>
    """
  end

  # Dashboard render function
  defp render_dashboard(assigns) do
    ~H"""
    <div class="dashboard-content">
      <h2>📊 Game Statistics</h2>
      
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-number"><%= @game_stats.total_characters %></div>
          <div class="stat-label">Total Characters</div>
        </div>
        
        <div class="stat-card">
          <div class="stat-number"><%= @game_stats.total_items %></div>
          <div class="stat-label">Total Items</div>
        </div>
        
        <div class="stat-card">
          <div class="stat-number"><%= @game_stats.total_quests %></div>
          <div class="stat-label">Total Quests</div>
        </div>
        
        <div class="stat-card">
          <div class="stat-number"><%= @game_stats.total_guilds %></div>
          <div class="stat-label">Total Guilds</div>
        </div>
        
        <div class="stat-card">
          <div class="stat-number"><%= @game_stats.active_players %></div>
          <div class="stat-label">Active Players</div>
        </div>
      </div>

      <div class="crud-section">
        <h3>📋 Recent Events</h3>
        <div class="events-log" style="max-height: 300px; overflow-y: auto; background: #2c3e50; padding: 15px; border-radius: 5px;">
          <%= for event <- Enum.take(@recent_events, 20) do %>
            <div class="event-item" style="padding: 8px 0; border-bottom: 1px solid #444;">
              <span style="color: #bdc3c7; font-size: 0.8em;"><%= Calendar.strftime(event.inserted_at, "%H:%M:%S") %></span>
              <span style={"color: #{event_color(event.event_type)}; font-weight: bold; margin: 0 10px;"}><%= event.event_type %></span>
              <span><%= event.message %></span>
            </div>
          <% end %>
        </div>
      </div>

      <div class="crud-section">
        <h3>📢 System Broadcast</h3>
        <form phx-submit="broadcast_message" style="display: flex; gap: 10px; align-items: center;">
          <input type="text" name="message" placeholder="Enter system message..." 
                 class="form-control" style="flex: 1;" required>
          <button type="submit" class="btn btn-primary">Broadcast</button>
        </form>
      </div>
    </div>
    """
  end

  # Characters render function
  defp render_characters(assigns) do
    ~H"""
    <div class="characters-content">
      <div class="crud-header">
        <h2>⚔️ Characters Management</h2>
        <button class="btn btn-success" phx-click="new_character">+ New Character</button>
      </div>

      <table class="data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Class</th>
            <th>Level</th>
            <th>Gold</th>
            <th>Zone</th>
            <th>Last Active</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <%= for character <- @characters do %>
            <tr>
              <td><%= character.id %></td>
              <td><%= character.name %></td>
              <td><%= character.class %></td>
              <td><%= character.level %></td>
              <td><%= character.gold %></td>
              <td><%= character.current_zone %></td>
              <td><%= if character.last_active, do: Calendar.strftime(character.last_active, "%Y-%m-%d %H:%M"), else: "Never" %></td>
              <td>
                <button class="btn btn-sm btn-warning" phx-click="edit_character" phx-value-id={character.id}>Edit</button>
                <button class="btn btn-sm btn-danger" phx-click="delete_character" phx-value-id={character.id} 
                        onclick="return confirm('Are you sure?')">Delete</button>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>

      <%= if @editing_character do %>
        <div class="modal-overlay">
          <div class="modal">
            <h3><%= if @editing_character == :new, do: "Create New Character", else: "Edit Character" %></h3>
            
            <.form for={@character_form} phx-submit="save_character">
              <div class="form-grid">
                <div class="form-group">
                  <label>Name</label>
                  <.input field={@character_form[:name]} type="text" class="form-control" required />
                </div>
                
                <div class="form-group">
                  <label>Class</label>
                  <.input field={@character_form[:class]} type="select" 
                          options={[{"Warrior", "Warrior"}, {"Mage", "Mage"}, {"Rogue", "Rogue"}, {"Priest", "Priest"}, {"Archer", "Archer"}]}
                          class="form-control" required />
                </div>
                
                <div class="form-group">
                  <label>Level</label>
                  <.input field={@character_form[:level]} type="number" class="form-control" min="1" max="100" />
                </div>
                
                <div class="form-group">
                  <label>Gold</label>
                  <.input field={@character_form[:gold]} type="number" class="form-control" min="0" />
                </div>
                
                <div class="form-group">
                  <label>Current Zone</label>
                  <.input field={@character_form[:current_zone]} type="text" class="form-control" />
                </div>
                
                <div class="form-group">
                  <label>User ID</label>
                  <.input field={@character_form[:user_id]} type="number" class="form-control" required />
                </div>
              </div>
              
              <div class="form-actions">
                <button type="submit" class="btn btn-success">Save Character</button>
                <button type="button" class="btn btn-secondary" phx-click="cancel_edit">Cancel</button>
              </div>
            </.form>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  # Items render function  
  defp render_items(assigns) do
    ~H"""
    <div class="items-content">
      <div class="crud-header">
        <h2>🎒 Items Management</h2>
        <button class="btn btn-success" phx-click="new_item">+ New Item</button>
      </div>

      <table class="data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Type</th>
            <th>Rarity</th>
            <th>Level Req</th>
            <th>Price</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <%= for item <- @items do %>
            <tr>
              <td><%= item.id %></td>
              <td><%= item.name %></td>
              <td><%= item.item_type %></td>
              <td><span class={"rarity-#{item.rarity}"}><%= item.rarity %></span></td>
              <td><%= item.level_requirement %></td>
              <td><%= item.price %></td>
              <td>
                <button class="btn btn-sm btn-warning" phx-click="edit_item" phx-value-id={item.id}>Edit</button>
                <button class="btn btn-sm btn-danger" phx-click="delete_item" phx-value-id={item.id} 
                        onclick="return confirm('Are you sure?')">Delete</button>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>

      <%= if @editing_item do %>
        <div class="modal-overlay">
          <div class="modal">
            <h3><%= if @editing_item == :new, do: "Create New Item", else: "Edit Item" %></h3>
            
            <.form for={@item_form} phx-submit="save_item">
              <div class="form-grid">
                <div class="form-group">
                  <label>Name</label>
                  <.input field={@item_form[:name]} type="text" class="form-control" required />
                </div>
                
                <div class="form-group">
                  <label>Description</label>
                  <.input field={@item_form[:description]} type="textarea" class="form-control" />
                </div>
                
                <div class="form-group">
                  <label>Type</label>
                  <.input field={@item_form[:item_type]} type="select" 
                          options={[{"weapon", "weapon"}, {"armor", "armor"}, {"accessory", "accessory"}, {"consumable", "consumable"}, {"material", "material"}, {"quest", "quest"}, {"misc", "misc"}]}
                          class="form-control" required />
                </div>
                
                <div class="form-group">
                  <label>Rarity</label>
                  <.input field={@item_form[:rarity]} type="select" 
                          options={[{"common", "common"}, {"uncommon", "uncommon"}, {"rare", "rare"}, {"epic", "epic"}, {"legendary", "legendary"}, {"artifact", "artifact"}]}
                          class="form-control" />
                </div>
                
                <div class="form-group">
                  <label>Level Requirement</label>
                  <.input field={@item_form[:level_requirement]} type="number" class="form-control" min="1" max="100" />
                </div>
                
                <div class="form-group">
                  <label>Price</label>
                  <.input field={@item_form[:price]} type="number" class="form-control" min="0" />
                </div>
                
                <div class="form-group">
                  <label>Icon</label>
                  <.input field={@item_form[:icon]} type="text" class="form-control" placeholder="🗡️" />
                </div>
                
                <div class="form-group">
                  <label>Attack Power</label>
                  <.input field={@item_form[:attack_power]} type="number" class="form-control" min="0" />
                </div>
                
                <div class="form-group">
                  <label>Defense</label>
                  <.input field={@item_form[:defense]} type="number" class="form-control" min="0" />
                </div>
              </div>
              
              <div class="form-actions">
                <button type="submit" class="btn btn-success">Save Item</button>
                <button type="button" class="btn btn-secondary" phx-click="cancel_edit">Cancel</button>
              </div>
            </.form>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  # Placeholder render functions for other tabs
  defp render_quests(assigns), do: ~H"<div>Quests management coming soon...</div>"
  defp render_guilds(assigns), do: ~H"<div>Guilds management coming soon...</div>"
  defp render_chat(assigns), do: ~H"<div>Chat management coming soon...</div>"
  
  defp render_graphql(assigns) do
    ~H"""
    <div class="graphql-content">
      <h2>🔗 GraphQL API Testing</h2>
      
      <div class="alert alert-info">
        <strong>GraphQL Endpoint:</strong> <code>http://localhost:4000/api/graphql</code><br>
        <strong>GraphiQL Interface:</strong> <a href="http://localhost:4000/api/graphiql" target="_blank">http://localhost:4000/api/graphiql</a>
      </div>

      <div class="graphql-section">
        <h3>📝 Sample Queries</h3>
        
        <h4>Get All Characters</h4>
        <div class="code-block">
query {
  characters {
    id
    name
    class
    level
    gold
    currentZone
    user_id
  }
}
        </div>

        <h4>Get All Items</h4>
        <div class="code-block">
query {
  items {
    id
    name
    itemType
    rarity
    levelRequirement
    price
    attackPower
    defense
  }
}
        </div>

        <h4>Get Game Statistics</h4>
        <div class="code-block">
query {
  gameStats {
    totalCharacters
    totalItems
    totalQuests
    totalGuilds
    activePlayers
  }
}
        </div>
      </div>

      <div class="graphql-section">
        <h3>✏️ Sample Mutations</h3>
        
        <h4>Create Character</h4>
        <div class="code-block">
mutation {
  createCharacter(input: {
    name: "TestHero"
    class: "Warrior"
    userId: 1
  }) {
    id
    name
    class
    level
  }
}
        </div>

        <h4>Create Item</h4>
        <div class="code-block">
mutation {
  createItem(input: {
    name: "Magic Sword"
    itemType: "weapon"
    rarity: "rare"
    levelRequirement: 10
    price: 500
    attackPower: 25
  }) {
    id
    name
    rarity
    attackPower
  }
}
        </div>

        <h4>Send Chat Message</h4>
        <div class="code-block">
mutation {
  sendChatMessage(input: {
    message: "Hello from GraphQL!"
    channel: "global"
  }) {
    id
    message
    channel
    insertedAt
  }
}
        </div>
      </div>

      <div class="graphql-section">
        <h3>🔐 Authentication</h3>
        <p>To use authenticated mutations, include the user token in your request headers:</p>
        <div class="code-block">
{
  "Authorization": "Bearer YOUR_USER_TOKEN"
}
        </div>
      </div>
    </div>
    """
  end

  # Helper function for event colors
  defp event_color("player_join"), do: "#2ecc71"
  defp event_color("player_leave"), do: "#e74c3c"
  defp event_color("level_up"), do: "#f39c12"
  defp event_color("quest_complete"), do: "#9b59b6"
  defp event_color("combat"), do: "#e67e22"
  defp event_color(_), do: "#3498db"
end