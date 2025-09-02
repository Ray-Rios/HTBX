defmodule PhoenixApp.CMS.Settings.Option do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_options" do
    field :option_name, :string
    field :option_value, :string, default: ""
    field :autoload, :string, default: "yes"

    timestamps()
  end

  @doc false
  def changeset(option, attrs) do
    option
    |> cast(attrs, [:option_name, :option_value, :autoload])
    |> validate_required([:option_name])
    |> validate_inclusion(:autoload, ["yes", "no"])
    |> unique_constraint(:option_name)
  end
end