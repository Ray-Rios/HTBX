# EQEmu to UE5 Migration Guide

## 🎯 **Overview**
Transform EQEmu's C++ codebase into a modern UE5 game with GraphQL API integration, creating a visually stunning EverQuest experience that leverages your existing Phoenix infrastructure.

## 🏗️ **Architecture Transformation**

### **Current EQEmu Architecture**
```
EQEmu C++ Server ←→ MySQL Database ←→ EQ Client
     ↑                    ↑                ↑
Game Logic        Character Data    Legacy UI/Graphics
```

### **New UE5 + Phoenix Architecture**
```
UE5 Game Client ←→ Phoenix GraphQL API ←→ PostgreSQL Database
     ↑                      ↑                     ↑
Modern Graphics      Game Logic/CMS        Unified Data Store
     ↓                      ↓                     ↓
Pixel Streaming ←→ Phoenix LiveView ←→ Admin Dashboard
```

## 🔄 **Migration Strategy**

### **Phase 1: Database Schema Migration**

#### **EQEmu to Phoenix Schema Mapping**
```sql
-- EQEmu Tables → Phoenix Equivalents

-- Characters
eqemu.character_data → phoenix_app.characters
eqemu.character_stats → phoenix_app.character_stats
eqemu.character_skills → phoenix_app.character_skills
eqemu.character_spells → phoenix_app.character_spells

-- Items & Equipment
eqemu.items → phoenix_app.items
eqemu.character_inventory → phoenix_app.character_inventory
eqemu.character_equipment → phoenix_app.character_equipment

-- Guilds & Groups
eqemu.guilds → phoenix_app.guilds
eqemu.guild_members → phoenix_app.guild_members
eqemu.group_id → phoenix_app.groups

-- Zones & NPCs
eqemu.zone → phoenix_app.zones
eqemu.npc_types → phoenix_app.npcs
eqemu.spawn2 → phoenix_app.npc_spawns

-- Quests & Loot
eqemu.tasks → phoenix_app.quests
eqemu.loot_table → phoenix_app.loot_tables
eqemu.merchantlist → phoenix_app.merchant_inventories
```

