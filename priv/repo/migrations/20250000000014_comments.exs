defmodule PhoenixApp.Repo.Migrations.CreateCmsComments do
  use Ecto.Migration

  def change do
    create table(:cms_comments) do
      add :post_id, references(:cms_posts, on_delete: :delete_all), null: false
      add :author_name, :string, null: false, default: ""
      add :author_email, :string, null: false, default: ""
      add :author_url, :string, null: false, default: ""
      add :author_ip, :string, null: false, default: ""
      add :content, :text, null: false, default: ""
      add :approved, :string, null: false, default: "1"
      add :agent, :string, null: false, default: ""
      add :type, :string, null: false, default: "comment"
      add :parent_id, references(:cms_comments, on_delete: :delete_all)
      add :user_id, references(:cms_users, on_delete: :nilify_all)
      add :comment_date, :naive_datetime
      add :comment_date_gmt, :naive_datetime

      timestamps()
    end

    create index(:cms_comments, [:post_id])
    create index(:cms_comments, [:parent_id])
    create index(:cms_comments, [:user_id])
    create index(:cms_comments, [:approved])
    create index(:cms_comments, [:comment_date])
    create index(:cms_comments, [:type])
  end
end