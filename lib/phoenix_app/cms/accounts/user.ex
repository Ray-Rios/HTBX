defmodule PhoenixApp.CMS.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cms_users" do
    field :login, :string
    field :email, :string
    field :display_name, :string, default: ""
    field :first_name, :string, default: ""
    field :last_name, :string, default: ""
    field :nickname, :string, default: ""
    field :password_hash, :string
    field :status, Ecto.Enum, values: [:active, :inactive, :pending, :spam], default: :active
    field :role, :string, default: "subscriber"
    field :activation_key, :string, default: ""
    field :user_url, :string, default: ""
    field :user_registered, :naive_datetime
    field :spam, :boolean, default: false
    field :deleted, :boolean, default: false

    # Virtual field for password
    field :password, :string, virtual: true

    has_many :posts, PhoenixApp.CMS.Content.Post, foreign_key: :author_id
    has_many :meta, PhoenixApp.CMS.Accounts.UserMeta, foreign_key: :user_id
    has_many :comments, PhoenixApp.CMS.Content.Comment, foreign_key: :user_id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :login, :email, :display_name, :first_name, :last_name, :nickname,
      :password, :status, :role, :activation_key, :user_url, :user_registered,
      :spam, :deleted
    ])
    |> validate_required([:login, :email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:login, min: 3, max: 60)
    |> validate_length(:password, min: 6, max: 100)
    |> unique_constraint(:login)
    |> unique_constraint(:email)
    |> hash_password()
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
      _ ->
        changeset
    end
  end

  @doc """
  Verifies the password.
  """
  def valid_password?(%__MODULE__{password_hash: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Pbkdf2.no_user_verify()
    false
  end

  @doc """
  Gets user capabilities based on role
  """
  def get_capabilities(%__MODULE__{role: role}) do
    case role do
      "administrator" -> [
        "manage_options", "edit_posts", "edit_others_posts", "edit_published_posts",
        "publish_posts", "delete_posts", "delete_others_posts", "delete_published_posts",
        "edit_pages", "edit_others_pages", "edit_published_pages", "publish_pages",
        "delete_pages", "delete_others_pages", "delete_published_pages",
        "manage_categories", "manage_links", "moderate_comments", "upload_files",
        "import", "unfiltered_html", "edit_themes", "install_themes", "update_themes",
        "delete_themes", "edit_plugins", "install_plugins", "update_plugins",
        "delete_plugins", "edit_users", "list_users", "delete_users", "promote_users",
        "remove_users", "add_users", "create_users", "edit_dashboard", "update_core",
        "list_roles", "promote_users", "edit_theme_options", "delete_site", "manage_network",
        "manage_sites", "manage_network_users", "manage_network_plugins", "manage_network_themes",
        "manage_network_options", "upgrade_network", "setup_network"
      ]
      "editor" -> [
        "edit_posts", "edit_others_posts", "edit_published_posts", "publish_posts",
        "delete_posts", "delete_others_posts", "delete_published_posts",
        "edit_pages", "edit_others_pages", "edit_published_pages", "publish_pages",
        "delete_pages", "delete_others_pages", "delete_published_pages",
        "manage_categories", "manage_links", "moderate_comments", "upload_files",
        "unfiltered_html"
      ]
      "author" -> [
        "edit_posts", "edit_published_posts", "publish_posts", "delete_posts",
        "delete_published_posts", "upload_files"
      ]
      "contributor" -> [
        "edit_posts", "delete_posts"
      ]
      "subscriber" -> [
        "read"
      ]
      _ -> []
    end
  end

  @doc """
  Checks if user has a specific capability
  """
  def can?(%__MODULE__{} = user, capability) do
    capability in get_capabilities(user)
  end
end