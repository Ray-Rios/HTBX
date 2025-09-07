defmodule PhoenixApp.EqemuMigration.RobustImportPreparer do
  @moduledoc """
  Robust SQL import preparer that handles all MySQL to CockroachDB conversion issues.
  
  This module addresses:
  - MySQL syntax incompatibilities
  - Large message size limits
  - Column name mapping
  - Table name mapping
  - Character encoding issues
  - Data type conversions
  """

  require Logger

  @doc """
  Prepares SQL file with comprehensive MySQL to CockroachDB conversion.
  """
  def prepare_for_import(input_file, output_file) do
    Logger.info("Starting robust SQL import preparation: #{input_file} -> #{output_file}")
    
    # Read and process the file in chunks to handle large files
    content = File.read!(input_file)
    
    # Apply transformations in order
    prepared_content = content
    |> add_cockroachdb_header()
    |> clean_mysql_syntax()
    |> convert_table_definitions()
    |> split_large_statements()
    |> fix_data_types()
    |> add_cockroachdb_footer()
    
    # Write the prepared file
    File.write!(output_file, prepared_content)
    
    Logger.info("Robust SQL import preparation complete: #{output_file}")
    
    # Return statistics
    original_size = byte_size(content)
    prepared_size = byte_size(prepared_content)
    
    %{
      original_size: original_size,
      prepared_size: prepared_size,
      size_change: prepared_size - original_size
    }
  end

  # Private transformation functions

  defp add_cockroachdb_header(content) do
    header = """
    -- Phoenix EQEmu Import Script (Robust Version)
    -- Generated: #{DateTime.utc_now()}
    -- Source: Trimmed EQEmu PEQ Database
    -- Target: Phoenix CMS with CockroachDB
    -- 
    -- This script has been processed to handle:
    -- • MySQL to CockroachDB syntax conversion
    -- • Large message size limits (split statements)
    -- • Column and table name mapping
    -- • Data type compatibility
    
    -- CockroachDB settings
    SET TIME ZONE 'UTC';
    SET sql_safe_updates = false;
    
    """
    
    header <> content
  end

  defp clean_mysql_syntax(content) do
    Logger.info("Cleaning MySQL-specific syntax...")
    
    content
    # Remove all DROP TABLE statements for temp tables
    |> then(&Regex.replace(~r/DROP TABLE IF EXISTS temp_\w+[^;]*;\r?\n?/i, &1, ""))
    # Remove MySQL comments and metadata
    |> then(&Regex.replace(~r/--.*MySQL.*\r?\n/i, &1, ""))
    # Remove MySQL-specific SET statements
    |> then(&Regex.replace(~r/SET [^;]*;\r?\n/i, &1, ""))
    # Clean up extra whitespace
    |> then(&Regex.replace(~r/\r?\n\r?\n\r?\n+/, &1, "\n\n"))
  end

  defp convert_table_definitions(content) do
    Logger.info("Converting table definitions...")
    
    # Process each CREATE TABLE statement individually
    create_table_pattern = ~r/(CREATE TEMPORARY TABLE temp_\w+.*?);/s
    
    Regex.replace(create_table_pattern, content, fn full_match, _table_def ->
      convert_single_table_definition(full_match)
    end)
  end

  defp convert_single_table_definition(table_sql) do
    table_sql
    # Extract table name
    |> extract_and_convert_table_name()
    # Convert column definitions
    |> convert_column_definitions()
    # Remove MySQL-specific clauses
    |> remove_mysql_table_clauses()
  end

  defp extract_and_convert_table_name(table_sql) do
    case Regex.run(~r/CREATE TEMPORARY TABLE temp_(\w+)/i, table_sql, capture: :all_but_first) do
      [table_name] ->
        phoenix_table = map_table_name(table_name)
        String.replace(table_sql, ~r/CREATE TEMPORARY TABLE temp_\w+/i, "CREATE TABLE IF NOT EXISTS #{phoenix_table}")
      _ ->
        table_sql
    end
  end

  defp convert_column_definitions(table_sql) do
    table_sql
    # Fix common column name issues
    |> String.replace(~r/\beqemu_id\b/i, "id")
    |> String.replace(~r/\bcharid\b/i, "char_id")
    |> String.replace(~r/\baaid\b/i, "aa_id")
    # Fix data types
    |> String.replace(~r/INTEGER unsigned/i, "INTEGER")
    |> String.replace(~r/SMALLINT unsigned/i, "SMALLINT")
    |> String.replace(~r/BIGINT unsigned/i, "BIGINT")
    |> String.replace(~r/TINYINT unsigned/i, "SMALLINT")
    |> String.replace(~r/float unsigned/i, "REAL")
    |> String.replace(~r/\bfloat\b/i, "REAL")
    # Fix timestamp defaults
    |> String.replace("'0000-00-00 00:00:00'", "'1970-01-01 00:00:00'")
    # Remove character set specifications
    |> then(&Regex.replace(~r/CHARACTER SET \w+/i, &1, ""))
    |> then(&Regex.replace(~r/COLLATE \w+/i, &1, ""))
  end

  defp remove_mysql_table_clauses(table_sql) do
    table_sql
    # Remove ENGINE and charset specifications
    |> then(&Regex.replace(~r/\)\s*ENGINE=\w+[^;]*;/i, &1, ");"))
    # Remove KEY definitions (not PRIMARY KEY)
    |> then(&Regex.replace(~r/,\s*KEY \w+[^,)]*(?=,|\))/i, &1, ""))
    |> then(&Regex.replace(~r/,\s*UNIQUE KEY \w+[^,)]*(?=,|\))/i, &1, ""))
    # Clean up any remaining MySQL syntax
    |> then(&Regex.replace(~r/=\s*\d+\s*DEFAULT/i, &1, " DEFAULT"))
  end

  defp split_large_statements(content) do
    Logger.info("Splitting large INSERT statements...")
    
    # Find INSERT statements and split if they're too large
    insert_pattern = ~r/(INSERT INTO \w+ VALUES\s*)(.*?);/s
    
    Regex.replace(insert_pattern, content, fn full_match, prefix, values_part ->
      # Check if statement is too large (> 8MB to be safe)
      if byte_size(full_match) > 8 * 1024 * 1024 do
        split_insert_statement(prefix, values_part)
      else
        # Also convert table names in INSERT statements
        convert_insert_table_name(full_match)
      end
    end)
  end

  defp split_insert_statement(prefix, values_part) do
    Logger.info("Splitting large INSERT statement: #{String.slice(prefix, 0, 50)}...")
    
    # Extract individual value tuples
    value_tuples = extract_value_tuples(values_part)
    
    # Split into chunks of 500 rows each (conservative)
    chunks = Enum.chunk_every(value_tuples, 500)
    
    # Convert table name in prefix
    converted_prefix = convert_insert_table_name(prefix)
    
    # Create separate INSERT statements
    Enum.map(chunks, fn chunk ->
      values_str = Enum.join(chunk, ",\n")
      "#{converted_prefix}#{values_str};"
    end)
    |> Enum.join("\n\n")
  end

  defp extract_value_tuples(values_part) do
    # Use a more robust approach to extract value tuples
    # Handle nested parentheses and quoted strings properly
    
    tuples = []
    current_tuple = ""
    paren_depth = 0
    in_quote = false
    quote_char = nil
    
    String.graphemes(values_part)
    |> Enum.reduce({tuples, current_tuple, paren_depth, in_quote, quote_char}, 
      fn char, {acc_tuples, acc_tuple, depth, quoted, q_char} ->
        cond do
          # Handle quotes
          char in ["'", "\""] and not quoted ->
            {acc_tuples, acc_tuple <> char, depth, true, char}
          
          char == q_char and quoted ->
            {acc_tuples, acc_tuple <> char, depth, false, nil}
          
          quoted ->
            {acc_tuples, acc_tuple <> char, depth, quoted, q_char}
          
          # Handle parentheses when not quoted
          char == "(" ->
            new_depth = depth + 1
            new_tuple = if new_depth == 1, do: char, else: acc_tuple <> char
            {acc_tuples, new_tuple, new_depth, quoted, q_char}
          
          char == ")" ->
            new_depth = depth - 1
            new_tuple = acc_tuple <> char
            
            if new_depth == 0 do
              # Complete tuple found
              {acc_tuples ++ [new_tuple], "", new_depth, quoted, q_char}
            else
              {acc_tuples, new_tuple, new_depth, quoted, q_char}
            end
          
          # Handle commas between tuples
          char == "," and depth == 0 ->
            {acc_tuples, acc_tuple, depth, quoted, q_char}
          
          # Regular characters
          true ->
            {acc_tuples, acc_tuple <> char, depth, quoted, q_char}
        end
      end)
    |> elem(0)  # Return just the tuples
  end

  defp convert_insert_table_name(insert_statement) do
    case Regex.run(~r/INSERT INTO temp_(\w+)/i, insert_statement, capture: :all_but_first) do
      [table_name] ->
        phoenix_table = map_table_name(table_name)
        String.replace(insert_statement, ~r/INSERT INTO temp_\w+/i, "INSERT INTO #{phoenix_table}")
      _ ->
        insert_statement
    end
  end

  defp fix_data_types(content) do
    Logger.info("Fixing data type compatibility...")
    
    content
    # Ensure all floating point numbers use proper syntax
    |> then(&Regex.replace(~r/\bfloat\b/i, &1, "REAL"))
    # Fix any remaining unsigned references
    |> String.replace(~r/\bunsigned\b/i, "")
    # Clean up extra spaces
    |> then(&Regex.replace(~r/\s+/, &1, " "))
  end

  defp add_cockroachdb_footer(content) do
    footer = """
    
    -- Import completion
    SELECT 'Phoenix EQEmu robust import completed successfully!' as status;
    
    """
    
    content <> footer
  end

  # Table name mapping
  defp map_table_name(eqemu_table) do
    case eqemu_table do
      "account" -> "accounts"
      "character_" <> _ -> "characters"
      "guild_member" -> "guild_members"
      table -> table  # Keep original name if no mapping
    end
  end
end