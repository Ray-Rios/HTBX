defmodule PhoenixApp.EqemuMigration.AggressiveTrimmer do
  @moduledoc """
  Aggressive SQL trimming to create a minimal development database.
  Targets essential data only with much smaller table sizes.
  """

  require Logger

  @doc """
  Apply aggressive trimming to create a minimal development database.
  """
  def trim_sql_file(input_path, output_path) do
    Logger.info("Starting aggressive SQL trimming: #{input_path} -> #{output_path}")
    
    content = File.read!(input_path)
    
    # Apply aggressive filtering
    trimmed_content = 
      content
      |> remove_unnecessary_tables()
      |> apply_aggressive_row_limits()
      |> add_development_comments()
    
    File.write!(output_path, trimmed_content)
    
    # Report results
    original_size = File.stat!(input_path).size
    new_size = File.stat!(output_path).size
    
    Logger.info("Aggressive trimming complete!")
    Logger.info("Original: #{format_bytes(original_size)}")
    Logger.info("Trimmed: #{format_bytes(new_size)}")
    Logger.info("Reduction: #{Float.round((original_size - new_size) / original_size * 100, 1)}%")
    
    {:ok, output_path}
  end

  @doc """
  Remove entire tables that aren't essential for basic development.
  """
  defp remove_unnecessary_tables(content) do
    Logger.info("Removing unnecessary tables for development...")
    
    # Tables to completely remove for minimal dev environment
    tables_to_remove = [
      "temp_aa_ability", "temp_aa_actions", "temp_aa_effects", "temp_aa_rank_effects", "temp_aa_rank_prereqs", 
      "temp_aa_ranks", "temp_aa_required_level_cost", "temp_aa_timers"
    ]
    
    Enum.reduce(tables_to_remove, content, fn table_pattern, acc ->
      # Remove CREATE TABLE and INSERT statements for these tables using simple string operations
      lines = String.split(acc, "\n")
      
      filtered_lines = Enum.reject(lines, fn line ->
        String.contains?(line, table_pattern) and 
        (String.contains?(line, "DROP TABLE") or 
         String.contains?(line, "CREATE") or 
         String.contains?(line, "INSERT INTO"))
      end)
      
      Enum.join(filtered_lines, "\n")
    end)
  end

  @doc """
  Apply very aggressive row limits for a minimal development environment.
  """
  defp apply_aggressive_row_limits(content) do
    Logger.info("Applying aggressive row limits for minimal development database...")
    
    # Much smaller limits for development
    aggressive_limits = %{
      "accounts" => 50,           # Just a few test accounts
      "characters" => 100,        # Limited test characters
      "items" => 1000,           # Essential items only
      "npc_types" => 500,        # Basic NPCs
      "spawn2" => 200,           # Minimal spawns
      "spawnentry" => 300,       # Essential spawn entries
      "spawn_groups" => 200,     # Basic spawn groups
      "spells_new" => 500,       # Core spells
      "doors" => 100,            # Essential doors
      "zones" => 50,             # Core zones only
      "loot_drops" => 200,       # Basic loot
      "loot_drops_entries" => 500, # Essential loot entries
      "merchantlist" => 200,     # Basic merchants
      "skill_caps" => 100,       # Standard skill caps
      "guilds" => 20,            # Few test guilds
      "guild_members" => 50      # Limited guild membership
    }
    
    Enum.reduce(aggressive_limits, content, fn {table, limit}, acc ->
      Logger.info("Limiting #{table} to #{limit} rows")
      limit_table_rows(acc, table, limit)
    end)
  end

  @doc """
  Limit a table to a specific number of rows.
  """
  defp limit_table_rows(content, table_name, max_rows) do
    insert_pattern = ~r/(INSERT INTO #{table_name} VALUES\s*\()(.*?)(\);)/s
    
    Regex.replace(insert_pattern, content, fn _full_match, prefix, values_part, suffix ->
      # Split into individual value tuples
      value_tuples = String.split(values_part, "),(")
      
      if length(value_tuples) > max_rows do
        # Take only the first max_rows
        trimmed_tuples = Enum.take(value_tuples, max_rows)
        
        # Rejoin properly
        trimmed_values = case trimmed_tuples do
          [first | rest] ->
            first_clean = String.replace_leading(first, "(", "")
            
            rest_formatted = Enum.map(rest, fn tuple ->
              tuple_clean = tuple
              |> String.replace_leading("(", "")
              |> String.replace_trailing(")", "")
              "(#{tuple_clean})"
            end)
            
            "(" <> first_clean <> ")," <> Enum.join(rest_formatted, ",")
          
          [] -> ""
        end
        
        "#{prefix}#{trimmed_values}#{suffix}"
      else
        "#{prefix}#{values_part}#{suffix}"
      end
    end)
  end

  @doc """
  Add comments explaining the aggressive trimming.
  """
  defp add_development_comments(content) do
    header_comment = """
    -- =====================================================
    -- AGGRESSIVELY TRIMMED EQEMU DATABASE FOR DEVELOPMENT
    -- =====================================================
    -- This database has been heavily trimmed for development use:
    -- • Non-essential tables removed entirely
    -- • Row counts limited to minimal viable amounts
    -- • Focus on core game functionality only
    -- • Suitable for testing Phoenix integration
    -- =====================================================

    """
    
    header_comment <> content
  end

  defp format_bytes(bytes) when is_integer(bytes) do
    cond do
      bytes >= 1_073_741_824 -> "#{Float.round(bytes / 1_073_741_824, 1)} GB"
      bytes >= 1_048_576 -> "#{Float.round(bytes / 1_048_576, 1)} MB"
      bytes >= 1_024 -> "#{Float.round(bytes / 1_024, 1)} KB"
      true -> "#{bytes} bytes"
    end
  end
end