#### **Phoenix Migration Files**
```elixir
# priv/repo/migrations/20250903000001_create_eqemu_schema.exs
defmodule PhoenixApp.Repo.Migrations.CreateEqemuSchema do
  use Ecto.Migration

  def change do
    # Characters
    create table(:characters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id), null: false
      add :name, :string, null: false
      add :level, :integer, default: 1
      add :race, :integer, null: false
      add :class, :integer, null: false
      add :gender, :integer, default: 0
      add :zone_id, :integer, default: 1
      add :x, :float, default: 0.0
      add :y, :float, default: 0.0
      add :z, :float, default: 0.0
      add :heading, :float, default: 0.0
      add :hp, :integer, default: 100
      add :mana, :integer, default: 0
      add :endurance, :integer, default: 100
      add :experience, :bigint, default: 0
      add :platinum, :integer, default: 0
      add :gold, :integer, default: 0
      add :silver, :integer, default: 0
      add :copper, :integer, default: 0
      add :face, :integer, default: 1
      add :hair_color, :integer, default: 1
      add :hair_style, :integer, default: 1
      add :beard, :integer, default: 0
      add :beard_color, :integer, default: 1
      add :eye_color_1, :integer, default: 1
      add :eye_color_2, :integer, default: 1
      add :drakkin_heritage, :integer, default: 0
      add :drakkin_tattoo, :integer, default: 0
      add :drakkin_details, :integer, default: 0
      add :last_login, :utc_datetime
      add :time_played, :integer, default: 0

      timestamps()
    end

    create unique_index(:characters, [:name])
    create index(:characters, [:user_id])
    create index(:characters, [:level])
    create index(:characters, [:zone_id])

    # Character Stats
    create table(:character_stats, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :character_id, references(:characters, type: :binary_id), null: false
      add :strength, :integer, default: 75
      add :stamina, :integer, default: 75
      add :charisma, :integer, default: 75
      add :dexterity, :integer, default: 75
      add :intelligence, :integer, default: 75
      add :agility, :integer, default: 75
      add :wisdom, :integer, default: 75
      add :attack, :integer, default: 100
      add :ac, :integer, default: 0
      add :hp_regen_rate, :integer, default: 1
      add :mana_regen_rate, :integer, default: 1
      add :endurance_regen_rate, :integer, default: 1

      timestamps()
    end

    create unique_index(:character_stats, [:character_id])

    # Items
    create table(:items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :item_id, :integer, null: false  # Original EQEmu item ID
      add :name, :string, null: false
      add :lore, :text
      add :item_type, :integer, default: 0
      add :icon, :integer, default: 0
      add :weight, :integer, default: 0
      add :no_drop, :boolean, default: false
      add :no_rent, :boolean, default: false
      add :magic, :boolean, default: false
      add :light, :integer, default: 0
      add :delay, :integer, default: 0
      add :damage, :integer, default: 0
      add :range, :integer, default: 0
      add :skill, :integer, default: 0
      add :ac, :integer, default: 0
      add :hp, :integer, default: 0
      add :mana, :integer, default: 0
      add :endur, :integer, default: 0
      add :attack, :integer, default: 0
      add :haste, :integer, default: 0
      add :classes, :integer, default: 0
      add :races, :integer, default: 0
      add :slots, :integer, default: 0
      add :price, :integer, default: 0
      add :sellrate, :float, default: 1.0
      add :cr, :integer, default: 0
      add :dr, :integer, default: 0
      add :pr, :integer, default: 0
      add :mr, :integer, default: 0
      add :fr, :integer, default: 0
      add :str, :integer, default: 0
      add :sta, :integer, default: 0
      add :agi, :integer, default: 0
      add :dex, :integer, default: 0
      add :cha, :integer, default: 0
      add :int, :integer, default: 0
      add :wis, :integer, default: 0

      timestamps()
    end

    create unique_index(:items, [:item_id])
    create index(:items, [:name])
    create index(:items, [:item_type])

    # Character Inventory
    create table(:character_inventory, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :character_id, references(:characters, type: :binary_id), null: false
      add :item_id, references(:items, type: :binary_id), null: false
      add :slot_id, :integer, null: false
      add :charges, :integer, default: 1
      add :color, :integer, default: 0
      add :augment_1, :binary_id
      add :augment_2, :binary_id
      add :augment_3, :binary_id
      add :augment_4, :binary_id
      add :augment_5, :binary_id

      timestamps()
    end

    create unique_index(:character_inventory, [:character_id, :slot_id])
    create index(:character_inventory, [:item_id])

    # Guilds
    create table(:guilds, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :guild_id, :integer, null: false  # Original EQEmu guild ID
      add :name, :string, null: false
      add :leader_id, references(:characters, type: :binary_id)
      add :moto_of_the_day, :text
      add :tribute, :integer, default: 0
      add :url, :string

      timestamps()
    end

    create unique_index(:guilds, [:guild_id])
    create unique_index(:guilds, [:name])

    # Guild Members
    create table(:guild_members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :guild_id, references(:guilds, type: :binary_id), null: false
      add :character_id, references(:characters, type: :binary_id), null: false
      add :rank, :integer, default: 0
      add :tribute, :integer, default: 0
      add :public_note, :text
      add :officer_note, :text

      timestamps()
    end

    create unique_index(:guild_members, [:guild_id, :character_id])

    # Zones
    create table(:zones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :zone_id, :integer, null: false  # Original EQEmu zone ID
      add :short_name, :string, null: false
      add :long_name, :string, null: false
      add :map_file_name, :string
      add :safe_x, :float, default: 0.0
      add :safe_y, :float, default: 0.0
      add :safe_z, :float, default: 0.0
      add :safe_heading, :float, default: 0.0
      add :graveyard_id, :float, default: 0.0
      add :min_level, :integer, default: 1
      add :max_level, :integer, default: 255
      add :min_status, :integer, default: 0
      add :zoneidnumber, :integer, default: 0
      add :version, :integer, default: 0
      add :timezone, :integer, default: 0
      add :maxclients, :integer, default: 0
      add :ruleset, :integer, default: 0
      add :note, :text
      add :underworld, :float, default: 0.0
      add :minclip, :float, default: 450.0
      add :maxclip, :float, default: 450.0
      add :fog_minclip, :float, default: 450.0
      add :fog_maxclip, :float, default: 450.0
      add :fog_blue, :integer, default: 0
      add :fog_red, :integer, default: 0
      add :fog_green, :integer, default: 0
      add :sky, :integer, default: 1
      add :ztype, :integer, default: 1
      add :zone_exp_multiplier, :decimal, default: 0.00
      add :walkspeed, :float, default: 0.4
      add :time_type, :integer, default: 2
      add :fog_red1, :integer, default: 0
      add :fog_green1, :integer, default: 0
      add :fog_blue1, :integer, default: 0
      add :fog_minclip1, :float, default: 450.0
      add :fog_maxclip1, :float, default: 450.0
      add :fog_red2, :integer, default: 0
      add :fog_green2, :integer, default: 0
      add :fog_blue2, :integer, default: 0
      add :fog_minclip2, :float, default: 450.0
      add :fog_maxclip2, :float, default: 450.0
      add :fog_red3, :integer, default: 0
      add :fog_green3, :integer, default: 0
      add :fog_blue3, :integer, default: 0
      add :fog_minclip3, :float, default: 450.0
      add :fog_maxclip3, :float, default: 450.0
      add :fog_red4, :integer, default: 0
      add :fog_green4, :integer, default: 0
      add :fog_blue4, :integer, default: 0
      add :fog_minclip4, :float, default: 450.0
      add :fog_maxclip4, :float, default: 450.0
      add :flag_needed, :string
      add :canbind, :integer, default: 1
      add :cancombat, :integer, default: 1
      add :canlevitate, :integer, default: 1
      add :castoutdoor, :integer, default: 1
      add :hotzone, :integer, default: 0
      add :insttype, :integer, default: 0
      add :shutdowndelay, :bigint, default: 5000
      add :peqzone, :integer, default: 1
      add :expansion, :integer, default: 0
      add :suspendbuffs, :integer, default: 0
      add :rain_chance1, :integer, default: 0
      add :rain_chance2, :integer, default: 0
      add :rain_chance3, :integer, default: 0
      add :rain_chance4, :integer, default: 0
      add :rain_duration1, :integer, default: 0
      add :rain_duration2, :integer, default: 0
      add :rain_duration3, :integer, default: 0
      add :rain_duration4, :integer, default: 0
      add :snow_chance1, :integer, default: 0
      add :snow_chance2, :integer, default: 0
      add :snow_chance3, :integer, default: 0
      add :snow_chance4, :integer, default: 0
      add :snow_duration1, :integer, default: 0
      add :snow_duration2, :integer, default: 0
      add :snow_duration3, :integer, default: 0
      add :snow_duration4, :integer, default: 0
      add :gravity, :float, default: 0.4
      add :type, :integer, default: 0
      add :skylock, :integer, default: 0
      add :fast_regen_hp, :integer, default: 180
      add :fast_regen_mana, :integer, default: 180
      add :fast_regen_endurance, :integer, default: 180
      add :npc_max_aggro_dist, :integer, default: 600
      add :max_movement_update_range, :integer, default: 600

      timestamps()
    end

    create unique_index(:zones, [:zone_id])
    create unique_index(:zones, [:short_name])
    create index(:zones, [:long_name])

    # NPCs
    create table(:npcs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :npc_id, :integer, null: false  # Original EQEmu NPC ID
      add :name, :string, null: false
      add :lastname, :string
      add :level, :integer, default: 1
      add :race, :integer, default: 1
      add :class, :integer, default: 1
      add :bodytype, :integer, default: 1
      add :hp, :integer, default: 100
      add :mana, :integer, default: 0
      add :gender, :integer, default: 0
      add :texture, :integer, default: 0
      add :helmtexture, :integer, default: 0
      add :herosforgemodel, :integer, default: 0
      add :size, :float, default: 6.0
      add :hp_regen_rate, :integer, default: 1
      add :mana_regen_rate, :integer, default: 1
      add :loottable_id, :integer, default: 0
      add :merchant_id, :integer, default: 0
      add :alt_currency_id, :integer, default: 0
      add :npc_spells_id, :integer, default: 0
      add :npc_spells_effects_id, :integer, default: 0
      add :npc_faction_id, :integer, default: 0
      add :adventure_template_id, :integer, default: 0
      add :trap_template, :integer, default: 0
      add :mindmg, :integer, default: 1
      add :maxdmg, :integer, default: 1
      add :attack_count, :integer, default: -1
      add :npcspecialattks, :string
      add :special_abilities, :text
      add :aggroradius, :integer, default: 70
      add :assistradius, :integer, default: 0
      add :face, :integer, default: 1
      add :luclin_hairstyle, :integer, default: 1
      add :luclin_haircolor, :integer, default: 1
      add :luclin_eyecolor, :integer, default: 1
      add :luclin_eyecolor2, :integer, default: 1
      add :luclin_beardcolor, :integer, default: 1
      add :luclin_beard, :integer, default: 0
      add :drakkin_heritage, :integer, default: 0
      add :drakkin_tattoo, :integer, default: 0
      add :drakkin_details, :integer, default: 0
      add :armortint_id, :integer, default: 0
      add :armortint_red, :integer, default: 0
      add :armortint_green, :integer, default: 0
      add :armortint_blue, :integer, default: 0
      add :d_melee_texture1, :integer, default: 0
      add :d_melee_texture2, :integer, default: 0
      add :ammo_idfile, :string, default: "IT10"
      add :prim_melee_type, :integer, default: 28
      add :sec_melee_type, :integer, default: 28
      add :ranged_type, :integer, default: 7
      add :runspeed, :float, default: 1.25
      add :mr, :integer, default: 0
      add :cr, :integer, default: 0
      add :dr, :integer, default: 0
      add :fr, :integer, default: 0
      add :pr, :integer, default: 0
      add :corrup, :integer, default: 0
      add :phr, :integer, default: 0
      add :see_invis, :integer, default: 0
      add :see_invis_undead, :integer, default: 0
      add :qglobal, :integer, default: 0
      add :ac, :integer, default: 0
      add :npc_aggro, :integer, default: 0
      add :spawn_limit, :integer, default: 0
      add :attack_speed, :float, default: 0.0
      add :attack_delay, :integer, default: 30
      add :findable, :integer, default: 0
      add :str, :integer, default: 75
      add :sta, :integer, default: 75
      add :dex, :integer, default: 75
      add :agi, :integer, default: 75
      add :int, :integer, default: 80
      add :wis, :integer, default: 75
      add :cha, :integer, default: 75
      add :see_hide, :integer, default: 0
      add :see_improved_hide, :integer, default: 0
      add :trackable, :integer, default: 1
      add :isbot, :integer, default: 0
      add :exclude, :integer, default: 1
      add :atk, :integer, default: 0
      add :accuracy, :integer, default: 0
      add :avoidance, :integer, default: 0
      add :left_ring_idfile, :string, default: "IT10"
      add :right_ring_idfile, :string, default: "IT10"
      add :exp_pct, :integer, default: 100
      add :greed, :integer, default: 0
      add :engage_notice, :integer, default: 0
      add :ignore_despawn, :integer, default: 0
      add :avoidance_cap, :integer, default: 0

      timestamps()
    end

    create unique_index(:npcs, [:npc_id])
    create index(:npcs, [:name])
    create index(:npcs, [:level])

    # Quests
    create table(:quests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :quest_id, :integer, null: false  # Original EQEmu task ID
      add :type, :integer, default: 0
      add :title, :string, null: false
      add :description, :text
      add :reward_text, :text
      add :completion_emote, :string
      add :turn_in_npc, :integer, default: 0
      add :cash_reward, :integer, default: 0
      add :xp_reward, :integer, default: 0
      add :faction_reward, :integer, default: 0
      add :faction_amount, :integer, default: 0
      add :enabled, :boolean, default: true
      add :repeatable, :boolean, default: false
      add :level_min, :integer, default: 1
      add :level_max, :integer, default: 255
      add :dz_template_id, :integer, default: 0

      timestamps()
    end

    create unique_index(:quests, [:quest_id])
    create index(:quests, [:title])
    create index(:quests, [:enabled])

    # Character Quests (Progress Tracking)
    create table(:character_quests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :character_id, references(:characters, type: :binary_id), null: false
      add :quest_id, references(:quests, type: :binary_id), null: false
      add :slot, :integer, default: 0
      add :type, :integer, default: 0
      add :accepted_time, :utc_datetime
      add :completed_time, :utc_datetime
      add :activity_completed, :integer, default: 0

      timestamps()
    end

    create unique_index(:character_quests, [:character_id, :quest_id])
    create index(:character_quests, [:completed_time])
  end
end
```

