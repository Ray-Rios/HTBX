defmodule PhoenixApp.Repo.Migrations.AddMissingGameCmsTables do
  use Ecto.Migration

  def change do
    # Only add tables that don't exist yet
    # game_guilds, game_characters, game_items, game_quests already exist from partial migration
    
    # Game Chat Messages (this one might be missing)
    create_if_not_exists table(:game_chat_messages) do
      add :message, :text, null: false
      add :channel, :string, default: "global"
      add :message_type, :string, default: "chat"
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false
      add :character_id, references(:game_characters, on_delete: :nilify_all)

      timestamps()
    end

    create_if_not_exists index(:game_chat_messages, [:channel])
    create_if_not_exists index(:game_chat_messages, [:user_id])
    create_if_not_exists index(:game_chat_messages, [:character_id])
    create_if_not_exists index(:game_chat_messages, [:inserted_at])
  end
end