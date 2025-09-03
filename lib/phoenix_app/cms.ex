defmodule PhoenixApp.CMS do
  @moduledoc """
  The CMS context - WordPress-equivalent content management system.
  """

  import Ecto.Query, warn: false
  alias PhoenixApp.Repo

  alias PhoenixApp.CMS.Accounts.User
  alias PhoenixApp.CMS.Content.Post
  alias PhoenixApp.CMS.Taxonomy.{Taxonomy, Term}
  alias PhoenixApp.CMS.Settings.Option

  @doc """
  Creates a CMS user with WordPress-compatible fields.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a post with WordPress-compatible fields.
  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a taxonomy (category, tag, etc.).
  """
  def create_taxonomy(attrs \\ %{}) do
    %Taxonomy{}
    |> Taxonomy.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a term within a taxonomy.
  """
  def create_term(attrs \\ %{}) do
    %Term{}
    |> Term.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Sets a site option (WordPress wp_options equivalent).
  """
  def set_option(name, value, autoload \\ "yes") do
    case Repo.get_by(Option, option_name: name) do
      nil ->
        %Option{}
        |> Option.changeset(%{option_name: name, option_value: value, autoload: autoload})
        |> Repo.insert()
      
      option ->
        option
        |> Option.changeset(%{option_value: value, autoload: autoload})
        |> Repo.update()
    end
  end

  @doc """
  Gets a site option value.
  """
  def get_option(name, default \\ nil) do
    case Repo.get_by(Option, option_name: name) do
      nil -> default
      option -> option.option_value
    end
  end

  @doc """
  Gets all posts with optional filters.
  """
  def list_posts(opts \\ []) do
    query = from p in Post, order_by: [desc: p.inserted_at]
    
    query
    |> maybe_filter_by_status(opts[:status])
    |> maybe_filter_by_type(opts[:post_type])
    |> Repo.all()
  end

  defp maybe_filter_by_status(query, nil), do: query
  defp maybe_filter_by_status(query, status) do
    from p in query, where: p.status == ^status
  end

  defp maybe_filter_by_type(query, nil), do: query
  defp maybe_filter_by_type(query, post_type) do
    from p in query, where: p.post_type == ^post_type
  end

  @doc """
  Gets a single post by ID.
  """
  def get_post!(id) do
    Repo.get!(Post, id)
  end

  @doc """
  Updates a post.
  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.
  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Gets all users.
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user by ID.
  """
  def get_user!(id) do
    Repo.get!(User, id)
  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Seeds the database with default WordPress taxonomies.
  """
  def seed_default_taxonomies do
    # Create category taxonomy
    {:ok, category_taxonomy} = create_taxonomy(%{
      name: "category",
      label: "Categories",
      description: "Post categories",
      hierarchical: true,
      public: true,
      object_type: ["post"]
    })

    # Create tag taxonomy
    {:ok, tag_taxonomy} = create_taxonomy(%{
      name: "post_tag",
      label: "Tags",
      description: "Post tags",
      hierarchical: false,
      public: true,
      object_type: ["post"]
    })

    # Create default "Uncategorized" category
    {:ok, _uncategorized} = create_term(%{
      name: "Uncategorized",
      slug: "uncategorized",
      description: "Default category for posts",
      taxonomy_id: category_taxonomy.id
    })

    # Set default options
    set_option("blogname", "My WordPress Site")
    set_option("blogdescription", "Just another WordPress site")
    set_option("default_category", "1")
    set_option("posts_per_page", "10")

    {:ok, %{category_taxonomy: category_taxonomy, tag_taxonomy: tag_taxonomy}}
  end
end