### **Phase 2: GraphQL Schema Definition**

#### **Enhanced GraphQL Schema**
```elixir
# lib/phoenix_app_web/schema/eqemu_types.ex
defmodule PhoenixAppWeb.Schema.EqemuTypes do
  use Absinthe.Schema.Notation
  alias PhoenixAppWeb.Resolvers.EqemuResolver

  # Character Types
  object :character do
    field :id, non_null(:id)
    field :user_id, non_null(:id)
    field :name, non_null(:string)
    field :level, :integer
    field :race, :integer
    field :class, :integer
    field :gender, :integer
    field :zone_id, :integer
    field :x, :float
    field :y, :float
    field :z, :float
    field :heading, :float
    field :hp, :integer
    field :mana, :integer
    field :endurance, :integer
    field :experience, :integer
    field :platinum, :integer
    field :gold, :integer
    field :silver, :integer
    field :copper, :integer
    field :face, :integer
    field :hair_color, :integer
    field :hair_style, :integer
    field :beard, :integer
    field :beard_color, :integer
    field :eye_color_1, :integer
    field :eye_color_2, :integer
    field :last_login, :datetime
    field :time_played, :integer
    field :inserted_at, :datetime
    field :updated_at, :datetime

    # Associations
    field :user, :user, resolve: dataloader(PhoenixApp.Accounts)
    field :stats, :character_stats, resolve: dataloader(PhoenixApp.EqemuGame)
    field :inventory, list_of(:character_inventory), resolve: dataloader(PhoenixApp.EqemuGame)
    field :guild_membership, :guild_member, resolve: dataloader(PhoenixApp.EqemuGame)
    field :quests, list_of(:character_quest), resolve: dataloader(PhoenixApp.EqemuGame)
    field :zone, :zone, resolve: dataloader(PhoenixApp.EqemuGame)
  end

  object :character_stats do
    field :id, non_null(:id)
    field :character_id, non_null(:id)
    field :strength, :integer
    field :stamina, :integer
    field :charisma, :integer
    field :dexterity, :integer
    field :intelligence, :integer
    field :agility, :integer
    field :wisdom, :integer
    field :attack, :integer
    field :ac, :integer
    field :hp_regen_rate, :integer
    field :mana_regen_rate, :integer
    field :endurance_regen_rate, :integer

    field :character, :character, resolve: dataloader(PhoenixApp.EqemuGame)
  end

  object :item do
    field :id, non_null(:id)
    field :item_id, :integer
    field :name, non_null(:string)
    field :lore, :string
    field :item_type, :integer
    field :icon, :integer
    field :weight, :integer
    field :no_drop, :boolean
    field :no_rent, :boolean
    field :magic, :boolean
    field :light, :integer
    field :delay, :integer
    field :damage, :integer
    field :range, :integer
    field :skill, :integer
    field :ac, :integer
    field :hp, :integer
    field :mana, :integer
    field :endur, :integer
    field :attack, :integer
    field :haste, :integer
    field :classes, :integer
    field :races, :integer
    field :slots, :integer
    field :price, :integer
    field :sellrate, :float
    field :cr, :integer
    field :dr, :integer
    field :pr, :integer
    field :mr, :integer
    field :fr, :integer
    field :str, :integer
    field :sta, :integer
    field :agi, :integer
    field :dex, :integer
    field :cha, :integer
    field :int, :integer
    field :wis, :integer
  end

  object :character_inventory do
    field :id, non_null(:id)
    field :character_id, non_null(:id)
    field :item_id, non_null(:id)
    field :slot_id, :integer
    field :charges, :integer
    field :color, :integer

    field :character, :character, resolve: dataloader(PhoenixApp.EqemuGame)
    field :item, :item, resolve: dataloader(PhoenixApp.EqemuGame)
  end

  object :guild do
    field :id, non_null(:id)
    field :guild_id, :integer
    field :name, non_null(:string)
    field :leader_id, :id
    field :moto_of_the_day, :string
    field :tribute, :integer
    field :url, :string

    field :leader, :character, resolve: dataloader(PhoenixApp.EqemuGame)
    field :members, list_of(:guild_member), resolve: dataloader(PhoenixApp.EqemuGame)
  end

  object :guild_member do
    field :id, non_null(:id)
    field :guild_id, non_null(:id)
    field :character_id, non_null(:id)
    field :rank, :integer
    field :tribute, :integer
    field :public_note, :string
    field :officer_note, :string

    field :guild, :guild, resolve: dataloader(PhoenixApp.EqemuGame)
    field :character, :character, resolve: dataloader(PhoenixApp.EqemuGame)
  end

  object :zone do
    field :id, non_null(:id)
    field :zone_id, :integer
    field :short_name, non_null(:string)
    field :long_name, non_null(:string)
    field :map_file_name, :string
    field :safe_x, :float
    field :safe_y, :float
    field :safe_z, :float
    field :safe_heading, :float
    field :min_level, :integer
    field :max_level, :integer
    field :expansion, :integer

    field :characters, list_of(:character), resolve: dataloader(PhoenixApp.EqemuGame)
    field :npcs, list_of(:npc_spawn), resolve: dataloader(PhoenixApp.EqemuGame)
  end

  object :npc do
    field :id, non_null(:id)
    field :npc_id, :integer
    field :name, non_null(:string)
    field :lastname, :string
    field :level, :integer
    field :race, :integer
    field :class, :integer
    field :hp, :integer
    field :mana, :integer
    field :gender, :integer
    field :texture, :integer
    field :size, :float
    field :loottable_id, :integer
    field :merchant_id, :integer
    field :aggroradius, :integer
    field :assistradius, :integer
  end

  object :quest do
    field :id, non_null(:id)
    field :quest_id, :integer
    field :type, :integer
    field :title, non_null(:string)
    field :description, :string
    field :reward_text, :string
    field :completion_emote, :string
    field :cash_reward, :integer
    field :xp_reward, :integer
    field :enabled, :boolean
    field :repeatable, :boolean
    field :level_min, :integer
    field :level_max, :integer

    field :character_progress, list_of(:character_quest), resolve: dataloader(PhoenixApp.EqemuGame)
  end

  object :character_quest do
    field :id, non_null(:id)
    field :character_id, non_null(:id)
    field :quest_id, non_null(:id)
    field :slot, :integer
    field :type, :integer
    field :accepted_time, :datetime
    field :completed_time, :datetime
    field :activity_completed, :integer

    field :character, :character, resolve: dataloader(PhoenixApp.EqemuGame)
    field :quest, :quest, resolve: dataloader(PhoenixApp.EqemuGame)
  end

  # Input Types for Mutations
  input_object :character_input do
    field :name, non_null(:string)
    field :race, non_null(:integer)
    field :class, non_null(:integer)
    field :gender, :integer
    field :face, :integer
    field :hair_color, :integer
    field :hair_style, :integer
    field :beard, :integer
    field :beard_color, :integer
    field :eye_color_1, :integer
    field :eye_color_2, :integer
  end

  input_object :character_update_input do
    field :zone_id, :integer
    field :x, :float
    field :y, :float
    field :z, :float
    field :heading, :float
    field :hp, :integer
    field :mana, :integer
    field :endurance, :integer
    field :experience, :integer
    field :platinum, :integer
    field :gold, :integer
    field :silver, :integer
    field :copper, :integer
  end

  input_object :inventory_update_input do
    field :item_id, non_null(:id)
    field :slot_id, non_null(:integer)
    field :charges, :integer
    field :color, :integer
  end

  # Queries
  object :eqemu_queries do
    @desc "Get character by ID"
    field :character, :character do
      arg :id, non_null(:id)
      resolve &EqemuResolver.get_character/3
    end

    @desc "Get characters for current user"
    field :my_characters, list_of(:character) do
      resolve &EqemuResolver.list_user_characters/3
    end

    @desc "Get character inventory"
    field :character_inventory, list_of(:character_inventory) do
      arg :character_id, non_null(:id)
      resolve &EqemuResolver.get_character_inventory/3
    end

    @desc "Get all items"
    field :items, list_of(:item) do
      arg :filter, :string
      arg :item_type, :integer
      arg :limit, :integer, default_value: 50
      arg :offset, :integer, default_value: 0
      resolve &EqemuResolver.list_items/3
    end

    @desc "Get item by ID"
    field :item, :item do
      arg :id, :id
      arg :item_id, :integer
      resolve &EqemuResolver.get_item/3
    end

    @desc "Get all zones"
    field :zones, list_of(:zone) do
      resolve &EqemuResolver.list_zones/3
    end

    @desc "Get zone by ID"
    field :zone, :zone do
      arg :id, :id
      arg :zone_id, :integer
      arg :short_name, :string
      resolve &EqemuResolver.get_zone/3
    end

    @desc "Get guild by ID"
    field :guild, :guild do
      arg :id, non_null(:id)
      resolve &EqemuResolver.get_guild/3
    end

    @desc "Get character's guild"
    field :character_guild, :guild do
      arg :character_id, non_null(:id)
      resolve &EqemuResolver.get_character_guild/3
    end

    @desc "Get available quests for character"
    field :available_quests, list_of(:quest) do
      arg :character_id, non_null(:id)
      resolve &EqemuResolver.get_available_quests/3
    end

    @desc "Get character's active quests"
    field :character_quests, list_of(:character_quest) do
      arg :character_id, non_null(:id)
      resolve &EqemuResolver.get_character_quests/3
    end
  end

  # Mutations
  object :eqemu_mutations do
    @desc "Create a new character"
    field :create_character, :character do
      arg :input, non_null(:character_input)
      resolve &EqemuResolver.create_character/3
    end

    @desc "Update character position and stats"
    field :update_character, :character do
      arg :id, non_null(:id)
      arg :input, non_null(:character_update_input)
      resolve &EqemuResolver.update_character/3
    end

    @desc "Delete character"
    field :delete_character, :character do
      arg :id, non_null(:id)
      resolve &EqemuResolver.delete_character/3
    end

    @desc "Update character inventory"
    field :update_inventory, :character_inventory do
      arg :character_id, non_null(:id)
      arg :input, non_null(:inventory_update_input)
      resolve &EqemuResolver.update_inventory/3
    end

    @desc "Join guild"
    field :join_guild, :guild_member do
      arg :character_id, non_null(:id)
      arg :guild_id, non_null(:id)
      resolve &EqemuResolver.join_guild/3
    end

    @desc "Leave guild"
    field :leave_guild, :guild_member do
      arg :character_id, non_null(:id)
      resolve &EqemuResolver.leave_guild/3
    end

    @desc "Accept quest"
    field :accept_quest, :character_quest do
      arg :character_id, non_null(:id)
      arg :quest_id, non_null(:id)
      resolve &EqemuResolver.accept_quest/3
    end

    @desc "Complete quest"
    field :complete_quest, :character_quest do
      arg :character_id, non_null(:id)
      arg :quest_id, non_null(:id)
      resolve &EqemuResolver.complete_quest/3
    end

    @desc "Zone character to new zone"
    field :zone_character, :character do
      arg :character_id, non_null(:id)
      arg :zone_id, non_null(:integer)
      arg :x, :float
      arg :y, :float
      arg :z, :float
      arg :heading, :float
      resolve &EqemuResolver.zone_character/3
    end
  end

  # Subscriptions for real-time updates
  object :eqemu_subscriptions do
    @desc "Subscribe to character updates"
    field :character_updated, :character do
      arg :character_id, non_null(:id)
      
      config fn args, _info ->
        {:ok, topic: "character:#{args.character_id}"}
      end
    end

    @desc "Subscribe to zone updates"
    field :zone_updated, :zone do
      arg :zone_id, non_null(:integer)
      
      config fn args, _info ->
        {:ok, topic: "zone:#{args.zone_id}"}
      end
    end

    @desc "Subscribe to guild updates"
    field :guild_updated, :guild do
      arg :guild_id, non_null(:id)
      
      config fn args, _info ->
        {:ok, topic: "guild:#{args.guild_id}"}
      end
    end
  end
end
```

