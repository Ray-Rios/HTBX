defmodule PhoenixApp.EqemuMigration.TableMappings do
  @moduledoc """
  Defines the mapping between original EQEmu tables and Phoenix tables.
  With the eqemu_ prefix removed, the mappings are much cleaner.
  """

  @doc """
  Core table mappings from original EQEmu to Phoenix.
  Now that we've removed the eqemu_ prefix, these are direct mappings.
  """
  def core_table_mappings do
    %{
      # Core game data - CLEAN 1:1 MAPPINGS!
      "account" => "accounts",
      "character_data" => "characters", 
      "character_stats" => "character_stats",
      "items" => "items",
      "guilds" => "guilds",
      "zone" => "zones",
      
      # Association tables
      "character_inventory" => "character_inventory",
      "guild_members" => "guild_members",
      "character_tasks" => "character_tasks",
      
      # Game content
      "npc_types" => "npc_types",
      "spawn2" => "npc_spawns",
      "spells_new" => "spells",
      "tasks" => "tasks",
      
      # Loot and trading
      "lootdrop" => "loot_drops",
      "lootdrop_entries" => "loot_drop_entries", 
      "loottable" => "loot_tables",
      "loottable_entries" => "loot_table_entries",
      "merchantlist" => "merchant_items",
      
      # Tradeskills
      "tradeskill_recipe" => "recipes",
      "tradeskill_recipe_entries" => "recipe_entries",
      
      # World objects
      "doors" => "doors",
      "object" => "objects",
      
      # Factions and skills
      "faction_list" => "factions",
      "skill_caps" => "skill_caps"
    }
  end

  @doc """
  Get Phoenix table name for an original EQEmu table.
  Handles both temp_ prefixed and regular table names.
  """
  def get_phoenix_table(original_table) do
    # Remove temp_ prefix if present
    clean_table = String.replace_prefix(original_table, "temp_", "")
    
    # Look up in mappings
    core_table_mappings()[clean_table] || clean_table
  end

  @doc """
  Get original EQEmu table name for a Phoenix table.
  """
  def get_original_table(phoenix_table) do
    core_table_mappings()
    |> Enum.find(fn {_original, mapped} -> mapped == phoenix_table end)
    |> case do
      {original, _mapped} -> original
      nil -> phoenix_table
    end
  end

  @doc """
  Check if a table should be migrated based on our mappings.
  """
  def should_migrate?(table_name) do
    clean_table = String.replace_prefix(table_name, "temp_", "")
    Map.has_key?(core_table_mappings(), clean_table)
  end

  @doc """
  Get all tables that will be created in Phoenix.
  """
  def phoenix_tables do
    core_table_mappings() |> Map.values() |> Enum.uniq()
  end

  @doc """
  Get field mappings for a specific table.
  This will be expanded as we implement schema comparison.
  """
  def get_field_mappings(table_name) do
    case table_name do
      "accounts" ->
        %{
          "id" => "eqemu_id",
          "name" => "name", 
          "password" => "password",
          "status" => "status",
          "time_creation" => "time_creation"
        }
      
      "characters" ->
        %{
          "id" => "eqemu_id",
          "account_id" => "account_id",
          "name" => "name",
          "level" => "level",
          "race" => "race",
          "class" => "class",
          "zone_id" => "zone_id",
          "x" => "x",
          "y" => "y", 
          "z" => "z"
        }
      
      "items" ->
        %{
          "id" => "eqemu_id",
          "name" => "name",
          "itemtype" => "itemtype",
          "weight" => "weight",
          "price" => "price"
        }
      
      _ ->
        %{} # Default to empty mapping, will be filled in by schema comparison
    end
  end

  @doc """
  Format the mapping summary for display.
  """
  def format_mapping_summary do
    mappings = core_table_mappings()
    
    """
    
    === Table Mapping Summary ===
    📋 Total Mappings: #{map_size(mappings)}
    
    🔗 Core Mappings:
    #{format_mapping_list(mappings)}
    
    ✅ Clean Mapping: Original EQEmu tables map directly to Phoenix tables
    ❌ No more eqemu_ prefix confusion!
    """
  end

  defp format_mapping_list(mappings) do
    mappings
    |> Enum.sort()
    |> Enum.map(fn {original, phoenix} ->
      "  #{original} → #{phoenix}"
    end)
    |> Enum.join("\n")
  end
end