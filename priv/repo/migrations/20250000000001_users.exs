defmodule PhoenixApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration
  @disable_ddl_transaction true

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :confirmed_at, :utc_datetime
      add :is_online, :boolean, default: false
      add :is_admin, :boolean, default: false
      add :last_activity, :utc_datetime
      add :avatar_shape, :string
      add :avatar_color, :string
      add :avatar_file, :string
      add :two_factor_secret, :string
      add :two_factor_enabled, :boolean, default: false
      add :two_factor_backup_codes, {:array, :string}, default: []
      add :position_x, :float, default: 400.0
      add :position_y, :float, default: 300.0
      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create index(:users, [:is_admin])
    create index(:users, [:two_factor_enabled])
  end
end