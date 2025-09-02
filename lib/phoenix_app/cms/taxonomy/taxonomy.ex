defmodule PhoenixApp.CMS.Taxonomy.Taxonomy do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_taxonomies" do
    field :name, :string
    field :label, :string
    field :description, :string, default: ""
    field :hierarchical, :boolean, default: false
    field :public, :boolean, default: true
    field :object_type, {:array, :string}, default: []

    has_many :terms, PhoenixApp.CMS.Taxonomy.Term

    timestamps()
  end

  @doc false
  def changeset(taxonomy, attrs) do
    taxonomy
    |> cast(attrs, [:name, :label, :description, :hierarchical, :public, :object_type])
    |> validate_required([:name, :label])
    |> unique_constraint(:name)
  end
end