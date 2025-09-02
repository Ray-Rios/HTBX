defmodule PhoenixApp.CMS.Content.PostMeta do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_post_meta" do
    field :meta_key, :string, default: ""
    field :meta_value, :string, default: ""

    belongs_to :post, PhoenixApp.CMS.Content.Post

    timestamps()
  end

  @doc false
  def changeset(post_meta, attrs) do
    post_meta
    |> cast(attrs, [:meta_key, :meta_value, :post_id])
    |> validate_required([:meta_key, :post_id])
  end
end