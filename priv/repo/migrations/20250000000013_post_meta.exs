defmodule PhoenixApp.Repo.Migrations.CreateCmsPostMeta do
  use Ecto.Migration

  def change do
    create table(:cms_post_meta) do
      add :post_id, references(:cms_posts, on_delete: :delete_all), null: false
      add :meta_key, :string, null: false, default: ""
      add :meta_value, :text, null: false, default: ""

      timestamps()
    end

    create index(:cms_post_meta, [:post_id])
    create index(:cms_post_meta, [:meta_key])
    create index(:cms_post_meta, [:post_id, :meta_key])
  end
end