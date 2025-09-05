defmodule PhoenixAppWeb.Schema.EqemuTypes do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  alias PhoenixAppWeb.Resolvers.EqemuResolver

  # Character Types
  object :eqemu_character do
    field :id, non_null(:id)
    field :user_id, non_null(:id)
    field :character_id, :integer
    field :name, non_null(:string)
    field :level, :integer
    field :race, :integer
    field :race_name, :string do
      resolve fn character, _, _ ->
        {:ok, PhoenixApp.EqemuGame.get_race_name(character.race)}
      end
    end
    field :class, :integer
    field :class_name, :string do
      resolve fn character, _, _ ->
        {:ok, PhoenixApp.EqemuGame.get_class_name(character.class)}
      end
    end
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
    field :deity, :integer
    field :guild_id, :integer
    field :last_login, :datetime
    field :time_played, :integer
    field :inserted_at, :datetime
    field :updated_at, :datetime

    # Associations
    field :user, :user, resolve: dataloader(PhoenixApp.Accounts)
    field :stats, :eqemu_character_stats, resolve: dataloader(PhoenixApp.EqemuGame)
    field :inventory, list_of(:eqemu_character_inventory), resolve: dataloader(PhoenixApp.EqemuGame)
    field :guild_membership, :eqemu_guild_member, resolve: dataloader(PhoenixApp.EqemuGame)
    field :character_tasks, list_of(:eqemu_character_task), resolve: dataloader(PhoenixApp.EqemuGame)
  end

  object :eqemu_character_stats do
    field :id, non_null(:id)
    field :character_id, non_null(:id)
    field :str, :integer
    field :sta, :integer
    field :cha, :integer
    field :dex, :integer
    field :int, :integer
    field :agi, :integer
    field :wis, :integer
    field :atk, :integer
    field :ac, :integer
    field :hp_regen_rate, :integer
    field :mana_regen_rate, :integer
    field :endurance_regen_rate, :integer
    field :heroic_str, :integer
    field :heroic_sta, :integer
    field :heroic_cha, :integer
    field :heroic_dex, :integer
    field :heroic_int, :integer
    field :heroic_agi, :integer
    field :heroic_wis, :integer
    field :mr, :integer
    field :fr, :integer
    field :cr, :integer
    field :pr, :integer
    field :dr, :integer
    field :corrup, :integer

    field :character, :eqemu_character, resolve: dataloader(PhoenixApp.EqemuGame)
  end

  object :eqemu_item do
    field :id, non_null(:id)
    field :item_id, :integer
    field :name, non_null(:string)
    field :lore, :string
    field :item_type, :integer
    field :item_type_name, :string do
      resolve fn item, _, _ ->
        {:ok, PhoenixApp.EqemuGame.Item.item_type_name(item)}
      end
    end
    field :icon, :integer
    field :weight, :integer
    field :nodrop, :integer
    field :norent, :integer
    field :magic, :integer
    field :light, :integer
    field :delay, :integer
    field :damage, :integer
    field :range_, :integer
    field :ac, :integer
    field :hp, :integer
    field :mana, :integer
    field :endur, :integer
    field :atk, :integer
    field :haste, :integer
    field :classes, :integer
    field :races, :integer
    field :price, :integer
    field :sellrate, :float
    field :cr, :integer
    field :dr, :integer
    field :pr, :integer
    field :mr, :integer
    field :fr, :integer
    field :astr, :integer
    field :asta, :integer
    field :aagi, :integer
    field :adex, :integer
    field :acha, :integer
    field :aint, :integer
    field :awis, :integer
  end

  object :eqemu_character_inventory do
    field :id, non_null(:id)
    field :character_id, non_null(:id)
    field :item_id, non_null(:id)
    field :slotid, :integer
    field :charges, :integer
    field :color, :integer

    field :character, :eqemu_character, resolve: dataloader(PhoenixApp.EqemuGame)
    field :item, :eqemu_item, resolve: dataloader(PhoenixApp.EqemuGame)
  end

  object :eqemu_guild do
    field :id, non_null(:id)
    field :guild_id, :integer
    field :name, non_null(:string)
    field :leader, :integer
    field :moto_of_the_day, :string
    field :url, :string
    field :tribute, :integer

    field :members, list_of(:eqemu_guild_member), resolve: dataloader(PhoenixApp.EqemuGame)
  end

  object :eqemu_guild_member do
    field :id, non_null(:id)
    field :guild_id, non_null(:id)
    field :character_id, non_null(:id)
    field :rank_, :integer
    field :tribute_enable, :integer
    field :public_note, :string
    field :officer_note, :string

    field :guild, :eqemu_guild, resolve: dataloader(PhoenixApp.EqemuGame)
    field :character, :eqemu_character, resolve: dataloader(PhoenixApp.EqemuGame)
  end

  object :eqemu_zone do
    field :id, non_null(:id)
    field :zoneidnumber, :integer
    field :short_name, non_null(:string)
    field :long_name, non_null(:string)
    field :safe_x, :float
    field :safe_y, :float
    field :safe_z, :float
    field :safe_heading, :float
    field :min_level, :integer
    field :expansion, :integer

    field :characters, list_of(:eqemu_character), resolve: dataloader(PhoenixApp.EqemuGame)
    field :npc_spawns, list_of(:eqemu_npc_spawn), resolve: dataloader(PhoenixApp.EqemuGame)
  end

  object :eqemu_npc do
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

  object :eqemu_npc_spawn do
    field :id, non_null(:id)
    field :spawn_id, :integer
    field :zone_id, non_null(:id)
    field :npc_id, non_null(:id)
    field :x, :float
    field :y, :float
    field :z, :float
    field :heading, :float
    field :respawntime, :integer
    field :enabled, :integer

    field :zone, :eqemu_zone, resolve: dataloader(PhoenixApp.EqemuGame)
    field :npc, :eqemu_npc, resolve: dataloader(PhoenixApp.EqemuGame)
  end

  object :eqemu_spell do
    field :id, non_null(:id)
    field :spell_id, :integer
    field :name, non_null(:string)
    field :you_cast, :string
    field :other_casts, :string
    field :cast_on_you, :string
    field :cast_on_other, :string
    field :spell_fades, :string
    field :range_, :integer
    field :cast_time, :integer
    field :mana, :integer
    field :icon, :integer
    field :skill, :integer
    field :targettype, :integer
    field :classes1, :integer
    field :classes2, :integer
    field :classes3, :integer
    field :classes4, :integer
    field :classes5, :integer
    field :classes6, :integer
    field :classes7, :integer
    field :classes8, :integer
    field :classes9, :integer
    field :classes10, :integer
    field :classes11, :integer
    field :classes12, :integer
    field :classes13, :integer
    field :classes14, :integer
    field :classes15, :integer
    field :classes16, :integer
  end

  object :eqemu_task do
    field :id, non_null(:id)
    field :task_id, :integer
    field :type, :integer
    field :title, non_null(:string)
    field :description, :string
    field :reward, :string
    field :cashreward, :integer
    field :xpreward, :integer
    field :minlevel, :integer
    field :maxlevel, :integer
    field :repeatable, :integer

    field :character_progress, list_of(:eqemu_character_task), resolve: dataloader(PhoenixApp.EqemuGame)
  end

  object :eqemu_character_task do
    field :id, non_null(:id)
    field :character_id, non_null(:id)
    field :task_id, non_null(:id)
    field :slot, :integer
    field :type, :integer
    field :acceptedtime, :datetime
    field :completedtime, :datetime

    field :character, :eqemu_character, resolve: dataloader(PhoenixApp.EqemuGame)
    field :task, :eqemu_task, resolve: dataloader(PhoenixApp.EqemuGame)
  end

  # Input Types for Mutations
  input_object :eqemu_character_input do
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
    field :deity, :integer
  end

  input_object :eqemu_character_update_input do
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

  input_object :eqemu_inventory_update_input do
    field :item_id, non_null(:id)
    field :slotid, non_null(:integer)
    field :charges, :integer
    field :color, :integer
  end

  # Queries
  object :eqemu_queries do
    @desc "Get character by ID"
    field :eqemu_character, :eqemu_character do
      arg :id, non_null(:id)
      resolve &EqemuResolver.get_character/3
    end

    @desc "Get characters for current user"
    field :my_eqemu_characters, list_of(:eqemu_character) do
      resolve &EqemuResolver.list_user_characters/3
    end

    @desc "Get character inventory"
    field :eqemu_character_inventory, list_of(:eqemu_character_inventory) do
      arg :character_id, non_null(:id)
      resolve &EqemuResolver.get_character_inventory/3
    end

    @desc "Get all items"
    field :eqemu_items, list_of(:eqemu_item) do
      arg :filter, :string
      arg :item_type, :integer
      arg :limit, :integer, default_value: 50
      arg :offset, :integer, default_value: 0
      resolve &EqemuResolver.list_items/3
    end

    @desc "Get item by ID"
    field :eqemu_item, :eqemu_item do
      arg :id, :id
      arg :item_id, :integer
      resolve &EqemuResolver.get_item/3
    end

    @desc "Get all zones"
    field :eqemu_zones, list_of(:eqemu_zone) do
      resolve &EqemuResolver.list_zones/3
    end

    @desc "Get zone by ID"
    field :eqemu_zone, :eqemu_zone do
      arg :id, :id
      arg :zone_id, :integer
      arg :short_name, :string
      resolve &EqemuResolver.get_zone/3
    end

    @desc "Get guild by ID"
    field :eqemu_guild, :eqemu_guild do
      arg :id, non_null(:id)
      resolve &EqemuResolver.get_guild/3
    end

    @desc "Get character's guild"
    field :eqemu_character_guild, :eqemu_guild do
      arg :character_id, non_null(:id)
      resolve &EqemuResolver.get_character_guild/3
    end

    @desc "Get available quests for character"
    field :eqemu_available_quests, list_of(:eqemu_task) do
      arg :character_id, non_null(:id)
      resolve &EqemuResolver.get_available_quests/3
    end

    @desc "Get character's active quests"
    field :eqemu_character_quests, list_of(:eqemu_character_task) do
      arg :character_id, non_null(:id)
      resolve &EqemuResolver.get_character_quests/3
    end

    @desc "Get NPCs in zone"
    field :eqemu_zone_npcs, list_of(:eqemu_npc_spawn) do
      arg :zone_id, non_null(:id)
      resolve &EqemuResolver.get_zone_npcs/3
    end

    @desc "Get spells for class"
    field :eqemu_class_spells, list_of(:eqemu_spell) do
      arg :class_id, non_null(:integer)
      arg :level, :integer
      resolve &EqemuResolver.get_class_spells/3
    end
  end

  # Mutations
  object :eqemu_mutations do
    @desc "Create a new character"
    field :create_eqemu_character, :eqemu_character do
      arg :input, non_null(:eqemu_character_input)
      resolve &EqemuResolver.create_character/3
    end

    @desc "Update character position and stats"
    field :update_eqemu_character, :eqemu_character do
      arg :id, non_null(:id)
      arg :input, non_null(:eqemu_character_update_input)
      resolve &EqemuResolver.update_character/3
    end

    @desc "Delete character"
    field :delete_eqemu_character, :eqemu_character do
      arg :id, non_null(:id)
      resolve &EqemuResolver.delete_character/3
    end

    @desc "Update character inventory"
    field :update_eqemu_inventory, :eqemu_character_inventory do
      arg :character_id, non_null(:id)
      arg :input, non_null(:eqemu_inventory_update_input)
      resolve &EqemuResolver.update_inventory/3
    end

    @desc "Join guild"
    field :join_eqemu_guild, :eqemu_guild_member do
      arg :character_id, non_null(:id)
      arg :guild_id, non_null(:id)
      resolve &EqemuResolver.join_guild/3
    end

    @desc "Leave guild"
    field :leave_eqemu_guild, :eqemu_guild_member do
      arg :character_id, non_null(:id)
      resolve &EqemuResolver.leave_guild/3
    end

    @desc "Accept quest"
    field :accept_eqemu_quest, :eqemu_character_task do
      arg :character_id, non_null(:id)
      arg :task_id, non_null(:id)
      resolve &EqemuResolver.accept_quest/3
    end

    @desc "Complete quest"
    field :complete_eqemu_quest, :eqemu_character_task do
      arg :character_id, non_null(:id)
      arg :task_id, non_null(:id)
      resolve &EqemuResolver.complete_quest/3
    end

    @desc "Zone character to new zone"
    field :zone_eqemu_character, :eqemu_character do
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
    field :eqemu_character_updated, :eqemu_character do
      arg :character_id, non_null(:id)
      
      config fn args, _info ->
        {:ok, topic: "eqemu_character:#{args.character_id}"}
      end
    end

    @desc "Subscribe to zone updates"
    field :eqemu_zone_updated, :eqemu_zone do
      arg :zone_id, non_null(:integer)
      
      config fn args, _info ->
        {:ok, topic: "eqemu_zone:#{args.zone_id}"}
      end
    end

    @desc "Subscribe to guild updates"
    field :eqemu_guild_updated, :eqemu_guild do
      arg :guild_id, non_null(:id)
      
      config fn args, _info ->
        {:ok, topic: "eqemu_guild:#{args.guild_id}"}
      end
    end
  end
end