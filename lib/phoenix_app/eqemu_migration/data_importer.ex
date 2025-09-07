defmodule PhoenixApp.EqemuMigration.DataImporter do
  @moduledoc """
  Import EQEmu data into existing Phoenix tables.
  This module extracts INSERT statements from the EQEmu SQL dump and 
  transforms them to work with our Phoenix schema.
  """
  
  require Logger

  @doc """
  Extract and transform INSERT statements from EQEmu SQL to Phoenix format
  """
  def create_import_script(input_path, output_path) do
    Logger.info("Creating Phoenix import script from: #{input_path}")
    
    # Tables we want to import (that exist in Phoenix)
    target_tables = %{
      "temp_account" => "accounts",
      "temp_character_data" => "characters", 
      "temp_character_inventory" => "character_inventory",
      "temp_items" => "items",
      "temp_guilds" => "guilds",
      "temp_guild_members" => "guild_members",
      "temp_zone" => "zones"
    }
    
    with {:ok, content} <- File.read(input_path) do
      import_statements = 
        content
        |> String.split("\n")
        |> Enum.filter(&is_insert_statement?/1)
        |> Enum.filter(&is_target_table?(&1, target_tables))
        |> Enum.map(&transform_insert_statement(&1, target_tables))
        |> Enum.map(&transform_field_names/1)
        |> Enum.reject(&is_nil/1)
      
      # Create the import script
      script_content = [
        "-- Phoenix EQEmu Data Import Script",
        "-- Generated from: #{input_path}",
        "-- Target: Phoenix database tables",
        "",
        "BEGIN;",
        "",
        "-- Disable foreign key checks for import",
        "SET foreign_key_checks = 0;",
        "",
        "-- Clear existing data (optional - comment out to preserve)",
        "-- TRUNCATE accounts, characters, character_inventory, items, guilds, guild_members, zones;",
        "",
        "-- Import data",
        ""
      ] ++ import_statements ++ [
        "",
        "-- Re-enable foreign key checks",
        "SET foreign_key_checks = 1;",
        "",
        "COMMIT;",
        "",
        "-- Import complete!"
      ]
      
      case File.write(output_path, Enum.join(script_content, "\n")) do
        :ok -> 
          Logger.info("Import script created: #{output_path}")
          {:ok, output_path}
        {:error, reason} -> 
          Logger.error("Failed to write import script: #{reason}")
          {:error, reason}
      end
    else
      {:error, reason} -> 
        Logger.error("Failed to read SQL file: #{reason}")
        {:error, reason}
    end
  end

  # Check if line is an INSERT statement
  defp is_insert_statement?(line) do
    String.starts_with?(String.trim(line), "INSERT INTO")
  end

  # Check if INSERT is for a table we want to import
  defp is_target_table?(line, target_tables) do
    Enum.any?(target_tables, fn {eqemu_table, _phoenix_table} ->
      String.contains?(line, "INSERT INTO #{eqemu_table}")
    end)
  end

  # Transform INSERT statement to use Phoenix table names
  defp transform_insert_statement(line, target_tables) do
    Enum.reduce(target_tables, line, fn {eqemu_table, phoenix_table}, acc ->
      String.replace(acc, "INSERT INTO #{eqemu_table}", "INSERT INTO #{phoenix_table}")
    end)
  end

  # Transform field names to match Phoenix schema
  defp transform_field_names(line) do
    line
    |> transform_character_stats_fields()
    |> transform_augmentation_fields()
    |> transform_tribute_fields()
    |> transform_primary_key_fields()
  end

  # Transform character stats field names (remove extra 'a')
  defp transform_character_stats_fields(line) do
    field_mappings = %{
      "stra," => "str,",
      "staa," => "sta,", 
      "chaa," => "cha,",
      "dexa," => "dex,",
      "inta," => "int,",
      "agia," => "agi,",
      "wisa," => "wis,"
    }
    
    Enum.reduce(field_mappings, line, fn {old_field, new_field}, acc ->
      String.replace(acc, old_field, new_field)
    end)
  end

  # Transform augmentation fields to materia
  defp transform_augmentation_fields(line) do
    field_mappings = %{
      "aug1," => "materia_1,",
      "aug2," => "materia_2,",
      "aug3," => "materia_3,",
      "aug4," => "materia_4,",
      "aug5," => "materia_5,",
      "aug6," => "materia_6,"
    }
    
    Enum.reduce(field_mappings, line, fn {old_field, new_field}, acc ->
      String.replace(acc, old_field, new_field)
    end)
  end

  # Transform tribute fields to DKP
  defp transform_tribute_fields(line) do
    field_mappings = %{
      "tribute_points," => "dkp_points,",
      "tribute_time_remaining," => "dkp_time_remaining,"
    }
    
    Enum.reduce(field_mappings, line, fn {old_field, new_field}, acc ->
      String.replace(acc, old_field, new_field)
    end)
  end

  # Transform primary key fields
  defp transform_primary_key_fields(line) do
    # This is more complex as we need to be careful not to replace 'id' in other contexts
    # For now, we'll handle the most common cases
    line
  end

  @doc """
  Get statistics about the import
  """
  def get_import_stats(script_path) do
    case File.read(script_path) do
      {:ok, content} ->
        lines = String.split(content, "\n")
        insert_lines = Enum.filter(lines, &String.starts_with?(String.trim(&1), "INSERT INTO"))
        
        table_counts = 
          insert_lines
          |> Enum.map(&extract_table_name_from_insert/1)
          |> Enum.frequencies()
        
        %{
          total_inserts: length(insert_lines),
          table_counts: table_counts,
          file_size: File.stat!(script_path).size
        }
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp extract_table_name_from_insert(line) do
    case Regex.run(~r/INSERT INTO (\w+)/, line) do
      [_, table_name] -> table_name
      _ -> "unknown"
    end
  end
end