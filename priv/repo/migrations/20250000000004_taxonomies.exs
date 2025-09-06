defmodule PhoenixApp.Repo.Migrations.CreateCmsTaxonomies do
  use Ecto.Migration

  def change do
    create table(:cms_taxonomies) do
      add :name, :string, null: false
      add :label, :string, null: false
      add :description, :text, null: false, default: ""
      add :hierarchical, :boolean, null: false, default: false
      add :public, :boolean, null: false, default: true
      add :object_type, {:array, :string}, null: false, default: []

      timestamps()
    end

    create unique_index(:cms_taxonomies, [:name])
    create index(:cms_taxonomies, [:hierarchical])
    create index(:cms_taxonomies, [:public])
  end
end