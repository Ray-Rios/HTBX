# lib/phoenix_app_web/live/eqemu_player_live.ex
defmodule PhoenixAppWeb.EqemuPlayerLive do
  use PhoenixAppWeb, :live_view
  alias PhoenixApp.EqemuGame

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    
    if user do
      characters = EqemuGame.list_user_characters(user)
      
      {:ok, assign(socket,
        page_title: "EverQuest",
        characters: characters,
        selected_character: nil,
        game_state: :character_select,
        zones: EqemuGame.list_zones()
      )}
    else
      {:ok, redirect(socket, to: "/login")}
    end
  end

  def handle_event("select_character", %{"character_id" => character_id}, socket) do
    character = EqemuGame.get_character_with_details(character_id)
    
    {:noreply, assign(socket, 
      selected_character: character,
      game_state: :in_game
    )}
  end

  def handle_event("create_character", character_params, socket) do
    user = socket.assigns.current_user
    
    case EqemuGame.create_character(Map.put(character_params, "user_id", user.id)) do
      {:ok, character} ->
        characters = EqemuGame.list_user_characters(user)
        {:noreply, assign(socket, characters: characters)
         |> put_flash(:info, "Character '#{character.name}' created successfully")}
      
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create character")}
    end
  end

  def handle_event("enter_world", _params, socket) do
    character = socket.assigns.selected_character
    
    # Initialize character in world
    EqemuGame.enter_world(character)
    
    {:noreply, assign(socket, game_state: :playing)}
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
        <!-- Character Select Screen -->
        <%= if @game_state == :character_select do %>
          <div class="max-w-4xl mx-auto">
            <div class="text-center mb-8">
              <h1 class="text-4xl font-bold text-white mb-2">⚔️ EverQuest</h1>
              <p class="text-gray-300">Select your character to enter Norrath</p>
            </div>

            <!-- Character List -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
              <%= for character <- @characters do %>
                <div class="bg-gray-800 rounded-lg p-6 hover:bg-gray-700 transition-colors cursor-pointer"
                     phx-click="select_character" phx-value-character_id={character.id}>
                  <div class="text-center mb-4">
                    <div class="text-4xl mb-2"><%= get_character_avatar(character.race, character.gender) %></div>
                    <h3 class="text-xl font-bold text-white"><%= character.name %></h3>
                    <p class="text-gray-400">Level <%= character.level %> <%= get_race_name(character.race) %> <%= get_class_name(character.class) %></p>
                  </div>
                  
                  <div class="space-y-2 text-sm">
                    <div class="flex justify-between">
                      <span class="text-gray-400">Zone:</span>
                      <span class="text-white"><%= get_zone_name(character.zone_id, @zones) %></span>
                    </div>
                    <div class="flex justify-between">
                      <span class="text-gray-400">Last Played:</span>
                      <span class="text-white">
                        <%= if character.last_login do %>
                          <%= Calendar.strftime(character.last_login, "%m/%d/%Y") %>
                        <% else %>
                          Never
                        <% end %>
                      </span>
                    </div>
                  </div>
                </div>
              <% end %>

              <!-- Create New Character -->
              <div class="bg-gray-800 border-2 border-dashed border-gray-600 rounded-lg p-6 hover:border-blue-500 transition-colors cursor-pointer text-center">
                <div class="text-4xl text-gray-400 mb-4">➕</div>
                <h3 class="text-lg font-medium text-white mb-2">Create New Character</h3>
                <p class="text-gray-400 text-sm">Start your adventure in Norrath</p>
              </div>
            </div>

            <!-- Quick Actions -->
            <div class="text-center">
              <.link navigate="/eqemu/admin" class="bg-gray-600 hover:bg-gray-700 text-white px-6 py-2 rounded-lg mr-4">
                🛠️ Admin Panel
              </.link>
              <.link navigate="/dashboard" class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg">
                🏠 Dashboard
              </.link>
            </div>
          </div>
        <% end %>

        <!-- In-Game Interface -->
        <%= if @game_state == :in_game && @selected_character do %>
          <div class="grid grid-cols-1 lg:grid-cols-4 gap-6 h-screen">
            <!-- Game World (Placeholder for UE5 integration) -->
            <div class="lg:col-span-3 bg-black rounded-lg relative">
              <div id="game-world" class="w-full h-full rounded-lg flex items-center justify-center">
                <div class="text-center text-white">
                  <div class="text-6xl mb-4">🏰</div>
                  <h2 class="text-2xl font-bold mb-2">Welcome to <%= get_zone_name(@selected_character.zone_id, @zones) %></h2>
                  <p class="text-gray-300 mb-6">UE5 Game World will render here</p>
                  <button phx-click="enter_world" class="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg">
                    🚀 Enter World
                  </button>
                </div>
              </div>
            </div>

            <!-- Character Panel -->
            <div class="lg:col-span-1 space-y-4">
              <!-- Character Info -->
              <div class="bg-gray-800 rounded-lg p-4">
                <h3 class="text-lg font-bold text-white mb-3">👤 Character</h3>
                <div class="text-center mb-4">
                  <div class="text-3xl mb-2"><%= get_character_avatar(@selected_character.race, @selected_character.gender) %></div>
                  <h4 class="text-white font-medium"><%= @selected_character.name %></h4>
                  <p class="text-gray-400 text-sm">Level <%= @selected_character.level %> <%= get_class_name(@selected_character.class) %></p>
                </div>
                
                <!-- Health/Mana Bars -->
                <div class="space-y-2">
                  <div>
                    <div class="flex justify-between text-sm mb-1">
                      <span class="text-red-400">HP</span>
                      <span class="text-white"><%= @selected_character.hp %></span>
                    </div>
                    <div class="w-full bg-gray-700 rounded-full h-2">
                      <div class="bg-red-500 h-2 rounded-full" style={"width: #{(@selected_character.hp / 100) * 100}%"}></div>
                    </div>
                  </div>
                  
                  <div>
                    <div class="flex justify-between text-sm mb-1">
                      <span class="text-blue-400">Mana</span>
                      <span class="text-white"><%= @selected_character.mana %></span>
                    </div>
                    <div class="w-full bg-gray-700 rounded-full h-2">
                      <div class="bg-blue-500 h-2 rounded-full" style={"width: #{(@selected_character.mana / 100) * 100}%"}></div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Inventory (Placeholder) -->
              <div class="bg-gray-800 rounded-lg p-4">
                <h3 class="text-lg font-bold text-white mb-3">🎒 Inventory</h3>
                <div class="grid grid-cols-4 gap-2">
                  <%= for i <- 1..16 do %>
                    <div class="bg-gray-700 border border-gray-600 rounded aspect-square flex items-center justify-center text-gray-400">
                      <%= if rem(i, 3) == 0 do %>
                        <div class="text-lg">⚔️</div>
                      <% else %>
                        <div class="text-xs">#{i}</div>
                      <% end %>
                    </div>
                  <% end %>
                </div>
              </div>

              <!-- Chat (Placeholder) -->
              <div class="bg-gray-800 rounded-lg p-4">
                <h3 class="text-lg font-bold text-white mb-3">💬 Chat</h3>
                <div class="bg-gray-900 rounded p-2 h-32 overflow-y-auto text-sm">
                  <div class="text-green-400">[OOC] Welcome to EverQuest!</div>
                  <div class="text-yellow-400">[Say] You say, 'Hail!'</div>
                  <div class="text-blue-400">[Guild] Guild chat coming soon...</div>
                </div>
                <input type="text" placeholder="Type your message..." 
                       class="w-full mt-2 bg-gray-700 text-white px-3 py-1 rounded text-sm" />
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # Helper functions
  defp get_character_avatar(race, gender) do
    case {race, gender} do
      {1, 0} -> "🧙‍♂️"  # Human Male
      {1, 1} -> "🧙‍♀️"  # Human Female
      {2, 0} -> "🏔️"   # Barbarian Male
      {2, 1} -> "❄️"   # Barbarian Female
      {8, 0} -> "⛏️"   # Dwarf Male
      {8, 1} -> "💎"   # Dwarf Female
      {4, 0} -> "🏹"   # Wood Elf Male
      {4, 1} -> "🌿"   # Wood Elf Female
      _ -> "👤"
    end
  end

  defp get_zone_name(zone_id, zones) do
    case Enum.find(zones, &(&1.zone_id == zone_id)) do
      nil -> "Unknown Zone"
      zone -> zone.long_name
    end
  end

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
      _ -> "Unknown"
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
      _ -> "Unknown"
    end
  end
end