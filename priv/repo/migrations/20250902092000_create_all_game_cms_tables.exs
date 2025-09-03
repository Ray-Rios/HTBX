defmodule PhoenixApp.Repo.Migrations.CreateAllGameCmsTables do
  use Ecto.Migration

  def change do
    # Game Guilds
    create_if_not_exists table(:game_guilds) do
      add :name, :string, null: false
      add :description, :text
      add :level, :integer, default: 1
      add :experience, :integer, default: 0
      add :max_members, :integer, default: 50
      add :guild_type, :string, default: "casual"
      add :requirements, :text
      add :active, :boolean, default: true
      add :leader_id, references(:users, on_delete: :restrict, type: :uuid), null: false

      timestamps()
    end

    create_if_not_exists unique_index(:game_guilds, [:name])
    create_if_not_exists index(:game_guilds, [:leader_id])
    create_if_not_exists index(:game_guilds, [:active])

    # Game Characters
    create_if_not_exists table(:game_characters) do
      add :name, :string, null: false
      add :class, :string, null: false
      add :level, :integer, default: 1
      add :experience, :integer, default: 0
      add :health, :integer, default: 100
      add :max_health, :integer, default: 100
      add :mana, :integer, default: 50
      add :max_mana, :integer, default: 50
      add :gold, :integer, default: 0
      add :current_zone, :string, default: "Starting Area"
      add :last_active, :utc_datetime
      
      # Stats
      add :strength, :integer, default: 10
      add :agility, :integer, default: 10
      add :intelligence, :integer, default: 10
      add :vitality, :integer, default: 10
      
      # Calculated stats
      add :attack_power, :integer, default: 10
      add :defense, :integer, default: 5
      add :crit_chance, :float, default: 5.0
      add :attack_speed, :float, default: 1.0

      add :user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false
      add :guild_id, references(:game_guilds, on_delete: :nilify_all)

      timestamps()
    end

    create_if_not_exists unique_index(:game_characters, [:name])
    create_if_not_exists index(:game_characters, [:user_id])
    create_if_not_exists index(:game_characters, [:guild_id])
    create_if_not_exists index(:game_characters, [:level])
    create_if_not_exists index(:game_characters, [:last_active])

    # Game Items
    create_if_not_exists table(:game_items) do
      add :name, :string, null: false
      add :description, :text
      add :item_type, :string, null: false
      add :rarity, :string, default: "common"
      add :level_requirement, :integer, default: 1
      add :price, :integer, default: 0
      add :icon, :string
      add :usable, :boolean, default: false
      add :stackable, :boolean, default: true
      add :max_stack, :integer, default: 99
      
      # Item stats (for equipment)
      add :attack_power, :integer, default: 0
      add :defense, :integer, default: 0
      add :health_bonus, :integer, default: 0
      add :mana_bonus, :integer, default: 0
      add :strength_bonus, :integer, default: 0
      add :agility_bonus, :integer, default: 0
      add :intelligence_bonus, :integer, default: 0
      add :vitality_bonus, :integer, default: 0
      
      # For consumables
      add :health_restore, :integer, default: 0
      add :mana_restore, :integer, default: 0
      add :buff_duration, :integer, default: 0
      add :buff_effect, :string

      timestamps()
    end

    create_if_not_exists index(:game_items, [:item_type])
    create_if_not_exists index(:game_items, [:rarity])
    create_if_not_exists index(:game_items, [:level_requirement])

    # Game Quests
    create_if_not_exists table(:game_quests) do
      add :title, :string, null: false
      add :description, :text, null: false
      add :objective, :text, null: false
      add :difficulty, :string, default: "easy"
      add :level_requirement, :integer, default: 1
      add :xp_reward, :integer, default: 100
      add :gold_reward, :integer, default: 50
      add :item_rewards, {:array, :integer}, default: []
      add :prerequisites, {:array, :integer}, default: []
      add :zone, :string
      add :npc_giver, :string
      add :active, :boolean, default: true
      add :repeatable, :boolean, default: false
      add :max_completions, :integer, default: 1

      timestamps()
    end

    create_if_not_exists index(:game_quests, [:difficulty])
    create_if_not_exists index(:game_quests, [:level_requirement])
    create_if_not_exists index(:game_quests, [:active])
    create_if_not_exists index(:game_quests, [:zone])
  end
end