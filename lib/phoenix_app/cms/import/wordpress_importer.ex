defmodule PhoenixApp.CMS.Import.WordPressImporter do
  @moduledoc """
  Imports WordPress SQL dumps into Phoenix CMS.
  Handles indiscriminate import - accepts whatever data it can parse.
  """

  import Ecto.Query
  alias PhoenixApp.Repo
  alias PhoenixApp.CMS

  @doc """
  Imports a WordPress SQL dump file.
  """
  def import_sql_file(file_path) do
    case File.read(file_path) do
      {:ok, sql_content} ->
        parse_and_import(sql_content)
      
      {:error, reason} ->
        {:error, "Could not read file: #{reason}"}
    end
  end

  defp parse_and_import(sql_content) do
    result = %{
      users: 0,
      posts: 0,
      taxonomies: 0,
      terms: 0,
      options: 0,
      errors: []
    }

    try do
      # Extract table data using regex patterns
      users_data = extract_table_data(sql_content, "wp_users")
      posts_data = extract_table_data(sql_content, "wp_posts")
      postmeta_data = extract_table_data(sql_content, "wp_postmeta")
      terms_data = extract_table_data(sql_content, "wp_terms")
      term_taxonomy_data = extract_table_data(sql_content, "wp_term_taxonomy")
      options_data = extract_table_data(sql_content, "wp_options")

      # Import data in order of dependencies
      result = import_users(users_data, result)
      result = import_posts(posts_data, postmeta_data, result)
      result = import_taxonomies_and_terms(terms_data, term_taxonomy_data, result)
      result = import_options(options_data, result)

      {:ok, result}
    rescue
      e ->
        {:error, "Import failed: #{Exception.message(e)}"}
    end
  end

  defp extract_table_data(sql_content, table_name) do
    # Look for INSERT INTO statements for the table
    pattern = ~r/INSERT INTO `?#{table_name}`?\s*\([^)]+\)\s*VALUES\s*(.+?);/is
    
    case Regex.run(pattern, sql_content) do
      [_, values_part] ->
        parse_values(values_part)
      
      nil ->
        []
    end
  end

  defp parse_values(values_part) do
    # Simple parser for VALUES (...), (...), (...)
    # This is a basic implementation - WordPress exports can be complex
    values_part
    |> String.split(~r/\),\s*\(/)
    |> Enum.map(fn row ->
      row
      |> String.replace(~r/^\(/, "")
      |> String.replace(~r/\)$/, "")
      |> parse_row_values()
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp parse_row_values(row) do
    # Basic CSV-like parsing with quote handling
    # This is simplified - real WordPress exports need more robust parsing
    try do
      row
      |> String.split(~r/,(?=(?:[^']*'[^']*')*[^']*$)/)
      |> Enum.map(fn value ->
        value
        |> String.trim()
        |> String.replace(~r/^'|'$/, "")
        |> String.replace("\\'", "'")
        |> String.replace("\\\"", "\"")
      end)
    rescue
      _ -> nil
    end
  end

  defp import_users(users_data, result) do
    count = Enum.reduce(users_data, 0, fn row, acc ->
      case create_user_from_wp_row(row) do
        {:ok, _user} -> acc + 1
        {:error, error} -> 
          %{result | errors: [error | result.errors]}
          acc
      end
    end)
    
    %{result | users: count}
  end

  defp create_user_from_wp_row(row) do
    # WordPress users table structure (approximate):
    # ID, user_login, user_pass, user_nicename, user_email, user_url, 
    # user_registered, user_activation_key, user_status, display_name
    
    case row do
      [_id, login, _pass, _nicename, email, _url, _registered, _key, _status, display_name | _] ->
        CMS.create_user(%{
          login: login,
          email: email,
          display_name: display_name || login,
          password: "imported_user_#{:rand.uniform(10000)}",
          role: "subscriber"
        })
      
      _ ->
        {:error, "Invalid user row format"}
    end
  end

  defp import_posts(posts_data, postmeta_data, result) do
    count = Enum.reduce(posts_data, 0, fn row, acc ->
      case create_post_from_wp_row(row) do
        {:ok, _post} -> acc + 1
        {:error, error} -> 
          %{result | errors: [error | result.errors]}
          acc
      end
    end)
    
    %{result | posts: count}
  end

  defp create_post_from_wp_row(row) do
    # WordPress posts table structure (approximate):
    # ID, post_author, post_date, post_date_gmt, post_content, post_title,
    # post_excerpt, post_status, comment_status, ping_status, post_password,
    # post_name, to_ping, pinged, post_modified, post_modified_gmt,
    # post_content_filtered, post_parent, guid, menu_order, post_type,
    # post_mime_type, comment_count
    
    case row do
      [_id, _author, _date, _date_gmt, content, title, excerpt, status, _comment_status, 
       _ping_status, _password, slug, _to_ping, _pinged, _modified, _modified_gmt,
       _filtered, _parent, _guid, _menu_order, post_type | _] ->
        
        # Convert WordPress status to our enum
        phoenix_status = case status do
          "publish" -> :publish
          "draft" -> :draft
          "private" -> :private
          "trash" -> :trash
          _ -> :draft
        end
        
        CMS.create_post(%{
          title: title || "Untitled",
          content: content || "",
          excerpt: excerpt || "",
          status: phoenix_status,
          post_type: post_type || "post",
          slug: slug || "untitled"
        })
      
      _ ->
        {:error, "Invalid post row format"}
    end
  end

  defp import_taxonomies_and_terms(terms_data, term_taxonomy_data, result) do
    # First create taxonomies
    taxonomies = extract_unique_taxonomies(term_taxonomy_data)
    tax_count = Enum.reduce(taxonomies, 0, fn taxonomy, acc ->
      case create_taxonomy(taxonomy) do
        {:ok, _} -> acc + 1
        {:error, _} -> acc
      end
    end)
    
    # Then create terms
    term_count = Enum.reduce(terms_data, 0, fn row, acc ->
      case create_term_from_wp_row(row, term_taxonomy_data) do
        {:ok, _} -> acc + 1
        {:error, _} -> acc
      end
    end)
    
    %{result | taxonomies: tax_count, terms: term_count}
  end

  defp extract_unique_taxonomies(term_taxonomy_data) do
    term_taxonomy_data
    |> Enum.map(fn row ->
      case row do
        [_term_taxonomy_id, _term_id, taxonomy, _description, _parent, _count] ->
          taxonomy
        _ ->
          nil
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  defp create_taxonomy(taxonomy_name) do
    CMS.create_taxonomy(%{
      name: taxonomy_name,
      label: String.capitalize(taxonomy_name),
      description: "Imported #{taxonomy_name} taxonomy",
      hierarchical: taxonomy_name == "category",
      public: true,
      object_type: ["post"]
    })
  end

  defp create_term_from_wp_row(row, term_taxonomy_data) do
    case row do
      [term_id, name, slug, _term_group] ->
        # Find the taxonomy for this term
        taxonomy_name = find_taxonomy_for_term(term_id, term_taxonomy_data)
        
        if taxonomy_name do
          # Find the taxonomy record
          taxonomy = Repo.get_by(PhoenixApp.CMS.Taxonomy.Taxonomy, name: taxonomy_name)
          
          if taxonomy do
            CMS.create_term(%{
              name: name,
              slug: slug,
              taxonomy_id: taxonomy.id
            })
          else
            {:error, "Taxonomy not found: #{taxonomy_name}"}
          end
        else
          {:error, "No taxonomy found for term #{term_id}"}
        end
      
      _ ->
        {:error, "Invalid term row format"}
    end
  end

  defp find_taxonomy_for_term(term_id, term_taxonomy_data) do
    Enum.find_value(term_taxonomy_data, fn row ->
      case row do
        [_term_taxonomy_id, ^term_id, taxonomy, _description, _parent, _count] ->
          taxonomy
        _ ->
          nil
      end
    end)
  end

  defp import_options(options_data, result) do
    count = Enum.reduce(options_data, 0, fn row, acc ->
      case create_option_from_wp_row(row) do
        {:ok, _} -> acc + 1
        {:error, _} -> acc
      end
    end)
    
    %{result | options: count}
  end

  defp create_option_from_wp_row(row) do
    case row do
      [_option_id, option_name, option_value, autoload] ->
        CMS.set_option(option_name, option_value, autoload)
      
      _ ->
        {:error, "Invalid option row format"}
    end
  end
end