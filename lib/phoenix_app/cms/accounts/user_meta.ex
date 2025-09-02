defmodule PhoenixApp.CMS.Accounts.UserMeta do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_user_meta" do
    field :meta_key, :string, default: ""
    field :meta_value, :string, default: ""

    belongs_to :user, PhoenixApp.CMS.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(user_meta, attrs) do
    user_meta
    |> cast(attrs, [:meta_key, :meta_value, :user_id])
    |> validate_required([:meta_key, :user_id])
  end
end