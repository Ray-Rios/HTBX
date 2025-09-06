defmodule PhoenixApp.Repo.Migrations.AddMissingItemFields do
  use Ecto.Migration

  def up do
    alter table(:eqemu_items) do
      # Add missing fields that the schema expects but migration doesn't have
      add_if_not_exists :weight, :integer, default: 0
      add_if_not_exists :reqlevel, :integer, default: 0
    end
  end

  def down do
    alter table(:eqemu_items) do
      remove_if_exists :weight, :integer
      remove_if_exists :reqlevel, :integer
    end
  end
end