```elixir
# lib/phoenix_app_web/live/eqemu_admin_live.ex
defmodule PhoenixAppWeb.EqemuAdminLive do
  use PhoenixAppWeb, :live_view
  alias PhoenixApp.EqemuGame

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    
    if user && user.is_admin do
      characters = EqemuGame.list_characters()
      items = EqemuGame.list_items(limit: 100)
      zones = EqemuGame.list_zones()
      
      {:ok, assign(socket,
        page_title: "EQEmu Administration",
        characters: characters,
        items: items,
        zones: zones,
        selected_character: nil,
        view_mode: :characters,
        search_query: ""
      )}
    else
      {:ok, redirect(socket, to: "/login")}
    end
  end

  def handle_params(%{"view" => view}, _uri, socket) do
    {:noreply, assign(socket, view_mode: String.to_atom(view))}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("switch_view", %{"view" => view}, socket) do
    {:noreply, push_patch(socket, to: "/eqemu/admin?view=#{view}")}
  end

  def handle_event("search", %{"query" => query}, socket) do
    case socket.assigns.view_mode do
      :characters ->
        characters = EqemuGame.search_characters(query)
        {:noreply, assign(socket, characters: characters, search_query: query)}
      
      :items ->
        items = EqemuGame.search_items(query)
        {:noreply, assign(socket, items: items, search_query: query)}
      
      :zones ->
        zones = EqemuGame.search_zones(query)
        {:noreply, assign(socket, zones: zones, search_query: query)}
      
      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("select_character", %{"character_id" => character_id}, socket) do
    character = EqemuGame.get_character_with_details(character_id)
    {:noreply, assign(socket, selected_character: character)}
  end

  def handle_event("create_character", character_params, socket) do
    case EqemuGame.create_character(character_params) do
      {:ok, character} ->
        characters = EqemuGame.list_characters()
        {:noreply, assign(socket, characters: characters) 
         |> put_flash(:info, "Character '#{character.name}' created successfully")}
      
      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create character")}
    end
  end

  def handle_event("update_character", %{"character_id" => character_id} = params, socket) do
    character = EqemuGame.get_character!(character_id)
    
    case EqemuGame.update_character(character, params) do
      {:ok, updated_character} ->
        characters = EqemuGame.list_characters()
        {:noreply, assign(socket, 
          characters: characters,
          selected_character: updated_character
        ) |> put_flash(:info, "Character updated successfully")}
      
      {:error, changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update character")}
    end
  end

  def handle_event("delete_character", %{"character_id" => character_id}, socket) do
    character = EqemuGame.get_character!(character_id)
    
    case EqemuGame.delete_character(character) do
      {:ok, _} ->
        characters = EqemuGame.list_characters()
        {:noreply, assign(socket, 
          characters: characters,
          selected_character: nil
        ) |> put_flash(:info, "Character deleted successfully")}
      
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete character")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="starry-background min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-indigo-900">
      <div class="stars-container">
        <div class="stars"></div>
        <div class="stars2"></div>
        <div class="stars3"></div>
      </div>
      
      <div class="container mx-auto px-4 py-8 relative z-10">
        <!-- Header -->
        <div class="flex justify-between items-center mb-8">
          <h1 class="text-3xl font-bold text-white">🏰 EQEmu Administration</h1>
          <div class="flex items-center space-x-4">
            <.link navigate="/eqemu/player" class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg">
              🎮 Player View
            </.link>
            <.link navigate="/eqemu/server" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg">
              🖥️ Server Control
            </.link>
          </div>
        </div>

        <!-- Navigation Tabs -->
        <div class="bg-gray-800 rounded-lg p-4 mb-6">
          <div class="flex space-x-4">
            <button phx-click="switch_view" phx-value-view="characters"
                    class={["px-4 py-2 rounded-lg transition-colors",
                           if(@view_mode == :characters, do: "bg-blue-600 text-white", else: "bg-gray-700 text-gray-300 hover:bg-gray-600")]}>
              👤 Characters
            </button>
            <button phx-click="switch_view" phx-value-view="items"
                    class={["px-4 py-2 rounded-lg transition-colors",
                           if(@view_mode == :items, do: "bg-blue-600 text-white", else: "bg-gray-700 text-gray-300 hover:bg-gray-600")]}>
              ⚔️ Items
            </button>
            <button phx-click="switch_view" phx-value-view="zones"
                    class={["px-4 py-2 rounded-lg transition-colors",
                           if(@view_mode == :zones, do: "bg-blue-600 text-white", else: "bg-gray-700 text-gray-300 hover:bg-gray-600")]}>
              🗺️ Zones
            </button>
            <button phx-click="switch_view" phx-value-view="guilds"
                    class={["px-4 py-2 rounded-lg transition-colors",
                           if(@view_mode == :guilds, do: "bg-blue-600 text-white", else: "bg-gray-700 text-gray-300 hover:bg-gray-600")]}>
              🏛️ Guilds
            </button>
            <button phx-click="switch_view" phx-value-view="quests"
                    class={["px-4 py-2 rounded-lg transition-colors",
                           if(@view_mode == :quests, do: "bg-blue-600 text-white", else: "bg-gray-700 text-gray-300 hover:bg-gray-600")]}>
              📜 Quests
            </button>
          </div>
        </div>

        <!-- Search Bar -->
        <div class="bg-gray-800 rounded-lg p-4 mb-6">
          <form phx-change="search" class="flex items-center">
            <div class="relative flex-1">
              <input type="text" name="query" value={@search_query} 
                     placeholder={"Search #{@view_mode}..."}
                     class="w-full bg-gray-700 text-white px-4 py-2 pl-10 rounded-lg focus:ring-2 focus:ring-blue-500" />
              <div class="absolute left-3 top-2.5 text-gray-400">🔍</div>
            </div>
          </form>
        </div>

        <!-- Content Area -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <!-- Main Content -->
          <div class="lg:col-span-2">
            <!-- Characters View -->
            <div :if={@view_mode == :characters} class="bg-gray-800 rounded-lg p-6">
              <div class="flex justify-between items-center mb-4">
                <h2 class="text-xl font-bold text-white">👤 Characters</h2>
                <button class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg">
                  ➕ Create Character
                </button>
              </div>
              
              <div class="overflow-x-auto">
                <table class="w-full">
                  <thead class="bg-gray-700">
                    <tr>
                      <th class="px-4 py-3 text-left text-white">Name</th>
                      <th class="px-4 py-3 text-left text-white">Level</th>
                      <th class="px-4 py-3 text-left text-white">Race</th>
                      <th class="px-4 py-3 text-left text-white">Class</th>
                      <th class="px-4 py-3 text-left text-white">Zone</th>
                      <th class="px-4 py-3 text-left text-white">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <%= for character <- @characters do %>
                      <tr class="border-b border-gray-700 hover:bg-gray-700 transition-colors">
                        <td class="px-4 py-3 text-white font-medium"><%= character.name %></td>
                        <td class="px-4 py-3 text-gray-300"><%= character.level %></td>
                        <td class="px-4 py-3 text-gray-300"><%= get_race_name(character.race) %></td>
                        <td class="px-4 py-3 text-gray-300"><%= get_class_name(character.class) %></td>
                        <td class="px-4 py-3 text-gray-300"><%= character.zone_id %></td>
                        <td class="px-4 py-3">
                          <div class="flex space-x-2">
                            <button phx-click="select_character" phx-value-character_id={character.id}
                                    class="text-blue-400 hover:text-blue-300 text-sm">👁️ View</button>
                            <button class="text-yellow-400 hover:text-yellow-300 text-sm">✏️ Edit</button>
                            <button phx-click="delete_character" phx-value-character_id={character.id}
                                    class="text-red-400 hover:text-red-300 text-sm"
                                    onclick="return confirm('Delete this character?')">🗑️ Delete</button>
                          </div>
                        </td>
                      </tr>
                    <% end %>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- Items View -->
            <div :if={@view_mode == :items} class="bg-gray-800 rounded-lg p-6">
              <div class="flex justify-between items-center mb-4">
                <h2 class="text-xl font-bold text-white">⚔️ Items</h2>
                <button class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg">
                  ➕ Create Item
                </button>
              </div>
              
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <%= for item <- @items do %>
                  <div class="bg-gray-700 rounded-lg p-4 hover:bg-gray-600 transition-colors">
                    <div class="flex items-center space-x-3 mb-2">
                      <div class="text-2xl"><%= get_item_icon(item.item_type) %></div>
                      <div>
                        <h3 class="text-white font-medium"><%= item.name %></h3>
                        <p class="text-gray-400 text-sm">ID: <%= item.item_id %></p>
                      </div>
                    </div>
                    
                    <div class="text-sm text-gray-300 space-y-1">
                      <%= if item.damage > 0 do %>
                        <div>⚔️ Damage: <%= item.damage %></div>
                      <% end %>
                      <%= if item.ac > 0 do %>
                        <div>🛡️ AC: <%= item.ac %></div>
                      <% end %>
                      <%= if item.weight > 0 do %>
                        <div>⚖️ Weight: <%= item.weight %></div>
                      <% end %>
                    </div>
                    
                    <div class="mt-3 flex space-x-2">
                      <button class="text-blue-400 hover:text-blue-300 text-sm">👁️ View</button>
                      <button class="text-yellow-400 hover:text-yellow-300 text-sm">✏️ Edit</button>
                    </div>
                  </div>
                <% end %>
              </div>
            </div>

            <!-- Zones View -->
            <div :if={@view_mode == :zones} class="bg-gray-800 rounded-lg p-6">
              <div class="flex justify-between items-center mb-4">
                <h2 class="text-xl font-bold text-white">🗺️ Zones</h2>
                <button class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg">
                  ➕ Create Zone
                </button>
              </div>
              
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <%= for zone <- @zones do %>
                  <div class="bg-gray-700 rounded-lg p-4 hover:bg-gray-600 transition-colors">
                    <div class="flex justify-between items-start mb-2">
                      <div>
                        <h3 class="text-white font-medium"><%= zone.long_name %></h3>
                        <p class="text-gray-400 text-sm"><%= zone.short_name %> (ID: <%= zone.zone_id %>)</p>
                      </div>
                      <div class="text-2xl">🏰</div>
                    </div>
                    
                    <div class="text-sm text-gray-300 space-y-1">
                      <div>📊 Level Range: <%= zone.min_level %>-<%= zone.max_level %></div>
                      <div>🎯 Safe Point: (<%= Float.round(zone.safe_x, 1) %>, <%= Float.round(zone.safe_y, 1) %>, <%= Float.round(zone.safe_z, 1) %>)</div>
                      <%= if zone.expansion > 0 do %>
                        <div>📦 Expansion: <%= zone.expansion %></div>
                      <% end %>
                    </div>
                    
                    <div class="mt-3 flex space-x-2">
                      <button class="text-blue-400 hover:text-blue-300 text-sm">👁️ View</button>
                      <button class="text-yellow-400 hover:text-yellow-300 text-sm">✏️ Edit</button>
                      <button class="text-green-400 hover:text-green-300 text-sm">🚀 Load</button>
                    </div>
                  </div>
                <% end %>
              </div>
            </div>
          </div>

          <!-- Sidebar -->
          <div class="lg:col-span-1">
            <!-- Character Details -->
            <%= if @selected_character do %>
              <div class="bg-gray-800 rounded-lg p-6 mb-6">
                <h3 class="text-xl font-bold text-white mb-4">👤 Character Details</h3>
                
                <div class="space-y-3">
                  <div class="flex justify-between">
                    <span class="text-gray-400">Name:</span>
                    <span class="text-white font-medium"><%= @selected_character.name %></span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-gray-400">Level:</span>
                    <span class="text-white"><%= @selected_character.level %></span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-gray-400">Race:</span>
                    <span class="text-white"><%= get_race_name(@selected_character.race) %></span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-gray-400">Class:</span>
                    <span class="text-white"><%= get_class_name(@selected_character.class) %></span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-gray-400">HP:</span>
                    <span class="text-green-400"><%= @selected_character.hp %></span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-gray-400">Mana:</span>
                    <span class="text-blue-400"><%= @selected_character.mana %></span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-gray-400">Experience:</span>
                    <span class="text-purple-400"><%= @selected_character.experience %></span>
                  </div>
                </div>

                <!-- Character Stats -->
                <%= if @selected_character.stats do %>
                  <div class="mt-6">
                    <h4 class="text-lg font-medium text-white mb-3">📊 Stats</h4>
                    <div class="grid grid-cols-2 gap-2 text-sm">
                      <div class="flex justify-between">
                        <span class="text-gray-400">STR:</span>
                        <span class="text-white"><%= @selected_character.stats.strength %></span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-400">STA:</span>
                        <span class="text-white"><%= @selected_character.stats.stamina %></span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-400">AGI:</span>
                        <span class="text-white"><%= @selected_character.stats.agility %></span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-400">DEX:</span>
                        <span class="text-white"><%= @selected_character.stats.dexterity %></span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-400">INT:</span>
                        <span class="text-white"><%= @selected_character.stats.intelligence %></span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-400">WIS:</span>
                        <span class="text-white"><%= @selected_character.stats.wisdom %></span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-400">CHA:</span>
                        <span class="text-white"><%= @selected_character.stats.charisma %></span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-400">AC:</span>
                        <span class="text-white"><%= @selected_character.stats.ac %></span>
                      </div>
                    </div>
                  </div>
                <% end %>

                <div class="mt-6 space-y-2">
                  <button class="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-lg">
                    ✏️ Edit Character
                  </button>
                  <button class="w-full bg-green-600 hover:bg-green-700 text-white py-2 rounded-lg">
                    🎒 View Inventory
                  </button>
                  <button class="w-full bg-purple-600 hover:bg-purple-700 text-white py-2 rounded-lg">
                    📜 View Quests
                  </button>
                </div>
              </div>
            <% end %>

            <!-- Quick Stats -->
            <div class="bg-gray-800 rounded-lg p-6">
              <h3 class="text-xl font-bold text-white mb-4">📊 Quick Stats</h3>
              
              <div class="space-y-3">
                <div class="flex justify-between">
                  <span class="text-gray-400">Total Characters:</span>
                  <span class="text-white font-medium"><%= length(@characters) %></span>
                </div>
                <div class="flex justify-between">
                  <span class="text-gray-400">Total Items:</span>
                  <span class="text-white font-medium"><%= length(@items) %></span>
                </div>
                <div class="flex justify-between">
                  <span class="text-gray-400">Total Zones:</span>
                  <span class="text-white font-medium"><%= length(@zones) %></span>
                </div>
                <div class="flex justify-between">
                  <span class="text-gray-400">Online Players:</span>
                  <span class="text-green-400 font-medium">0</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Helper functions for display
  defp get_race_name(race_id) do
    case race_id do
      1 -> "Human"
      2 -> "Barbarian"
      3 -> "Erudite"
      4 -> "Wood Elf"
      5 -> "High Elf"
      6 -> "Dark Elf"
      7 -> "Half Elf"
      8 -> "Dwarf"
      9 -> "Troll"
      10 -> "Ogre"
      11 -> "Halfling"
      12 -> "Gnome"
      128 -> "Iksar"
      130 -> "Vah Shir"
      330 -> "Froglok"
      522 -> "Drakkin"
      _ -> "Unknown (#{race_id})"
    end
  end

  defp get_class_name(class_id) do
    case class_id do
      1 -> "Warrior"
      2 -> "Cleric"
      3 -> "Paladin"
      4 -> "Ranger"
      5 -> "Shadow Knight"
      6 -> "Druid"
      7 -> "Monk"
      8 -> "Bard"
      9 -> "Rogue"
      10 -> "Shaman"
      11 -> "Necromancer"
      12 -> "Wizard"
      13 -> "Magician"
      14 -> "Enchanter"
      15 -> "Beastlord"
      16 -> "Berserker"
      _ -> "Unknown (#{class_id})"
    end
  end

  defp get_item_icon(item_type) do
    case item_type do
      0 -> "📦"  # 1H Slashing
      1 -> "⚔️"  # 2H Slashing
      2 -> "🗡️"  # 1H Piercing
      3 -> "🔱"  # 1H Blunt
      4 -> "🔨"  # 2H Blunt
      5 -> "🏹"  # Archery
      8 -> "🛡️"  # Shield
      10 -> "👕" # Armor
      11 -> "💍" # Jewelry
      20 -> "🍖" # Food
      21 -> "🍺" # Drink
      22 -> "💡" # Light
      23 -> "📜" # Combinable
      25 -> "🎒" # Container
      _ -> "❓"
    end
  end
end
```