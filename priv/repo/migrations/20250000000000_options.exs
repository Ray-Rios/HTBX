defmodule PhoenixApp.Repo.Migrations.CreateCmsOptions do
  use Ecto.Migration

  def change do
    create table(:cms_options) do
      add :option_name, :string, null: false
      add :option_value, :text, null: false, default: ""
      add :autoload, :string, null: false, default: "yes"

      timestamps()
    end

    create unique_index(:cms_options, [:option_name])
    create index(:cms_options, [:autoload])
  end
end