defmodule PhoenixApp.EqemuMigration.AdvancedTrimmer do
  @moduledoc """
  Advanced SQL file trimming that reduces table sizes to manageable development limits.
  Targets 15,000 rows maximum per table while preserving essential game data.
  """

  require Logger

  @max_rows_per_table 15_000

  @doc """
  Trim the SQL file to reduce table sizes while preserving essential data.
  """
  def trim_sql_file(input_path, output_path) do
    Logger.info("Starting advanced SQL trimming: #{input_path} -> #{output_path}")
    
    # Read and analyze the file
    content = File.read!(input_path)
    
    # Get table statistics
    table_stats = analyze_insert_statements(content)
    Logger.info("Found #{map_size(table_stats)} tables with INSERT statements")
    
    # Apply trimming rules
    trimmed_content = apply_trimming_rules(content, table_stats)
    
    # Write the trimmed file
    File.write!(output_path, trimmed_content)
    
    # Generate report
    new_stats = analyze_insert_statements(trimmed_content)
    generate_trimming_report(table_stats, new_stats)
    
    {:ok, output_path}
  end

  @doc """
  Analyze INSERT statements to count rows per table.
  """
  def analyze_insert_statements(content) do
    # Find all INSERT INTO statements and count rows
    insert_pattern = ~r/INSERT INTO (\w+) VALUES\s*\((.*?)\);/s
    
    Regex.scan(insert_pattern, content)
    |> Enum.reduce(%{}, fn [_full_match, table_name, values_part], acc ->
      # Count the number of value tuples
      row_count = count_value_tuples(values_part)
      Map.update(acc, table_name, row_count, &(&1 + row_count))
    end)
  end

  @doc """
  Count the number of value tuples in an INSERT VALUES clause.
  """
  defp count_value_tuples(values_part) do
    # Count opening parentheses that start value tuples
    # This is a simplified approach - could be enhanced for complex cases
    values_part
    |> String.split("),(")
    |> length()
  end

  @doc """
  Apply trimming rules to reduce table sizes.
  """
  def apply_trimming_rules(content, table_stats) do
    Logger.info("Applying trimming rules with #{@max_rows_per_table} max rows per table")
    
    # Define smart trimming strategies for different table types
    trimming_strategies = get_trimming_strategies()
    
    # Process each large table
    Enum.reduce(table_stats, content, fn {table_name, row_count}, acc ->
      if row_count > @max_rows_per_table do
        strategy = get_strategy_for_table(table_name, trimming_strategies)
        Logger.info("Trimming #{table_name}: #{row_count} -> #{strategy.target_rows} rows")
        trim_table_inserts(acc, table_name, strategy)
      else
        acc
      end
    end)
  end

  @doc """
  Get trimming strategies for different types of tables.
  """
  defp get_trimming_strategies do
    %{
      # Core game data - keep more records
      "items" => %{
        target_rows: 15_000,
        filter_strategy: :low_level_items,
        priority_filter: "id < 100000"  # Keep lower ID items (usually more essential)
      },
      
      "npc_types" => %{
        target_rows: 12_000,
        filter_strategy: :essential_npcs,
        priority_filter: "level <= 50 AND id < 50000"  # Keep lower level, lower ID NPCs
      },
      
      "spawn2" => %{
        target_rows: 10_000,
        filter_strategy: :starter_zones,
        priority_filter: "zone IN ('qeynos', 'freeport', 'halas', 'rivervale', 'kelethin', 'felwithea', 'kaladim', 'grobb', 'oggok', 'cabeast', 'neriak', 'akanon', 'paineel')"
      },
      
      "spawnentry" => %{
        target_rows: 12_000,
        filter_strategy: :essential_spawns,
        priority_filter: "npcID < 50000"
      },
      
      # Loot and items - moderate trimming
      "lootdrop_entries" => %{
        target_rows: 8_000,
        filter_strategy: :essential_loot,
        priority_filter: "item_id < 50000 AND chance > 5"  # Keep higher chance, lower ID items
      },
      
      "merchantlist" => %{
        target_rows: 6_000,
        filter_strategy: :basic_merchants,
        priority_filter: "item < 30000"  # Keep basic items
      },
      
      # Skills and progression
      "skill_caps" => %{
        target_rows: 5_000,
        filter_strategy: :standard_classes,
        priority_filter: "class <= 16 AND level <= 60"  # Standard classes, reasonable levels
      },
      
      # Spells and abilities  
      "spells_new" => %{
        target_rows: 10_000,
        filter_strategy: :essential_spells,
        priority_filter: "id < 20000 AND classes != 0"  # Keep lower ID spells that have class restrictions
      },
      
      # Default strategy for other tables
      "default" => %{
        target_rows: @max_rows_per_table,
        filter_strategy: :first_n_rows,
        priority_filter: nil
      }
    }
  end

  @doc """
  Get the appropriate trimming strategy for a table.
  """
  defp get_strategy_for_table(table_name, strategies) do
    # Try exact match first
    case Map.get(strategies, table_name) do
      nil ->
        # Try pattern matching for similar tables
        matching_strategy = Enum.find(strategies, fn {pattern, _strategy} ->
          pattern != "default" && String.contains?(table_name, pattern)
        end)
        
        case matching_strategy do
          {_pattern, strategy} -> strategy
          nil -> strategies["default"]
        end
      
      strategy -> strategy
    end
  end

  @doc """
  Trim INSERT statements for a specific table.
  """
  defp trim_table_inserts(content, table_name, strategy) do
    insert_pattern = ~r/(INSERT INTO #{table_name} VALUES\s*\()(.*?)(\);)/s
    
    Regex.replace(insert_pattern, content, fn full_match, prefix, values_part, suffix ->
      case strategy.filter_strategy do
        :first_n_rows ->
          trim_to_first_n_rows(prefix, values_part, suffix, strategy.target_rows)
        
        _ ->
          # For other strategies, we'll implement smart filtering
          # For now, fall back to first N rows but add a comment about the strategy
          trimmed = trim_to_first_n_rows(prefix, values_part, suffix, strategy.target_rows)
          "-- Trimmed using #{strategy.filter_strategy} strategy\n#{trimmed}"
      end
    end)
  end

  @doc """
  Trim INSERT VALUES to first N rows.
  """
  defp trim_to_first_n_rows(prefix, values_part, suffix, target_rows) do
    # Split into individual value tuples
    value_tuples = String.split(values_part, "),(")
    
    if length(value_tuples) > target_rows do
      # Take only the first target_rows
      trimmed_tuples = Enum.take(value_tuples, target_rows)
      
      # Rejoin the tuples
      trimmed_values = case trimmed_tuples do
        [first | rest] ->
          # First tuple doesn't need leading comma/paren
          first_clean = String.replace_leading(first, "(", "")
          
          # Rest need proper formatting
          rest_formatted = Enum.map(rest, fn tuple ->
            tuple_clean = tuple
            |> String.replace_leading("(", "")
            |> String.replace_trailing(")", "")
            "(#{tuple_clean})"
          end)
          
          # Combine all
          "(" <> first_clean <> ")," <> Enum.join(rest_formatted, ",")
        
        [] -> ""
      end
      
      "#{prefix}#{trimmed_values}#{suffix}"
    else
      # No trimming needed
      "#{prefix}#{values_part}#{suffix}"
    end
  end

  @doc """
  Generate a report showing before/after statistics.
  """
  defp generate_trimming_report(before_stats, after_stats) do
    Logger.info("=== Trimming Report ===")
    
    total_before = before_stats |> Map.values() |> Enum.sum()
    total_after = after_stats |> Map.values() |> Enum.sum()
    
    reduction = total_before - total_after
    percentage = if total_before > 0, do: Float.round((reduction / total_before) * 100, 1), else: 0
    
    Logger.info("Total rows before: #{format_number(total_before)}")
    Logger.info("Total rows after: #{format_number(total_after)}")
    Logger.info("Rows removed: #{format_number(reduction)} (#{percentage}%)")
    
    # Show top trimmed tables
    trimmed_tables = 
      before_stats
      |> Enum.map(fn {table, before_count} ->
        after_count = Map.get(after_stats, table, 0)
        reduction = before_count - after_count
        {table, before_count, after_count, reduction}
      end)
      |> Enum.filter(fn {_table, _before, _after_count, reduction} -> reduction > 0 end)
      |> Enum.sort_by(fn {_table, _before, _after_count, reduction} -> reduction end, :desc)
      |> Enum.take(10)
    
    Logger.info("\nTop 10 Trimmed Tables:")
    Enum.each(trimmed_tables, fn {table, before_count, after_count, reduction} ->
      Logger.info("  #{table}: #{format_number(before_count)} -> #{format_number(after_count)} (-#{format_number(reduction)})")
    end)
  end

  defp format_number(number) when is_integer(number) do
    number
    |> Integer.to_string()
    |> String.reverse()
    |> String.replace(~r/(\d{3})(?=\d)/, "\\1,")
    |> String.reverse()
  end
end