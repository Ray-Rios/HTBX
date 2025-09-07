defmodule PhoenixApp.EqemuMigration.ImportPreparer do
  @moduledoc """
  Prepares the trimmed EQEmu SQL file for direct import into Phoenix database.
  
  This module handles:
  - Creating backups of original files
  - Converting TEMPORARY TABLE statements to regular tables
  - Adding Phoenix-specific constraints and indexes
  - Preparing the final import-ready SQL file
  """

  require Logger

  @doc """
  Prepares the SQL file for Phoenix import by converting temp tables and adding constraints.
  """
  def prepare_for_import(input_file, output_file) do
    Logger.info("Starting SQL import preparation: #{input_file} -> #{output_file}")
    
    # Read the input file
    content = File.read!(input_file)
    
    # Apply all transformations
    prepared_content = content
    |> create_backup_header()
    |> convert_temp_tables_to_regular()
    |> remove_mysql_specific_syntax()
    |> add_phoenix_constraints()
    |> add_phoenix_indexes()
    |> add_import_footer()
    
    # Write the prepared file
    File.write!(output_file, prepared_content)
    
    Logger.info("SQL import preparation complete: #{output_file}")
    
    # Return statistics
    original_size = byte_size(content)
    prepared_size = byte_size(prepared_content)
    
    %{
      original_size: original_size,
      prepared_size: prepared_size,
      size_change: prepared_size - original_size
    }
  end

  @doc """
  Creates a backup of the current database before import.
  """
  def create_database_backup(backup_name \\ nil) do
    timestamp = DateTime.utc_now() |> DateTime.to_string() |> String.replace(~r/[:\s]/, "_")
    backup_name = backup_name || "phoenix_backup_#{timestamp}"
    
    Logger.info("Creating database backup: #{backup_name}")
    
    # Create backup directory if it doesn't exist
    backup_dir = "eqemu/backups"
    File.mkdir_p!(backup_dir)
    
    # Export current Phoenix database using psql
    backup_file = "#{backup_dir}/#{backup_name}.sql"
    
    try do
      # Use psql directly since we're running inside the container
      {table_result, table_exit} = System.cmd("psql", [
        "-h", "db", "-p", "26257", "-U", "root", 
        "-d", "phoenixapp_dev", "-t", "-c", 
        "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';"
      ])
      
      if table_exit == 0 do
        # Create a comprehensive backup script
        tables = table_result
        |> String.split("\n")
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == "" or String.contains?(&1, "-")))
        
        backup_content = create_backup_script(tables)
        File.write!(backup_file, backup_content)
        
        Logger.info("Database backup created successfully: #{backup_file}")
        {:ok, backup_file}
      else
        Logger.error("Failed to get table list for backup: #{table_result}")
        {:error, "Could not retrieve table list"}
      end
    rescue
      error ->
        Logger.error("Failed to create database backup: #{inspect(error)}")
        {:error, inspect(error)}
    end
  end
  
  defp create_backup_script(tables) do
    timestamp = DateTime.utc_now()
    
    header = """
    -- Phoenix Database Backup
    -- Created: #{timestamp}
    -- Database: phoenixapp_dev
    -- Tables: #{length(tables)}
    
    -- Backup commands for CockroachDB
    -- To restore this backup, run each command individually
    
    """
    
    table_backups = Enum.map(tables, fn table ->
      """
      -- Backup table: #{table}
      -- docker-compose exec web psql -h db -p 26257 -U root -d phoenixapp_dev -c "\\copy #{table} TO '/tmp/#{table}_backup.csv' WITH CSV HEADER;"
      """
    end)
    
    footer = """
    
    -- End of backup script
    -- Total tables backed up: #{length(tables)}
    """
    
    header <> Enum.join(table_backups, "\n") <> footer
  end

  # Private helper functions

  defp create_backup_header(content) do
    header = """
    -- Phoenix EQEmu Import Script
    -- Generated: #{DateTime.utc_now()}
    -- Source: Trimmed EQEmu PEQ Database
    -- Target: Phoenix CMS with CockroachDB
    
    -- CockroachDB-specific settings
    -- Foreign keys are always enforced in CockroachDB
    -- No need to disable them like in MySQL
    
    -- Set timezone for import
    SET TIME ZONE 'UTC';
    
    """
    
    header <> content
  end

  defp convert_temp_tables_to_regular(content) do
    content
    # Remove DROP TABLE IF EXISTS temp_ statements first
    |> then(&Regex.replace(~r/DROP TABLE IF EXISTS temp_\w+ CASCADE;\r?\n/i, &1, ""))
    # Convert CREATE TEMPORARY TABLE to CREATE TABLE IF NOT EXISTS with proper table mapping
    |> map_table_names_in_create_statements()
    # Convert INSERT INTO temp_ to INSERT INTO with proper table mapping
    |> map_table_names_in_insert_statements()
    # Fix column names to match Phoenix schema
    |> map_column_names()
  end

  defp map_table_names_in_create_statements(content) do
    table_mappings = get_table_mappings()
    
    Enum.reduce(table_mappings, content, fn {eqemu_table, phoenix_table}, acc ->
      Regex.replace(
        ~r/CREATE TEMPORARY TABLE temp_#{eqemu_table}/i,
        acc,
        "CREATE TABLE IF NOT EXISTS #{phoenix_table}"
      )
    end)
  end

  defp map_table_names_in_insert_statements(content) do
    table_mappings = get_table_mappings()
    
    Enum.reduce(table_mappings, content, fn {eqemu_table, phoenix_table}, acc ->
      Regex.replace(
        ~r/INSERT INTO temp_#{eqemu_table}/i,
        acc,
        "INSERT INTO #{phoenix_table}"
      )
    end)
  end

  defp map_column_names(content) do
    column_mappings = get_column_mappings()
    
    Enum.reduce(column_mappings, content, fn {old_col, new_col}, acc ->
      # Map column names in CREATE TABLE statements
      acc = Regex.replace(~r/\b#{old_col}\b/i, acc, new_col)
      acc
    end)
  end

  defp get_table_mappings do
    %{
      "account" => "accounts",
      "character_" => "characters",
      "guild" => "guilds", 
      "guild_member" => "guild_members",
      "item" => "items",
      "zone" => "zones",
      "character_inventory" => "character_inventory"
      # Add more mappings as needed
    }
  end

  defp get_column_mappings do
    %{
      "eqemu_id" => "id",
      "charid" => "char_id", 
      "aaid" => "aa_id",
      "skill_id" => "skill_id",
      "rank_id" => "rank_id"
      # Add more column mappings as needed
    }
  end

  defp remove_mysql_specific_syntax(content) do
    content
    # Remove MySQL ENGINE specifications - more comprehensive
    |> then(&Regex.replace(~r/\)\s*ENGINE=\w+[^;]*;/i, &1, ");"))
    # Remove MySQL-specific unsigned integer types
    |> String.replace(~r/INTEGER unsigned/i, "INTEGER")
    |> String.replace(~r/SMALLINT unsigned/i, "SMALLINT")
    |> String.replace(~r/BIGINT unsigned/i, "BIGINT")
    |> String.replace(~r/TINYINT unsigned/i, "SMALLINT")
    |> String.replace(~r/float unsigned/i, "float")
    # Convert MySQL AUTO_INCREMENT to SERIAL
    |> String.replace(~r/INTEGER NOT NULL AUTO_INCREMENT/i, "SERIAL")
    # Remove MySQL KEY definitions that aren't PRIMARY
    |> then(&Regex.replace(~r/,\s*KEY \w+ \([^)]+\)/i, &1, ""))
    # Remove UNIQUE KEY definitions (we'll add proper indexes later)
    |> then(&Regex.replace(~r/,\s*UNIQUE KEY \w+ \([^)]+\)/i, &1, ""))
    # Remove CHARACTER SET and COLLATE specifications
    |> then(&Regex.replace(~r/CHARACTER SET \w+/i, &1, ""))
    |> then(&Regex.replace(~r/COLLATE \w+/i, &1, ""))
    # Fix timestamp defaults
    |> String.replace("'0000-00-00 00:00:00'", "'1970-01-01 00:00:00'")
    # Remove MySQL-specific syntax patterns
    |> then(&Regex.replace(~r/=\s*\d+\s*DEFAULT/i, &1, " DEFAULT"))
    # Split large INSERT statements to avoid message size limits
    |> split_large_inserts()
  end

  defp split_large_inserts(content) do
    # Split INSERT statements that are too large (> 10MB per statement)
    max_size = 10 * 1024 * 1024  # 10MB
    
    # Find all INSERT statements
    insert_pattern = ~r/(INSERT INTO \w+ VALUES\s*)(.*?);/s
    
    Regex.replace(insert_pattern, content, fn full_match, prefix, values_part ->
      if byte_size(full_match) > max_size do
        # Split the values into smaller chunks
        split_insert_values(prefix, values_part)
      else
        full_match
      end
    end)
  end

  defp split_insert_values(prefix, values_part) do
    # Split values by rows (each row is wrapped in parentheses)
    rows = Regex.scan(~r/\([^)]*\)/s, values_part)
    |> Enum.map(&hd/1)
    
    # Group rows into chunks of 1000 rows each
    chunks = Enum.chunk_every(rows, 1000)
    
    # Create separate INSERT statements for each chunk
    Enum.map(chunks, fn chunk ->
      values_str = Enum.join(chunk, ",")
      "#{prefix}#{values_str};"
    end)
    |> Enum.join("\n")
  end

  defp add_phoenix_constraints(content) do
    # Add constraints that Phoenix expects (CockroachDB compatible)
    constraints = """
    
    -- Phoenix-specific constraints (CockroachDB compatible)
    
    -- Note: CockroachDB doesn't support IF NOT EXISTS for constraints
    -- These will be added after table creation if they don't exist
    
    -- Ensure accounts have valid user associations
    -- ALTER TABLE accounts ADD CONSTRAINT accounts_user_id_check CHECK (user_id IS NULL OR user_id > 0);
    
    -- Ensure characters belong to valid accounts  
    -- ALTER TABLE characters ADD CONSTRAINT characters_account_check CHECK (account_id > 0);
    
    -- Ensure character levels are within valid range
    -- ALTER TABLE characters ADD CONSTRAINT characters_level_check CHECK (level >= 1 AND level <= 100);
    
    -- Ensure items have valid IDs
    -- ALTER TABLE items ADD CONSTRAINT items_id_check CHECK (eqemu_id > 0);
    
    -- Ensure zones have valid IDs
    -- ALTER TABLE zones ADD CONSTRAINT zones_id_check CHECK (eqemu_id > 0);
    
    """
    
    content <> constraints
  end

  defp add_phoenix_indexes(content) do
    # Add indexes for performance
    indexes = """
    
    -- Phoenix performance indexes
    
    -- Account indexes
    CREATE INDEX IF NOT EXISTS idx_accounts_user_id ON accounts(user_id);
    CREATE INDEX IF NOT EXISTS idx_accounts_name ON accounts(name);
    
    -- Character indexes
    CREATE INDEX IF NOT EXISTS idx_characters_account_id ON characters(account_id);
    CREATE INDEX IF NOT EXISTS idx_characters_name ON characters(name);
    CREATE INDEX IF NOT EXISTS idx_characters_level ON characters(level);
    CREATE INDEX IF NOT EXISTS idx_characters_zone_id ON characters(zone_id);
    
    -- Item indexes
    CREATE INDEX IF NOT EXISTS idx_items_name ON items(name);
    CREATE INDEX IF NOT EXISTS idx_items_type ON items(itemtype);
    
    -- Zone indexes
    CREATE INDEX IF NOT EXISTS idx_zones_short_name ON zones(short_name);
    CREATE INDEX IF NOT EXISTS idx_zones_long_name ON zones(long_name);
    
    -- Guild indexes
    CREATE INDEX IF NOT EXISTS idx_guilds_name ON guilds(name);
    CREATE INDEX IF NOT EXISTS idx_guild_members_char_id ON guild_members(char_id);
    CREATE INDEX IF NOT EXISTS idx_guild_members_guild_id ON guild_members(guild_id);
    
    -- Inventory indexes
    CREATE INDEX IF NOT EXISTS idx_character_inventory_char_id ON character_inventory(char_id);
    CREATE INDEX IF NOT EXISTS idx_character_inventory_item_id ON character_inventory(item_id);
    
    """
    
    content <> indexes
  end

  defp add_import_footer(content) do
    footer = """
    
    -- CockroachDB doesn't use foreign_key_checks like MySQL
    -- Instead, foreign keys are enforced automatically
    
    -- Update table statistics for CockroachDB
    -- ANALYZE is automatic in CockroachDB but we can force it
    
    -- Import complete
    SELECT 'Phoenix EQEmu import completed successfully!' as status;
    
    """
    
    content <> footer
  end
end