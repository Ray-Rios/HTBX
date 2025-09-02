defmodule PhoenixApp.Repo.Migrations.CreateCmsUsers do
  use Ecto.Migration

  def change do
    create table(:cms_users) do
      add :login, :string, null: false
      add :email, :string, null: false
      add :display_name, :string, null: false, default: ""
      add :first_name, :string, null: false, default: ""
      add :last_name, :string, null: false, default: ""
      add :nickname, :string, null: false, default: ""
      add :password_hash, :string, null: false
      add :status, :string, null: false, default: "active"
      add :role, :string, null: false, default: "subscriber"
      add :activation_key, :string, null: false, default: ""
      add :user_url, :string, null: false, default: ""
      add :user_registered, :naive_datetime
      add :spam, :boolean, null: false, default: false
      add :deleted, :boolean, null: false, default: false

      timestamps()
    end

    create unique_index(:cms_users, [:login])
    create unique_index(:cms_users, [:email])
    create index(:cms_users, [:status])
    create index(:cms_users, [:role])
  end
end