defmodule PhoenixApp.Settings.Option do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "options" do
    field :name, :string
    field :value, :string
    field :autoload, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  def changeset(option, attrs) do
    option
    |> cast(attrs, [:name, :value, :autoload])
    |> validate_required([:name, :value])
    |> unique_constraint(:name)
  end
end