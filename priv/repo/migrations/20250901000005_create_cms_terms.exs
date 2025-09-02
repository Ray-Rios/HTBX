defmodule PhoenixApp.Repo.Migrations.CreateCmsTerms do
  use Ecto.Migration

  def change do
    create table(:cms_terms) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text, null: false, default: ""
      add :count, :integer, null: false, default: 0
      add :parent_id, references(:cms_terms, on_delete: :nilify_all)
      add :taxonomy_id, references(:cms_taxonomies, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:cms_terms, [:taxonomy_id])
    create index(:cms_terms, [:parent_id])
    create index(:cms_terms, [:slug])
    create unique_index(:cms_terms, [:slug, :taxonomy_id])
  end
end