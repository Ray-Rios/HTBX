defmodule PhoenixApp.CMS.Taxonomy.TermMeta do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_term_meta" do
    field :meta_key, :string, default: ""
    field :meta_value, :string, default: ""

    belongs_to :term, PhoenixApp.CMS.Taxonomy.Term

    timestamps()
  end

  @doc false
  def changeset(term_meta, attrs) do
    term_meta
    |> cast(attrs, [:meta_key, :meta_value, :term_id])
    |> validate_required([:meta_key, :term_id])
  end
end