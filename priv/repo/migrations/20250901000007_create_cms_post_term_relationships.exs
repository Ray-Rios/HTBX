defmodule PhoenixApp.Repo.Migrations.CreateCmsPostTermRelationships do
  use Ecto.Migration

  def change do
    create table(:cms_post_term_relationships) do
      add :post_id, references(:cms_posts, on_delete: :delete_all), null: false
      add :term_id, references(:cms_terms, on_delete: :delete_all), null: false
      add :term_order, :integer, null: false, default: 0

      timestamps()
    end

    create index(:cms_post_term_relationships, [:post_id])
    create index(:cms_post_term_relationships, [:term_id])
    create unique_index(:cms_post_term_relationships, [:post_id, :term_id])
  end
end