defmodule PhoenixApp.CMS.Content.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_comments" do
    field :author_name, :string, default: ""
    field :author_email, :string, default: ""
    field :author_url, :string, default: ""
    field :author_ip, :string, default: ""
    field :content, :string, default: ""
    field :approved, :string, default: "1"
    field :agent, :string, default: ""
    field :type, :string, default: "comment"
    field :comment_date, :naive_datetime
    field :comment_date_gmt, :naive_datetime

    belongs_to :post, PhoenixApp.CMS.Content.Post
    belongs_to :parent, __MODULE__, foreign_key: :parent_id
    belongs_to :user, PhoenixApp.CMS.Accounts.User
    has_many :children, __MODULE__, foreign_key: :parent_id
    has_many :meta, PhoenixApp.CMS.Content.CommentMeta, foreign_key: :comment_id

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [
      :author_name, :author_email, :author_url, :author_ip, :content,
      :approved, :agent, :type, :comment_date, :comment_date_gmt,
      :post_id, :parent_id, :user_id
    ])
    |> validate_required([:content, :post_id])
    |> validate_format(:author_email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_inclusion(:approved, ["0", "1", "spam", "trash"])
  end
end