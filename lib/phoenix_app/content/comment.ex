defmodule PhoenixApp.Content.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "comments" do
    field :content, :string
    field :author_name, :string
    field :author_email, :string
    field :is_approved, :boolean, default: false

    belongs_to :post, PhoenixApp.Content.Post
    belongs_to :user, PhoenixApp.Accounts.User
    belongs_to :parent, __MODULE__, foreign_key: :parent_id
    has_many :children, __MODULE__, foreign_key: :parent_id

    timestamps(type: :utc_datetime)
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [
      :content, :author_name, :author_email, :is_approved, :post_id, :user_id, :parent_id
    ])
    |> validate_required([:content, :post_id])
    |> validate_length(:content, min: 1, max: 5000)
    |> validate_format(:author_email, ~r/@/, message: "must be a valid email")
    |> validate_inclusion(:is_approved, [true, false])
    |> foreign_key_constraint(:post_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:parent_id)
  end

  # Helper functions
  def approved?(comment), do: comment.is_approved == true
  def pending?(comment), do: comment.is_approved == false
end