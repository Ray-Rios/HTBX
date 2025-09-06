defmodule PhoenixApp.Repo.Migrations.CreateCmsPosts do
  use Ecto.Migration

  def change do
    create table(:cms_posts) do
      add :title, :text, null: false, default: ""
      add :content, :text, null: false, default: ""
      add :excerpt, :text, null: false, default: ""
      add :status, :string, null: false, default: "draft"
      add :post_type, :string, null: false, default: "post"
      add :slug, :string, null: false, default: ""
      add :password, :string, null: false, default: ""
      add :comment_status, :string, null: false, default: "open"
      add :ping_status, :string, null: false, default: "open"
      add :menu_order, :integer, null: false, default: 0
      add :post_parent_id, references(:cms_posts, on_delete: :nilify_all)
      add :author_id, references(:cms_users, on_delete: :nilify_all)
      add :guid, :string, null: false, default: ""
      add :comment_count, :integer, null: false, default: 0
      add :post_date, :naive_datetime
      add :post_date_gmt, :naive_datetime
      add :post_modified, :naive_datetime
      add :post_modified_gmt, :naive_datetime

      timestamps()
    end

    create index(:cms_posts, [:author_id])
    create index(:cms_posts, [:post_parent_id])
    create index(:cms_posts, [:status])
    create index(:cms_posts, [:post_type])
    create index(:cms_posts, [:slug])
    create index(:cms_posts, [:post_date])
    create unique_index(:cms_posts, [:slug, :post_type])
  end
end