### **Phase 3: UE5 C++ Integration**

#### **UE5 Game Mode with Phoenix Integration**
```cpp
// Source/EQEmuUE5/EQEmuGameMode.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "Engine/World.h"
#include "Http.h"
#include "Json.h"
#include "WebSocketsModule.h"
#include "IWebSocket.h"
#include "EQEmuGameMode.generated.h"

UCLASS()
class EQEMUUE5_API AEQEmuGameMode : public AGameModeBase
{
    GENERATED_BODY()

public:
    AEQEmuGameMode();

protected:
    virtual void BeginPlay() override;
    virtual void EndPlay(const EEndPlayReason::Type EndPlayReason) override;

    // Phoenix API Integration
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Phoenix API")
    FString PhoenixAPIUrl = TEXT("http://localhost:4000/api/graphql");

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Phoenix API")
    FString PhoenixWebSocketUrl = TEXT("ws://localhost:4000/socket/websocket");

    // WebSocket Connection
    TSharedPtr<IWebSocket> WebSocket;

    // HTTP Module
    FHttpModule* HttpModule;

public:
    // Character Management
    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void LoadCharacter(const FString& CharacterId);

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void SaveCharacterPosition(const FString& CharacterId, FVector Position, float Heading);

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void UpdateCharacterStats(const FString& CharacterId, int32 HP, int32 Mana, int32 Endurance);

    // Zone Management
    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void LoadZone(int32 ZoneId);

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void ZoneCharacter(const FString& CharacterId, int32 NewZoneId, FVector Position);

    // Inventory Management
    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void LoadCharacterInventory(const FString& CharacterId);

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void UpdateInventorySlot(const FString& CharacterId, int32 SlotId, const FString& ItemId);

    // Quest System
    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void LoadAvailableQuests(const FString& CharacterId);

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void AcceptQuest(const FString& CharacterId, const FString& QuestId);

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void CompleteQuest(const FString& CharacterId, const FString& QuestId);

private:
    // GraphQL Query Helpers
    void SendGraphQLQuery(const FString& Query, TFunction<void(TSharedPtr<FJsonObject>)> OnSuccess);
    void SendGraphQLMutation(const FString& Mutation, TFunction<void(TSharedPtr<FJsonObject>)> OnSuccess);

    // WebSocket Event Handlers
    void OnWebSocketConnected();
    void OnWebSocketMessage(const FString& Message);
    void OnWebSocketClosed(int32 StatusCode, const FString& Reason, bool bWasClean);

    // Character Data
    UPROPERTY()
    TMap<FString, class AEQEmuCharacter*> LoadedCharacters;

    // Zone Data
    UPROPERTY()
    TMap<int32, class AEQEmuZone*> LoadedZones;

    // Current User Session
    FString CurrentUserId;
    FString AuthToken;
};
```

