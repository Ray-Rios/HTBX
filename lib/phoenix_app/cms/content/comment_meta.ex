defmodule PhoenixApp.CMS.Content.CommentMeta do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_comment_meta" do
    field :meta_key, :string, default: ""
    field :meta_value, :string, default: ""

    belongs_to :comment, PhoenixApp.CMS.Content.Comment

    timestamps()
  end

  @doc false
  def changeset(comment_meta, attrs) do
    comment_meta
    |> cast(attrs, [:meta_key, :meta_value, :comment_id])
    |> validate_required([:meta_key, :comment_id])
  end
end