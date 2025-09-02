defmodule PhoenixApp.CMS.Taxonomy.Term do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_terms" do
    field :name, :string
    field :slug, :string
    field :description, :string, default: ""
    field :count, :integer, default: 0

    belongs_to :taxonomy, PhoenixApp.CMS.Taxonomy.Taxonomy
    belongs_to :parent, __MODULE__, foreign_key: :parent_id
    has_many :children, __MODULE__, foreign_key: :parent_id
    has_many :meta, PhoenixApp.CMS.Taxonomy.TermMeta, foreign_key: :term_id
    
    many_to_many :posts, PhoenixApp.CMS.Content.Post,
      join_through: PhoenixApp.CMS.Content.PostTermRelationship,
      join_keys: [term_id: :id, post_id: :id]

    timestamps()
  end

  @doc false
  def changeset(term, attrs) do
    term
    |> cast(attrs, [:name, :slug, :description, :count, :taxonomy_id, :parent_id])
    |> validate_required([:name, :taxonomy_id])
    |> generate_slug_if_empty()
    |> unique_constraint([:slug, :taxonomy_id])
  end

  defp generate_slug_if_empty(changeset) do
    case get_field(changeset, :slug) do
      nil -> 
        name = get_field(changeset, :name) || ""
        slug = name |> String.downcase() |> String.replace(~r/[^a-z0-9\s-]/, "") |> String.replace(~r/\s+/, "-")
        put_change(changeset, :slug, slug)
      "" -> 
        name = get_field(changeset, :name) || ""
        slug = name |> String.downcase() |> String.replace(~r/[^a-z0-9\s-]/, "") |> String.replace(~r/\s+/, "-")
        put_change(changeset, :slug, slug)
      _ -> changeset
    end
  end
end