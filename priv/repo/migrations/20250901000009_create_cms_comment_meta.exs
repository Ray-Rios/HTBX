defmodule PhoenixApp.Repo.Migrations.CreateCmsCommentMeta do
  use Ecto.Migration

  def change do
    create table(:cms_comment_meta) do
      add :comment_id, references(:cms_comments, on_delete: :delete_all), null: false
      add :meta_key, :string, null: false, default: ""
      add :meta_value, :text, null: false, default: ""

      timestamps()
    end

    create index(:cms_comment_meta, [:comment_id])
    create index(:cms_comment_meta, [:meta_key])
    create index(:cms_comment_meta, [:comment_id, :meta_key])
  end
end