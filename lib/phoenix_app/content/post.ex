defmodule PhoenixApp.Content.Post do
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "posts" do
    field :title, :string
    field :slug, :string
    field :content, :string
    field :excerpt, :string
    field :status, Ecto.Enum, values: [:published, :draft, :private, :trash], default: :draft
    field :post_type, :string, default: "post"
    field :published_at, :utc_datetime
    field :featured_image, PhoenixApp.PostImage.Type
    field :meta_description, :string
    field :tags, {:array, :string}, default: []
    field :comment_status, Ecto.Enum, values: [:open, :closed], default: :open
    field :menu_order, :integer, default: 0
    field :comment_count, :integer, default: 0

    belongs_to :user, PhoenixApp.Accounts.User
    belongs_to :parent, __MODULE__, foreign_key: :parent_id
    has_many :children, __MODULE__, foreign_key: :parent_id
    has_many :comments, PhoenixApp.Content.Comment, foreign_key: :post_id

    timestamps(type: :utc_datetime)
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [
      :title, :slug, :content, :excerpt, :status, :post_type, :published_at, 
      :meta_description, :tags, :comment_status, :menu_order, :comment_count, :parent_id
    ])
    |> cast_attachments(attrs, [:featured_image])
    |> validate_required([:title, :content])
    |> validate_length(:title, min: 1, max: 200)
    |> validate_length(:excerpt, max: 500)
    |> validate_length(:meta_description, max: 160)
    |> validate_inclusion(:status, [:published, :draft, :private, :trash])
    |> validate_inclusion(:comment_status, [:open, :closed])
    |> maybe_generate_slug()
    |> maybe_set_published_at()
    |> unique_constraint(:slug)
  end

  defp maybe_generate_slug(changeset) do
    case get_change(changeset, :slug) do
      nil ->
        title = get_change(changeset, :title)
        if title do
          slug = title 
                 |> String.downcase() 
                 |> String.replace(~r/[^a-z0-9\s]/, "") 
                 |> String.replace(~r/\s+/, "-")
                 |> String.slice(0, 100)
          put_change(changeset, :slug, slug)
        else
          changeset
        end
      _ -> changeset
    end
  end

  defp maybe_set_published_at(changeset) do
    status = get_change(changeset, :status)
    current_published_at = get_field(changeset, :published_at)
    
    cond do
      status == :published and is_nil(current_published_at) ->
        put_change(changeset, :published_at, DateTime.utc_now())
      status != :published ->
        put_change(changeset, :published_at, nil)
      true ->
        changeset
    end
  end

  # Helper functions for CMS compatibility
  def published?(post), do: post.status == :published
  def draft?(post), do: post.status == :draft
  def can_comment?(post), do: post.comment_status == :open
end