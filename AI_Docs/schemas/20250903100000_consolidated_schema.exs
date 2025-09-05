defmodule PhoenixApp.Repo.Migrations.ConsolidatedSchema do
  use Ecto.Migration

  def change do
    # ============================================================================
    # EQEMU GAME SYSTEM - Simplified & Consolidated
    # ============================================================================
    
    # Characters (combines game_characters + eqemu_characters)
    create_if_not_exists table(:characters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id), null: false
      
      # Basic character info
      add :name, :string, null: false
      add :level, :integer, default: 1
      add :race, :integer, default: 1  # EQ race IDs
      add :class, :integer, default: 1  # EQ class IDs
      add :gender, :integer, default: 0
      
      # Position & Zone
      add :zone_id, :integer, default: 1
      add :x, :float, default: 0.0
      add :y, :float, default: 0.0
      add :z, :float, default: 0.0
      add :heading, :float, default: 0.0
      
      # Core Stats
      add :hp, :integer, default: 100
      add :max_hp, :integer, default: 100
      add :mana, :integer, default: 0
      add :max_mana, :integer, default: 0
      add :endurance, :integer, default: 100
      add :max_endurance, :integer, default: 100
      
      # Attributes
      add :strength, :integer, default: 75
      add :stamina, :integer, default: 75
      add :charisma, :integer, default: 75
      add :dexterity, :integer, default: 75
      add :intelligence, :integer, default: 75
      add :agility, :integer, default: 75
      add :wisdom, :integer, default: 75
      
      # Currency
      add :platinum, :integer, default: 0
      add :gold, :integer, default: 0
      add :silver, :integer, default: 0
      add :copper, :integer, default: 0
      
      # Experience
      add :experience, :integer, default: 0
      add :aa_points, :integer, default: 0
      
      # Appearance
      add :face, :integer, default: 1
      add :hair_color, :integer, default: 1
      add :hair_style, :integer, default: 1
      add :beard, :integer, default: 0
      add :beard_color, :integer, default: 1
      add :eye_color_1, :integer, default: 1
      add :eye_color_2, :integer, default: 1
      
      # Guild
      add :guild_id, references(:guilds, type: :binary_id)
      add :guild_rank, :integer, default: 0
      
      # Timestamps
      add :last_login, :utc_datetime
      add :time_played, :integer, default: 0
      
      timestamps()
    end

    create unique_index(:characters, [:name])
    create index(:characters, [:user_id])
    create index(:characters, [:level])
    create index(:characters, [:zone_id])
    create index(:characters, [:race, :class])
    create index(:characters, [:guild_id])

    # ============================================================================
    # ITEMS SYSTEM - Essential Fields Only
    # ============================================================================
    
    create_if_not_exists table(:items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      
      # Basic item info
      add :name, :string, null: false
      add :description, :text
      add :item_type, :integer, default: 0  # 0=misc, 1=weapon, 2=armor, etc.
      add :icon, :integer, default: 0
      add :weight, :integer, default: 0
      add :size, :integer, default: 0
      add :price, :integer, default: 0
      
      # Combat stats
      add :damage, :integer, default: 0
      add :delay, :integer, default: 0
      add :ac, :integer, default: 0
      add :range, :integer, default: 0
      
      # Stat bonuses
      add :hp_bonus, :integer, default: 0
      add :mana_bonus, :integer, default: 0
      add :endurance_bonus, :integer, default: 0
      add :str_bonus, :integer, default: 0
      add :sta_bonus, :integer, default: 0
      add :cha_bonus, :integer, default: 0
      add :dex_bonus, :integer, default: 0
      add :int_bonus, :integer, default: 0
      add :agi_bonus, :integer, default: 0
      add :wis_bonus, :integer, default: 0
      
      # Resistances
      add :magic_resist, :integer, default: 0
      add :fire_resist, :integer, default: 0
      add :cold_resist, :integer, default: 0
      add :disease_resist, :integer, default: 0
      add :poison_resist, :integer, default: 0
      
      # Restrictions
      add :classes, :integer, default: 0  # Bitmask for allowed classes
      add :races, :integer, default: 0    # Bitmask for allowed races
      add :slots, :integer, default: 0    # Bitmask for equipment slots
      add :level_required, :integer, default: 0
      
      # Flags
      add :no_drop, :boolean, default: false
      add :no_rent, :boolean, default: false
      add :magic, :boolean, default: false
      add :stackable, :boolean, default: false
      add :max_stack, :integer, default: 1
      
      timestamps()
    end

    create index(:items, [:name])
    create index(:items, [:item_type])
    create index(:items, [:level_required])
    create index(:items, [:classes])
    create index(:items, [:races])

    # ============================================================================
    # CHARACTER INVENTORY
    # ============================================================================
    
    create_if_not_exists table(:character_inventory, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :character_id, references(:characters, type: :binary_id), null: false
      add :item_id, references(:items, type: :binary_id), null: false
      add :slot_id, :integer, null: false  # Equipment slot or bag slot
      add :charges, :integer, default: 1
      add :color, :integer, default: 0

      timestamps()
    end

    create unique_index(:character_inventory, [:character_id, :slot_id])
    create index(:character_inventory, [:item_id])

    # ============================================================================
    # GUILDS SYSTEM
    # ============================================================================
    
    create_if_not_exists table(:guilds, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :leader_id, references(:characters, type: :binary_id)
      add :level, :integer, default: 1
      add :experience, :integer, default: 0
      add :max_members, :integer, default: 50
      add :guild_type, :string, default: "casual"
      add :motd, :text  # Message of the day
      add :active, :boolean, default: true

      timestamps()
    end

    create unique_index(:guilds, [:name])
    create index(:guilds, [:leader_id])
    create index(:guilds, [:active])

    # ============================================================================
    # ZONES SYSTEM
    # ============================================================================
    
    create_if_not_exists table(:zones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :zone_id, :integer, null: false  # EQ zone ID
      add :short_name, :string, null: false
      add :long_name, :string, null: false
      add :description, :text
      
      # Safe spawn point
      add :safe_x, :float, default: 0.0
      add :safe_y, :float, default: 0.0
      add :safe_z, :float, default: 0.0
      add :safe_heading, :float, default: 0.0
      
      # Level restrictions
      add :min_level, :integer, default: 1
      add :max_level, :integer, default: 255
      
      # Zone properties
      add :max_clients, :integer, default: 100
      add :expansion, :integer, default: 0
      add :zone_type, :string, default: "outdoor"  # outdoor, dungeon, city, etc.
      add :pvp_enabled, :boolean, default: false
      add :active, :boolean, default: true

      timestamps()
    end

    create unique_index(:zones, [:zone_id])
    create unique_index(:zones, [:short_name])
    create index(:zones, [:min_level, :max_level])
    create index(:zones, [:expansion])
    create index(:zones, [:active])

    # ============================================================================
    # QUESTS SYSTEM
    # ============================================================================
    
    create_if_not_exists table(:quests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :description, :text, null: false
      add :objective, :text, null: false
      add :difficulty, :string, default: "easy"
      add :level_requirement, :integer, default: 1
      add :zone_id, references(:zones, type: :binary_id)
      
      # Rewards
      add :xp_reward, :integer, default: 100
      add :gold_reward, :integer, default: 50
      add :item_rewards, {:array, :binary_id}, default: []
      
      # Quest properties
      add :repeatable, :boolean, default: false
      add :max_completions, :integer, default: 1
      add :active, :boolean, default: true

      timestamps()
    end

    create index(:quests, [:level_requirement])
    create index(:quests, [:zone_id])
    create index(:quests, [:active])

    # Character quest progress
    create_if_not_exists table(:character_quests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :character_id, references(:characters, type: :binary_id), null: false
      add :quest_id, references(:quests, type: :binary_id), null: false
      add :status, :string, default: "active"  # active, completed, failed
      add :progress, :map, default: %{}
      add :completed_at, :utc_datetime

      timestamps()
    end

    create unique_index(:character_quests, [:character_id, :quest_id])
    create index(:character_quests, [:status])

    # ============================================================================
    # GAME SESSIONS (for real-time gameplay)
    # ============================================================================
    
    create_if_not_exists table(:game_sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id), null: false
      add :character_id, references(:characters, type: :binary_id)
      add :session_token, :text, null: false
      add :is_active, :boolean, default: true
      add :last_heartbeat, :utc_datetime, default: fragment("NOW()")
      
      # Current session state
      add :current_zone_id, :integer
      add :current_x, :float, default: 0.0
      add :current_y, :float, default: 0.0
      add :current_z, :float, default: 0.0
      add :current_heading, :float, default: 0.0

      timestamps()
    end

    create unique_index(:game_sessions, [:session_token])
    create index(:game_sessions, [:user_id])
    create index(:game_sessions, [:character_id])
    create index(:game_sessions, [:is_active])

    # ============================================================================
    # GAME EVENTS (for logging and analytics)
    # ============================================================================
    
    create_if_not_exists table(:game_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :session_id, references(:game_sessions, type: :binary_id)
      add :character_id, references(:characters, type: :binary_id)
      add :event_type, :string, null: false
      add :event_data, :map, default: %{}
      add :server_timestamp, :utc_datetime, default: fragment("NOW()")

      timestamps()
    end

    create index(:game_events, [:session_id])
    create index(:game_events, [:character_id])
    create index(:game_events, [:event_type])
    create index(:game_events, [:server_timestamp])

    # ============================================================================
    # PERFORMANCE INDEXES
    # ============================================================================
    
    # Common query patterns
    create index(:characters, [:user_id, :level])
    create index(:items, [:item_type, :level_required])
    create index(:character_inventory, [:character_id, :item_id])
    create index(:game_sessions, [:user_id, :is_active])
  end
end