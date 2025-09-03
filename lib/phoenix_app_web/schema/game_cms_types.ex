defmodule PhoenixAppWeb.Schema.GameCmsTypes do
  use Absinthe.Schema.Notation
  alias PhoenixAppWeb.Resolvers.GameCmsResolver

  # Object Types
  object :character do
    field :id, :id
    field :name, :string
    field :class, :string
    field :level, :integer
    field :experience, :integer
    field :health, :integer
    field :max_health, :integer
    field :mana, :integer
    field :max_mana, :integer
    field :gold, :integer
    field :current_zone, :string
    field :last_active, :datetime
    
    field :strength, :integer
    field :agility, :integer
    field :intelligence, :integer
    field :vitality, :integer
    
    field :attack_power, :integer
    field :defense, :integer
    field :crit_chance, :float
    field :attack_speed, :float
    
    field :user_id, :id
    field :guild_id, :id
    field :guild, :guild
    
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end

  object :item do
    field :id, :id
    field :name, :string
    field :description, :string
    field :item_type, :string
    field :rarity, :string
    field :level_requirement, :integer
    field :price, :integer
    field :icon, :string
    field :usable, :boolean
    field :stackable, :boolean
    field :max_stack, :integer
    
    field :attack_power, :integer
    field :defense, :integer
    field :health_bonus, :integer
    field :mana_bonus, :integer
    field :strength_bonus, :integer
    field :agility_bonus, :integer
    field :intelligence_bonus, :integer
    field :vitality_bonus, :integer
    
    field :health_restore, :integer
    field :mana_restore, :integer
    field :buff_duration, :integer
    field :buff_effect, :string
    
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end

  object :quest do
    field :id, :id
    field :title, :string
    field :description, :string
    field :objective, :string
    field :difficulty, :string
    field :level_requirement, :integer
    field :xp_reward, :integer
    field :gold_reward, :integer
    field :item_rewards, list_of(:integer)
    field :prerequisites, list_of(:integer)
    field :zone, :string
    field :npc_giver, :string
    field :active, :boolean
    field :repeatable, :boolean
    field :max_completions, :integer
    
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end

  object :guild do
    field :id, :id
    field :name, :string
    field :description, :string
    field :level, :integer
    field :experience, :integer
    field :max_members, :integer
    field :guild_type, :string
    field :requirements, :string
    field :active, :boolean
    field :leader_id, :id
    
    field :characters, list_of(:character)
    field :member_count, :integer do
      resolve fn guild, _, _ ->
        count = length(guild.characters || [])
        {:ok, count}
      end
    end
    
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end

  object :game_event do
    field :id, :id
    field :event_type, :string
    field :message, :string
    field :data, :string
    field :severity, :string
    field :user_id, :id
    field :character_id, :id
    
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end

  object :chat_message do
    field :id, :id
    field :message, :string
    field :channel, :string
    field :message_type, :string
    field :user_id, :id
    field :character_id, :id
    
    field :user, :user
    field :character, :character
    
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end

  object :game_cms_stats do
    field :total_characters, :integer
    field :total_items, :integer
    field :total_quests, :integer
    field :total_guilds, :integer
    field :active_players, :integer
    field :recent_events, list_of(:game_event)
  end

  # Input Types
  input_object :character_input do
    field :name, :string
    field :class, :string
    field :level, :integer
    field :experience, :integer
    field :health, :integer
    field :max_health, :integer
    field :mana, :integer
    field :max_mana, :integer
    field :gold, :integer
    field :current_zone, :string
    field :strength, :integer
    field :agility, :integer
    field :intelligence, :integer
    field :vitality, :integer
    field :attack_power, :integer
    field :defense, :integer
    field :crit_chance, :float
    field :attack_speed, :float
    field :user_id, :id
    field :guild_id, :id
  end

  input_object :item_input do
    field :name, :string
    field :description, :string
    field :item_type, :string
    field :rarity, :string
    field :level_requirement, :integer
    field :price, :integer
    field :icon, :string
    field :usable, :boolean
    field :stackable, :boolean
    field :max_stack, :integer
    field :attack_power, :integer
    field :defense, :integer
    field :health_bonus, :integer
    field :mana_bonus, :integer
    field :strength_bonus, :integer
    field :agility_bonus, :integer
    field :intelligence_bonus, :integer
    field :vitality_bonus, :integer
    field :health_restore, :integer
    field :mana_restore, :integer
    field :buff_duration, :integer
    field :buff_effect, :string
  end

  input_object :quest_input do
    field :title, :string
    field :description, :string
    field :objective, :string
    field :difficulty, :string
    field :level_requirement, :integer
    field :xp_reward, :integer
    field :gold_reward, :integer
    field :item_rewards, list_of(:integer)
    field :prerequisites, list_of(:integer)
    field :zone, :string
    field :npc_giver, :string
    field :active, :boolean
    field :repeatable, :boolean
    field :max_completions, :integer
  end

  input_object :guild_input do
    field :name, :string
    field :description, :string
    field :level, :integer
    field :experience, :integer
    field :max_members, :integer
    field :guild_type, :string
    field :requirements, :string
    field :active, :boolean
    field :leader_id, :id
  end

  input_object :chat_message_input do
    field :message, :string
    field :channel, :string
    field :message_type, :string
    field :character_id, :id
  end

  # Queries
  object :game_cms_queries do
    @desc "Get all characters"
    field :characters, list_of(:character) do
      resolve &GameCmsResolver.list_characters/3
    end

    @desc "Get a character by ID"
    field :character, :character do
      arg :id, non_null(:id)
      resolve &GameCmsResolver.get_character/3
    end

    @desc "Get current user's character"
    field :my_character, :character do
      resolve &GameCmsResolver.get_my_character/3
    end

    @desc "Get all items"
    field :items, list_of(:item) do
      resolve &GameCmsResolver.list_items/3
    end

    @desc "Get an item by ID"
    field :item, :item do
      arg :id, non_null(:id)
      resolve &GameCmsResolver.get_item/3
    end

    @desc "Get all quests"
    field :quests, list_of(:quest) do
      resolve &GameCmsResolver.list_quests/3
    end

    @desc "Get a quest by ID"
    field :quest, :quest do
      arg :id, non_null(:id)
      resolve &GameCmsResolver.get_quest/3
    end

    @desc "Get all guilds"
    field :guilds, list_of(:guild) do
      resolve &GameCmsResolver.list_guilds/3
    end

    @desc "Get a guild by ID"
    field :guild, :guild do
      arg :id, non_null(:id)
      resolve &GameCmsResolver.get_guild/3
    end

    @desc "Get recent game events"
    field :game_events, list_of(:game_event) do
      resolve &GameCmsResolver.list_game_events/3
    end

    @desc "Get chat messages"
    field :chat_messages, list_of(:chat_message) do
      arg :limit, :integer, default_value: 50
      resolve &GameCmsResolver.list_chat_messages/3
    end

    @desc "Get game CMS statistics"
    field :game_cms_stats, :game_cms_stats do
      resolve &GameCmsResolver.get_game_stats/3
    end
  end

  # Mutations
  object :game_cms_mutations do
    @desc "Create a character"
    field :create_character, :character do
      arg :input, non_null(:character_input)
      resolve &GameCmsResolver.create_character/3
    end

    @desc "Update a character"
    field :update_character, :character do
      arg :id, non_null(:id)
      arg :input, non_null(:character_input)
      resolve &GameCmsResolver.update_character/3
    end

    @desc "Delete a character"
    field :delete_character, :character do
      arg :id, non_null(:id)
      resolve &GameCmsResolver.delete_character/3
    end

    @desc "Create an item"
    field :create_item, :item do
      arg :input, non_null(:item_input)
      resolve &GameCmsResolver.create_item/3
    end

    @desc "Update an item"
    field :update_item, :item do
      arg :id, non_null(:id)
      arg :input, non_null(:item_input)
      resolve &GameCmsResolver.update_item/3
    end

    @desc "Delete an item"
    field :delete_item, :item do
      arg :id, non_null(:id)
      resolve &GameCmsResolver.delete_item/3
    end

    @desc "Create a quest"
    field :create_quest, :quest do
      arg :input, non_null(:quest_input)
      resolve &GameCmsResolver.create_quest/3
    end

    @desc "Update a quest"
    field :update_quest, :quest do
      arg :id, non_null(:id)
      arg :input, non_null(:quest_input)
      resolve &GameCmsResolver.update_quest/3
    end

    @desc "Delete a quest"
    field :delete_quest, :quest do
      arg :id, non_null(:id)
      resolve &GameCmsResolver.delete_quest/3
    end

    @desc "Create a guild"
    field :create_guild, :guild do
      arg :input, non_null(:guild_input)
      resolve &GameCmsResolver.create_guild/3
    end

    @desc "Update a guild"
    field :update_guild, :guild do
      arg :id, non_null(:id)
      arg :input, non_null(:guild_input)
      resolve &GameCmsResolver.update_guild/3
    end

    @desc "Delete a guild"
    field :delete_guild, :guild do
      arg :id, non_null(:id)
      resolve &GameCmsResolver.delete_guild/3
    end

    @desc "Send a chat message"
    field :send_chat_message, :chat_message do
      arg :input, non_null(:chat_message_input)
      resolve &GameCmsResolver.send_chat_message/3
    end
  end
end