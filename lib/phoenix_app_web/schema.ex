defmodule PhoenixAppWeb.Schema do
  use Absinthe.Schema
  alias PhoenixApp.{Accounts, Game}

  # Types
  object :user do
    field :id, :id
    field :email, :string
    field :name, :string
    field :is_admin, :boolean
  end

  object :game_stats do
    field :total_score, :integer
    field :total_playtime, :integer
    field :games_played, :integer
    field :highest_level, :integer
  end

  # Queries
  query do
    field :current_user, :user do
      resolve fn _, %{context: %{current_user: user}} ->
        {:ok, user}
      end
    end

    field :game_stats, :game_stats do
      resolve fn _, _ ->
        stats = Game.get_game_stats()
        {:ok, stats}
      end
    end
  end

  # Mutations
  mutation do
    field :login, :user do
      arg :email, non_null(:string)
      arg :password, non_null(:string)

      resolve fn %{email: email, password: password}, _ ->
        case Accounts.authenticate_user(email, password) do
          {:ok, user} -> {:ok, user}
          {:error, _} -> {:error, "Invalid credentials"}
        end
      end
    end

    field :register, :user do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      arg :name, :string

      resolve fn args, _ ->
        user_params = %{
          "email" => args.email,
          "password" => args.password,
          "name" => args[:name] || args.email
        }

        case Accounts.register_user(user_params) do
          {:ok, user} -> {:ok, user}
          {:error, changeset} -> 
            errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end)
            {:error, "Registration failed: #{inspect(errors)}"}
        end
      end
    end
  end
end