#### **UE5 Character Class**
```cpp
// Source/EQEmuUE5/EQEmuCharacter.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "Components/StaticMeshComponent.h"
#include "Components/SkeletalMeshComponent.h"
#include "EQEmuCharacter.generated.h"

USTRUCT(BlueprintType)
struct FEQEmuCharacterData
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    FString CharacterId;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    FString Name;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Level = 1;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Race = 1;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Class = 1;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Gender = 0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 HP = 100;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 MaxHP = 100;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Mana = 0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 MaxMana = 0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Endurance = 100;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 MaxEndurance = 100;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int64 Experience = 0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Platinum = 0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Gold = 0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Silver = 0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Copper = 0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 ZoneId = 1;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    FVector Position = FVector::ZeroVector;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    float Heading = 0.0f;
};

USTRUCT(BlueprintType)
struct FEQEmuCharacterStats
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Strength = 75;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Stamina = 75;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Charisma = 75;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Dexterity = 75;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Intelligence = 75;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Agility = 75;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Wisdom = 75;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Attack = 100;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 AC = 0;
};

UCLASS()
class EQEMUUE5_API AEQEmuCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    AEQEmuCharacter();

protected:
    virtual void BeginPlay() override;

public:
    virtual void Tick(float DeltaTime) override;
    virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;

    // Character Data
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "EQEmu")
    FEQEmuCharacterData CharacterData;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "EQEmu")
    FEQEmuCharacterStats CharacterStats;

    // Equipment Meshes
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Equipment")
    UStaticMeshComponent* HelmetMesh;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Equipment")
    UStaticMeshComponent* ChestMesh;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Equipment")
    UStaticMeshComponent* LegsMesh;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Equipment")
    UStaticMeshComponent* FeetMesh;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Equipment")
    UStaticMeshComponent* WeaponMesh;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Equipment")
    UStaticMeshComponent* ShieldMesh;

    // Character Functions
    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void LoadCharacterData(const FEQEmuCharacterData& Data);

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void UpdateCharacterStats(const FEQEmuCharacterStats& Stats);

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void EquipItem(int32 SlotId, const FString& ItemId);

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void UnequipItem(int32 SlotId);

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void TakeDamage(int32 Damage);

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void RestoreHP(int32 Amount);

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void RestoreMana(int32 Amount);

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void GainExperience(int64 Amount);

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void AddMoney(int32 Plat, int32 Gold, int32 Silver, int32 Copper);

    // Events
    UFUNCTION(BlueprintImplementableEvent, Category = "EQEmu")
    void OnCharacterDataLoaded();

    UFUNCTION(BlueprintImplementableEvent, Category = "EQEmu")
    void OnStatsUpdated();

    UFUNCTION(BlueprintImplementableEvent, Category = "EQEmu")
    void OnItemEquipped(int32 SlotId, const FString& ItemId);

    UFUNCTION(BlueprintImplementableEvent, Category = "EQEmu")
    void OnLevelUp(int32 NewLevel);

private:
    // Auto-save timer
    FTimerHandle SaveTimerHandle;
    void AutoSaveCharacter();

    // Stat regeneration
    FTimerHandle RegenTimerHandle;
    void RegenerateStats();

    // Equipment mapping
    TMap<int32, UStaticMeshComponent*> EquipmentSlots;
    void InitializeEquipmentSlots();
    void UpdateEquipmentMesh(int32 SlotId, const FString& ItemId);
};
```

