defmodule PhoenixApp.CMS.Content.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_posts" do
    field :title, :string, default: ""
    field :content, :string, default: ""
    field :excerpt, :string, default: ""
    field :status, Ecto.Enum, values: [:publish, :draft, :private, :trash, :auto_draft, :inherit], default: :draft
    field :post_type, :string, default: "post"
    field :slug, :string, default: ""
    field :password, :string, default: ""
    field :comment_status, Ecto.Enum, values: [:open, :closed], default: :open
    field :ping_status, Ecto.Enum, values: [:open, :closed], default: :open
    field :menu_order, :integer, default: 0
    field :guid, :string, default: ""
    field :comment_count, :integer, default: 0
    field :post_date, :naive_datetime
    field :post_date_gmt, :naive_datetime
    field :post_modified, :naive_datetime
    field :post_modified_gmt, :naive_datetime

    belongs_to :author, PhoenixApp.CMS.Accounts.User
    belongs_to :parent, __MODULE__, foreign_key: :post_parent_id
    has_many :children, __MODULE__, foreign_key: :post_parent_id
    has_many :meta, PhoenixApp.CMS.Content.PostMeta, foreign_key: :post_id
    has_many :comments, PhoenixApp.CMS.Content.Comment, foreign_key: :post_id
    
    many_to_many :terms, PhoenixApp.CMS.Taxonomy.Term,
      join_through: PhoenixApp.CMS.Content.PostTermRelationship,
      join_keys: [post_id: :id, term_id: :id]

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [
      :title, :content, :excerpt, :status, :post_type, :slug, :password,
      :comment_status, :ping_status, :menu_order, :guid, :comment_count,
      :post_date, :post_date_gmt, :post_modified, :post_modified_gmt,
      :author_id, :post_parent_id
    ])
    |> validate_required([:title, :status, :post_type])
    |> validate_inclusion(:status, [:publish, :draft, :private, :trash, :auto_draft, :inherit])
    |> validate_inclusion(:comment_status, [:open, :closed])
    |> validate_inclusion(:ping_status, [:open, :closed])
    |> generate_slug_if_empty()
    |> unique_constraint([:slug, :post_type])
  end

  defp generate_slug_if_empty(changeset) do
    case get_field(changeset, :slug) do
      "" -> 
        title = get_field(changeset, :title) || ""
        slug = title |> String.downcase() |> String.replace(~r/[^a-z0-9\s-]/, "") |> String.replace(~r/\s+/, "-")
        put_change(changeset, :slug, slug)
      _ -> changeset
    end
  end
end