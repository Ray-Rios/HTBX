defmodule PhoenixApp.Repo.Migrations.CreateCmsUserMeta do
  use Ecto.Migration

  def change do
    create table(:cms_user_meta) do
      add :user_id, references(:cms_users, on_delete: :delete_all), null: false
      add :meta_key, :string, null: false, default: ""
      add :meta_value, :text, null: false, default: ""

      timestamps()
    end

    create index(:cms_user_meta, [:user_id])
    create index(:cms_user_meta, [:meta_key])
    create index(:cms_user_meta, [:user_id, :meta_key])
  end
end