#### **UE5 Zone System**
```cpp
// Source/EQEmuUE5/EQEmuZone.h
#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Components/StaticMeshComponent.h"
#include "Engine/StaticMesh.h"
#include "EQEmuZone.generated.h"

USTRUCT(BlueprintType)
struct FEQEmuZoneData
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 ZoneId;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    FString ShortName;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    FString LongName;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    FString MapFileName;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    FVector SafePosition = FVector::ZeroVector;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    float SafeHeading = 0.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 MinLevel = 1;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 MaxLevel = 255;

    UPROPERTY(EditAnywhere, BlueprintReadWrite)
    int32 Expansion = 0;
};

UCLASS()
class EQEMUUE5_API AEQEmuZone : public AActor
{
    GENERATED_BODY()

public:
    AEQEmuZone();

protected:
    virtual void BeginPlay() override;

public:
    virtual void Tick(float DeltaTime) override;

    // Zone Data
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "EQEmu")
    FEQEmuZoneData ZoneData;

    // Zone Mesh
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Zone")
    UStaticMeshComponent* ZoneMesh;

    // NPCs in this zone
    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Zone")
    TArray<class AEQEmuNPC*> NPCs;

    // Zone Functions
    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void LoadZoneData(const FEQEmuZoneData& Data);

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void SpawnNPCs();

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    void DespawnNPCs();

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    FVector GetSafePosition() const;

    UFUNCTION(BlueprintCallable, Category = "EQEmu")
    bool IsValidLevel(int32 CharacterLevel) const;

    // Events
    UFUNCTION(BlueprintImplementableEvent, Category = "EQEmu")
    void OnZoneLoaded();

    UFUNCTION(BlueprintImplementableEvent, Category = "EQEmu")
    void OnCharacterEntered(class AEQEmuCharacter* Character);

    UFUNCTION(BlueprintImplementableEvent, Category = "EQEmu")
    void OnCharacterExited(class AEQEmuCharacter* Character);

private:
    // Zone loading
    void LoadZoneMesh();
    void LoadZoneTextures();
    void SetupZoneCollision();
};
```

## 🎯 **Benefits of UE5 + GraphQL Integration**

### **Modern Game Engine**
- **Stunning Graphics**: Modern rendering, lighting, and effects
- **Performance**: Optimized for modern hardware
- **Cross-Platform**: PC, Console, Mobile support
- **VR/AR Ready**: Future-proof for immersive experiences

### **Unified API System**
- **Single Source of Truth**: All game data through GraphQL
- **Real-time Updates**: Subscriptions for live data
- **Type Safety**: Strong typing across client/server
- **Caching**: Efficient data management with Apollo/Relay

### **Scalable Architecture**
- **Microservices**: Separate concerns (auth, game, cms)
- **Horizontal Scaling**: Scale components independently
- **Cloud Ready**: Deploy on AWS, GCP, Azure
- **DevOps Friendly**: Docker, Kubernetes support

This migration transforms EQEmu into a modern, scalable MMO platform while preserving all the classic gameplay mechanics that make EverQuest special!