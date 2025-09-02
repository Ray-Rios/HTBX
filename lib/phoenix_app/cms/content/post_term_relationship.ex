defmodule PhoenixApp.CMS.Content.PostTermRelationship do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_post_term_relationships" do
    field :term_order, :integer, default: 0

    belongs_to :post, PhoenixApp.CMS.Content.Post
    belongs_to :term, PhoenixApp.CMS.Taxonomy.Term

    timestamps()
  end

  @doc false
  def changeset(relationship, attrs) do
    relationship
    |> cast(attrs, [:term_order, :post_id, :term_id])
    |> validate_required([:post_id, :term_id])
    |> unique_constraint([:post_id, :term_id])
  end
end