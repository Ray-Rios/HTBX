defmodule PhoenixApp.EqemuMigration.SchemaComparator do
  @moduledoc """
  Compares original EQEmu schema with current Phoenix schema to identify differences.
  Handles field mappings, type conversions, and custom schema modifications.
  """

  require Logger

  @type field_mapping :: %{
    original_field: String.t(),
    phoenix_field: String.t(),
    type_conversion: atom(),
    default_value: any(),
    notes: String.t()
  }

  @type table_comparison :: %{
    table_name: String.t(),
    phoenix_table: String.t(),
    field_mappings: [field_mapping()],
    missing_in_phoenix: [String.t()],
    missing_in_original: [String.t()],
    type_mismatches: [field_mapping()]
  }

  @doc """
  Compare original EQEmu schema with current Phoenix schema.
  """
  def compare_schemas do
    Logger.info("Starting schema comparison between original EQEmu and Phoenix schemas")
    
    comparisons = [
      compare_account_tables(),
      compare_character_tables(),
      compare_character_stats_tables(),
      compare_item_tables(),
      compare_guild_tables(),
      compare_zone_tables()
    ]
    
    Logger.info("Schema comparison complete. Found #{length(comparisons)} table comparisons")
    
    %{
      comparisons: comparisons,
      summary: generate_comparison_summary(comparisons),
      timestamp: DateTime.utc_now()
    }
  end

  @doc """
  Compare account table schemas.
  """
  defp compare_account_tables do
    %{
      table_name: "account",
      phoenix_table: "eqemu_accounts",
      field_mappings: [
        %{original_field: "id", phoenix_field: "eqemu_id", type_conversion: :direct, default_value: nil, notes: "Primary key mapping"},
        %{original_field: "name", phoenix_field: "name", type_conversion: :direct, default_value: nil, notes: "Account name"},
        %{original_field: "charname", phoenix_field: "charname", type_conversion: :direct, default_value: nil, notes: "Character name"},
        %{original_field: "sharedplat", phoenix_field: "sharedplat", type_conversion: :direct, default_value: 0, notes: "Shared platinum"},
        %{original_field: "password", phoenix_field: "password", type_conversion: :bcrypt_hash, default_value: nil, notes: "Password hashing"},
        %{original_field: "status", phoenix_field: "status", type_conversion: :direct, default_value: 0, notes: "Account status"},
        %{original_field: "ls_id", phoenix_field: "ls_id", type_conversion: :direct, default_value: nil, notes: "Login server ID"},
        %{original_field: "lsaccount_id", phoenix_field: "lsaccount_id", type_conversion: :direct, default_value: 0, notes: "Login server account ID"},
        %{original_field: "gmspeed", phoenix_field: "gmspeed", type_conversion: :direct, default_value: 0, notes: "GM speed"},
        %{original_field: "revoked", phoenix_field: "revoked", type_conversion: :direct, default_value: 0, notes: "Account revoked status"},
        %{original_field: "karma", phoenix_field: "karma", type_conversion: :direct, default_value: 0, notes: "Account karma"},
        %{original_field: "minilogin_ip", phoenix_field: "minilogin_ip", type_conversion: :direct, default_value: nil, notes: "Mini login IP"},
        %{original_field: "hideme", phoenix_field: "hideme", type_conversion: :direct, default_value: 0, notes: "Hide me flag"},
        %{original_field: "rulesflag", phoenix_field: "rulesflag", type_conversion: :direct, default_value: 0, notes: "Rules flag"},
        %{original_field: "suspendeduntil", phoenix_field: "suspendeduntil", type_conversion: :unix_to_datetime, default_value: nil, notes: "Suspension end time"},
        %{original_field: "time_creation", phoenix_field: "time_creation", type_conversion: :direct, default_value: 0, notes: "Account creation time"},
        %{original_field: "expansion", phoenix_field: "expansion", type_conversion: :direct, default_value: 8, notes: "Expansion level"}
      ],
      missing_in_phoenix: [],
      missing_in_original: ["user_id"],
      type_mismatches: []
    }
  end

  @doc """
  Compare character table schemas with custom field mappings.
  """
  defp compare_character_tables do
    %{
      table_name: "character_data",
      phoenix_table: "eqemu_characters",
      field_mappings: [
        %{original_field: "id", phoenix_field: "eqemu_id", type_conversion: :direct, default_value: nil, notes: "Primary key mapping"},
        %{original_field: "account_id", phoenix_field: "account_id", type_conversion: :direct, default_value: nil, notes: "Account reference"},
        %{original_field: "name", phoenix_field: "name", type_conversion: :direct, default_value: nil, notes: "Character name"},
        %{original_field: "level", phoenix_field: "level", type_conversion: :direct, default_value: 1, notes: "Character level"},
        %{original_field: "race", phoenix_field: "race", type_conversion: :direct, default_value: nil, notes: "Character race"},
        %{original_field: "class", phoenix_field: "class", type_conversion: :direct, default_value: nil, notes: "Character class"},
        %{original_field: "gender", phoenix_field: "gender", type_conversion: :direct, default_value: 0, notes: "Character gender"},
        %{original_field: "zone_id", phoenix_field: "zone_id", type_conversion: :direct, default_value: 1, notes: "Current zone"},
        %{original_field: "zone_instance", phoenix_field: "zone_instance", type_conversion: :direct, default_value: 0, notes: "Zone instance"},
        %{original_field: "x", phoenix_field: "x", type_conversion: :direct, default_value: 0.0, notes: "X coordinate"},
        %{original_field: "y", phoenix_field: "y", type_conversion: :direct, default_value: 0.0, notes: "Y coordinate"},
        %{original_field: "z", phoenix_field: "z", type_conversion: :direct, default_value: 0.0, notes: "Z coordinate"},
        %{original_field: "heading", phoenix_field: "heading", type_conversion: :direct, default_value: 0.0, notes: "Character heading"},
        %{original_field: "hp", phoenix_field: "hp", type_conversion: :direct, default_value: 100, notes: "Hit points"},
        %{original_field: "mana", phoenix_field: "mana", type_conversion: :direct, default_value: 0, notes: "Mana points"},
        %{original_field: "endurance", phoenix_field: "endurance", type_conversion: :direct, default_value: 100, notes: "Endurance points"},
        %{original_field: "exp", phoenix_field: "exp", type_conversion: :direct, default_value: 0, notes: "Experience points"},
        %{original_field: "aa_points_spent", phoenix_field: "aa_points_spent", type_conversion: :direct, default_value: 0, notes: "AA points spent"},
        %{original_field: "aa_exp", phoenix_field: "aa_exp", type_conversion: :direct, default_value: 0, notes: "AA experience"},
        %{original_field: "platinum", phoenix_field: "platinum", type_conversion: :direct, default_value: 0, notes: "Platinum currency"},
        %{original_field: "gold", phoenix_field: "gold", type_conversion: :direct, default_value: 0, notes: "Gold currency"},
        %{original_field: "silver", phoenix_field: "silver", type_conversion: :direct, default_value: 0, notes: "Silver currency"},
        %{original_field: "copper", phoenix_field: "copper", type_conversion: :direct, default_value: 0, notes: "Copper currency"},
        %{original_field: "platinum_bank", phoenix_field: "platinum_bank", type_conversion: :direct, default_value: 0, notes: "Banked platinum"},
        %{original_field: "gold_bank", phoenix_field: "gold_bank", type_conversion: :direct, default_value: 0, notes: "Banked gold"},
        %{original_field: "silver_bank", phoenix_field: "silver_bank", type_conversion: :direct, default_value: 0, notes: "Banked silver"},
        %{original_field: "copper_bank", phoenix_field: "copper_bank", type_conversion: :direct, default_value: 0, notes: "Banked copper"},
        %{original_field: "platinum_cursor", phoenix_field: "platinum_cursor", type_conversion: :direct, default_value: 0, notes: "Cursor platinum"},
        %{original_field: "gold_cursor", phoenix_field: "gold_cursor", type_conversion: :direct, default_value: 0, notes: "Cursor gold"},
        %{original_field: "silver_cursor", phoenix_field: "silver_cursor", type_conversion: :direct, default_value: 0, notes: "Cursor silver"},
        %{original_field: "copper_cursor", phoenix_field: "copper_cursor", type_conversion: :direct, default_value: 0, notes: "Cursor copper"},
        %{original_field: "face", phoenix_field: "face", type_conversion: :direct, default_value: 1, notes: "Face appearance"},
        %{original_field: "hair_color", phoenix_field: "hair_color", type_conversion: :direct, default_value: 1, notes: "Hair color"},
        %{original_field: "hair_style", phoenix_field: "hair_style", type_conversion: :direct, default_value: 1, notes: "Hair style"},
        %{original_field: "beard", phoenix_field: "beard", type_conversion: :direct, default_value: 0, notes: "Beard style"},
        %{original_field: "beard_color", phoenix_field: "beard_color", type_conversion: :direct, default_value: 1, notes: "Beard color"},
        %{original_field: "eye_color_1", phoenix_field: "eye_color_1", type_conversion: :direct, default_value: 1, notes: "Primary eye color"},
        %{original_field: "eye_color_2", phoenix_field: "eye_color_2", type_conversion: :direct, default_value: 1, notes: "Secondary eye color"},
        %{original_field: "drakkin_heritage", phoenix_field: "drakkin_heritage", type_conversion: :direct, default_value: 0, notes: "Drakkin heritage"},
        %{original_field: "drakkin_tattoo", phoenix_field: "drakkin_tattoo", type_conversion: :direct, default_value: 0, notes: "Drakkin tattoo"},
        %{original_field: "drakkin_details", phoenix_field: "drakkin_details", type_conversion: :direct, default_value: 0, notes: "Drakkin details"},
        %{original_field: "deity", phoenix_field: "deity", type_conversion: :direct, default_value: 396, notes: "Character deity"},
        %{original_field: "birthday", phoenix_field: "birthday", type_conversion: :direct, default_value: 0, notes: "Character birthday"},
        %{original_field: "last_login", phoenix_field: "last_login", type_conversion: :direct, default_value: 0, notes: "Last login time"},
        %{original_field: "time_played", phoenix_field: "time_played", type_conversion: :direct, default_value: 0, notes: "Total time played"},
        %{original_field: "pvp_status", phoenix_field: "pvp_status", type_conversion: :direct, default_value: 0, notes: "PVP status"},
        %{original_field: "level2", phoenix_field: "level2", type_conversion: :direct, default_value: 0, notes: "Secondary level"},
        %{original_field: "anon", phoenix_field: "anon", type_conversion: :direct, default_value: 0, notes: "Anonymous flag"},
        %{original_field: "gm", phoenix_field: "gm", type_conversion: :direct, default_value: 0, notes: "GM flag"},
        %{original_field: "intoxication", phoenix_field: "intoxication", type_conversion: :direct, default_value: 0, notes: "Intoxication level"},
        %{original_field: "exp_enabled", phoenix_field: "exp_enabled", type_conversion: :direct, default_value: 1, notes: "Experience enabled"},
        %{original_field: "aa_points", phoenix_field: "aa_points", type_conversion: :direct, default_value: 0, notes: "Available AA points"},
        %{original_field: "group_leadership_exp", phoenix_field: "group_leadership_exp", type_conversion: :direct, default_value: 0, notes: "Group leadership exp"},
        %{original_field: "raid_leadership_exp", phoenix_field: "raid_leadership_exp", type_conversion: :direct, default_value: 0, notes: "Raid leadership exp"},
        %{original_field: "group_leadership_points", phoenix_field: "group_leadership_points", type_conversion: :direct, default_value: 0, notes: "Group leadership points"},
        %{original_field: "raid_leadership_points", phoenix_field: "raid_leadership_points", type_conversion: :direct, default_value: 0, notes: "Raid leadership points"},
        %{original_field: "mailkey", phoenix_field: "mailkey", type_conversion: :direct, default_value: nil, notes: "Mail key"},
        %{original_field: "xtargets", phoenix_field: "xtargets", type_conversion: :direct, default_value: 5, notes: "Extended targets"},
        %{original_field: "firstlogon", phoenix_field: "firstlogon", type_conversion: :direct, default_value: 0, notes: "First logon flag"},
        %{original_field: "e_aa_effects", phoenix_field: "e_aa_effects", type_conversion: :direct, default_value: 0, notes: "AA effects"},
        %{original_field: "e_percent_to_aa", phoenix_field: "e_percent_to_aa", type_conversion: :direct, default_value: 0, notes: "Percent to AA"},
        %{original_field: "e_expended_aa_spent", phoenix_field: "e_expended_aa_spent", type_conversion: :direct, default_value: 0, notes: "Expended AA spent"}
      ],
      missing_in_phoenix: [],
      missing_in_original: ["user_id", "heart", "triforce"],
      type_mismatches: []
    }
  end 
 @doc """
  Compare character stats table schemas with corrected field names (removing extra 'a').
  """
  defp compare_character_stats_tables do
    %{
      table_name: "character_stats",
      phoenix_table: "eqemu_character_stats",
      field_mappings: [
        # Base stats - removing extra 'a' from original EQEmu names
        %{original_field: "stra", phoenix_field: "str", type_conversion: :direct, default_value: 75, notes: "Strength (removed extra 'a')"},
        %{original_field: "staa", phoenix_field: "sta", type_conversion: :direct, default_value: 75, notes: "Stamina (removed extra 'a')"},
        %{original_field: "chaa", phoenix_field: "cha", type_conversion: :direct, default_value: 75, notes: "Charisma (removed extra 'a')"},
        %{original_field: "dexa", phoenix_field: "dex", type_conversion: :direct, default_value: 75, notes: "Dexterity (removed extra 'a')"},
        %{original_field: "inta", phoenix_field: "int", type_conversion: :direct, default_value: 75, notes: "Intelligence (removed extra 'a')"},
        %{original_field: "agia", phoenix_field: "agi", type_conversion: :direct, default_value: 75, notes: "Agility (removed extra 'a')"},
        %{original_field: "wisa", phoenix_field: "wis", type_conversion: :direct, default_value: 75, notes: "Wisdom (removed extra 'a')"},
        
        # Combat stats
        %{original_field: "atk", phoenix_field: "atk", type_conversion: :direct, default_value: 100, notes: "Attack rating"},
        %{original_field: "ac", phoenix_field: "ac", type_conversion: :direct, default_value: 0, notes: "Armor class"},
        %{original_field: "hp_regen_rate", phoenix_field: "hp_regen_rate", type_conversion: :direct, default_value: 1, notes: "HP regeneration rate"},
        %{original_field: "mana_regen_rate", phoenix_field: "mana_regen_rate", type_conversion: :direct, default_value: 1, notes: "Mana regeneration rate"},
        %{original_field: "endurance_regen_rate", phoenix_field: "endurance_regen_rate", type_conversion: :direct, default_value: 1, notes: "Endurance regeneration rate"},
        %{original_field: "attack_speed", phoenix_field: "attack_speed", type_conversion: :direct, default_value: 0.0, notes: "Attack speed modifier"},
        %{original_field: "accuracy", phoenix_field: "accuracy", type_conversion: :direct, default_value: 0, notes: "Accuracy rating"},
        %{original_field: "avoidance", phoenix_field: "avoidance", type_conversion: :direct, default_value: 0, notes: "Avoidance rating"},
        %{original_field: "combat_effects", phoenix_field: "combat_effects", type_conversion: :direct, default_value: 0, notes: "Combat effects"},
        %{original_field: "shielding", phoenix_field: "shielding", type_conversion: :direct, default_value: 0, notes: "Shielding rating"},
        %{original_field: "spell_shielding", phoenix_field: "spell_shielding", type_conversion: :direct, default_value: 0, notes: "Spell shielding"},
        %{original_field: "dot_shielding", phoenix_field: "dot_shielding", type_conversion: :direct, default_value: 0, notes: "DOT shielding"},
        %{original_field: "damage_shield", phoenix_field: "damage_shield", type_conversion: :direct, default_value: 0, notes: "Damage shield"},
        %{original_field: "damage_shield_mitigation", phoenix_field: "damage_shield_mitigation", type_conversion: :direct, default_value: 0, notes: "Damage shield mitigation"},
        
        # Heroic stats
        %{original_field: "heroic_str", phoenix_field: "heroic_str", type_conversion: :direct, default_value: 0, notes: "Heroic strength"},
        %{original_field: "heroic_int", phoenix_field: "heroic_int", type_conversion: :direct, default_value: 0, notes: "Heroic intelligence"},
        %{original_field: "heroic_wis", phoenix_field: "heroic_wis", type_conversion: :direct, default_value: 0, notes: "Heroic wisdom"},
        %{original_field: "heroic_agi", phoenix_field: "heroic_agi", type_conversion: :direct, default_value: 0, notes: "Heroic agility"},
        %{original_field: "heroic_dex", phoenix_field: "heroic_dex", type_conversion: :direct, default_value: 0, notes: "Heroic dexterity"},
        %{original_field: "heroic_sta", phoenix_field: "heroic_sta", type_conversion: :direct, default_value: 0, notes: "Heroic stamina"},
        %{original_field: "heroic_cha", phoenix_field: "heroic_cha", type_conversion: :direct, default_value: 0, notes: "Heroic charisma"},
        
        # Resistances
        %{original_field: "mr", phoenix_field: "mr", type_conversion: :direct, default_value: 0, notes: "Magic resistance"},
        %{original_field: "fr", phoenix_field: "fr", type_conversion: :direct, default_value: 0, notes: "Fire resistance"},
        %{original_field: "cr", phoenix_field: "cr", type_conversion: :direct, default_value: 0, notes: "Cold resistance"},
        %{original_field: "pr", phoenix_field: "pr", type_conversion: :direct, default_value: 0, notes: "Poison resistance"},
        %{original_field: "dr", phoenix_field: "dr", type_conversion: :direct, default_value: 0, notes: "Disease resistance"},
        %{original_field: "corrup", phoenix_field: "corrup", type_conversion: :direct, default_value: 0, notes: "Corruption resistance"}
      ],
      missing_in_phoenix: [],
      missing_in_original: ["character_id"],
      type_mismatches: []
    }
  end

  @doc """
  Compare item table schemas with custom field mappings (aug -> materia).
  """
  defp compare_item_tables do
    %{
      table_name: "items",
      phoenix_table: "eqemu_items",
      field_mappings: [
        %{original_field: "id", phoenix_field: "eqemu_id", type_conversion: :direct, default_value: nil, notes: "Primary key mapping"},
        %{original_field: "name", phoenix_field: "name", type_conversion: :direct, default_value: nil, notes: "Item name"},
        %{original_field: "itemtype", phoenix_field: "itemtype", type_conversion: :direct, default_value: 0, notes: "Item type"},
        %{original_field: "weight", phoenix_field: "weight", type_conversion: :direct, default_value: 0, notes: "Item weight"},
        %{original_field: "reqlevel", phoenix_field: "reqlevel", type_conversion: :direct, default_value: 0, notes: "Required level"},
        %{original_field: "classes", phoenix_field: "classes", type_conversion: :direct, default_value: 65535, notes: "Usable classes bitmask"},
        %{original_field: "races", phoenix_field: "races", type_conversion: :direct, default_value: 65535, notes: "Usable races bitmask"},
        
        # Augmentation -> Materia renaming
        %{original_field: "augtype", phoenix_field: "materia_type", type_conversion: :direct, default_value: 0, notes: "Materia type (was augtype)"},
        %{original_field: "augslot1type", phoenix_field: "materia_slot1_type", type_conversion: :direct, default_value: 0, notes: "Materia slot 1 type (was augslot1type)"},
        %{original_field: "augslot2type", phoenix_field: "materia_slot2_type", type_conversion: :direct, default_value: 0, notes: "Materia slot 2 type (was augslot2type)"},
        %{original_field: "augslot3type", phoenix_field: "materia_slot3_type", type_conversion: :direct, default_value: 0, notes: "Materia slot 3 type (was augslot3type)"},
        %{original_field: "augslot4type", phoenix_field: "materia_slot4_type", type_conversion: :direct, default_value: 0, notes: "Materia slot 4 type (was augslot4type)"},
        %{original_field: "augslot5type", phoenix_field: "materia_slot5_type", type_conversion: :direct, default_value: 0, notes: "Materia slot 5 type (was augslot5type)"},
        %{original_field: "augslot6type", phoenix_field: "materia_slot6_type", type_conversion: :direct, default_value: 0, notes: "Materia slot 6 type (was augslot6type)"},
        %{original_field: "augslot1visible", phoenix_field: "materia_slot1_visible", type_conversion: :direct, default_value: 0, notes: "Materia slot 1 visible (was augslot1visible)"},
        %{original_field: "augslot2visible", phoenix_field: "materia_slot2_visible", type_conversion: :direct, default_value: 0, notes: "Materia slot 2 visible (was augslot2visible)"},
        %{original_field: "augslot3visible", phoenix_field: "materia_slot3_visible", type_conversion: :direct, default_value: 0, notes: "Materia slot 3 visible (was augslot3visible)"},
        %{original_field: "augslot4visible", phoenix_field: "materia_slot4_visible", type_conversion: :direct, default_value: 0, notes: "Materia slot 4 visible (was augslot4visible)"},
        %{original_field: "augslot5visible", phoenix_field: "materia_slot5_visible", type_conversion: :direct, default_value: 0, notes: "Materia slot 5 visible (was augslot5visible)"},
        %{original_field: "augslot6visible", phoenix_field: "materia_slot6_visible", type_conversion: :direct, default_value: 0, notes: "Materia slot 6 visible (was augslot6visible)"}
      ],
      missing_in_phoenix: [],
      missing_in_original: [],
      type_mismatches: []
    }
  end

  @doc """
  Compare guild table schemas with custom field mappings (tribute -> dkp).
  """
  defp compare_guild_tables do
    %{
      table_name: "guilds",
      phoenix_table: "eqemu_guilds",
      field_mappings: [
        %{original_field: "id", phoenix_field: "eqemu_id", type_conversion: :direct, default_value: nil, notes: "Primary key mapping"},
        %{original_field: "name", phoenix_field: "name", type_conversion: :direct, default_value: nil, notes: "Guild name"},
        %{original_field: "leader", phoenix_field: "leader", type_conversion: :direct, default_value: 0, notes: "Guild leader character ID"},
        %{original_field: "minstatus", phoenix_field: "minstatus", type_conversion: :direct, default_value: 0, notes: "Minimum status to join"},
        %{original_field: "motd", phoenix_field: "motd", type_conversion: :direct, default_value: nil, notes: "Message of the day"},
        %{original_field: "motd_setter", phoenix_field: "motd_setter", type_conversion: :direct, default_value: nil, notes: "MOTD setter"},
        %{original_field: "channel", phoenix_field: "channel", type_conversion: :direct, default_value: nil, notes: "Guild channel"},
        %{original_field: "url", phoenix_field: "url", type_conversion: :direct, default_value: nil, notes: "Guild URL"},
        
        # Tribute -> DKP renaming
        %{original_field: "tribute", phoenix_field: "dkp_enabled", type_conversion: :boolean_conversion, default_value: false, notes: "DKP system enabled (was tribute)"},
        %{original_field: "tribute_time", phoenix_field: "dkp_last_update", type_conversion: :unix_to_datetime, default_value: nil, notes: "DKP last update time (was tribute_time)"}
      ],
      missing_in_phoenix: [],
      missing_in_original: [],
      type_mismatches: []
    }
  end

  @doc """
  Compare zone table schemas.
  """
  defp compare_zone_tables do
    %{
      table_name: "zone",
      phoenix_table: "eqemu_zones",
      field_mappings: [
        %{original_field: "zoneidnumber", phoenix_field: "eqemu_id", type_conversion: :direct, default_value: nil, notes: "Primary key mapping"},
        %{original_field: "short_name", phoenix_field: "short_name", type_conversion: :direct, default_value: nil, notes: "Zone short name"},
        %{original_field: "long_name", phoenix_field: "long_name", type_conversion: :direct, default_value: nil, notes: "Zone long name"},
        %{original_field: "file_name", phoenix_field: "file_name", type_conversion: :direct, default_value: nil, notes: "Zone file name"},
        %{original_field: "description", phoenix_field: "description", type_conversion: :direct, default_value: nil, notes: "Zone description"},
        %{original_field: "note", phoenix_field: "note", type_conversion: :direct, default_value: nil, notes: "Zone notes"},
        %{original_field: "expansion", phoenix_field: "expansion", type_conversion: :direct, default_value: 0, notes: "Required expansion"},
        %{original_field: "min_level", phoenix_field: "min_level", type_conversion: :direct, default_value: 0, notes: "Minimum level"},
        %{original_field: "max_level", phoenix_field: "max_level", type_conversion: :direct, default_value: 255, notes: "Maximum level"},
        %{original_field: "min_status", phoenix_field: "min_status", type_conversion: :direct, default_value: 0, notes: "Minimum status"},
        %{original_field: "zonetype", phoenix_field: "zonetype", type_conversion: :direct, default_value: 1, notes: "Zone type"},
        %{original_field: "version", phoenix_field: "version", type_conversion: :direct, default_value: 0, notes: "Zone version"},
        %{original_field: "timezone", phoenix_field: "timezone", type_conversion: :direct, default_value: 0, notes: "Zone timezone"},
        %{original_field: "maxclients", phoenix_field: "maxclients", type_conversion: :direct, default_value: 0, notes: "Maximum clients"},
        %{original_field: "ruleset", phoenix_field: "ruleset", type_conversion: :direct, default_value: 1, notes: "Zone ruleset"},
        %{original_field: "underworld", phoenix_field: "underworld", type_conversion: :direct, default_value: 0.0, notes: "Underworld Z coordinate"},
        %{original_field: "minclip", phoenix_field: "minclip", type_conversion: :direct, default_value: 450.0, notes: "Minimum clip distance"},
        %{original_field: "maxclip", phoenix_field: "maxclip", type_conversion: :direct, default_value: 450.0, notes: "Maximum clip distance"},
        %{original_field: "fog_minclip", phoenix_field: "fog_minclip", type_conversion: :direct, default_value: 450.0, notes: "Fog minimum clip"},
        %{original_field: "fog_maxclip", phoenix_field: "fog_maxclip", type_conversion: :direct, default_value: 450.0, notes: "Fog maximum clip"},
        %{original_field: "fog_blue", phoenix_field: "fog_blue", type_conversion: :direct, default_value: 0, notes: "Fog blue component"},
        %{original_field: "fog_red", phoenix_field: "fog_red", type_conversion: :direct, default_value: 0, notes: "Fog red component"},
        %{original_field: "fog_green", phoenix_field: "fog_green", type_conversion: :direct, default_value: 0, notes: "Fog green component"},
        %{original_field: "sky", phoenix_field: "sky", type_conversion: :direct, default_value: 1, notes: "Sky type"},
        %{original_field: "ztype", phoenix_field: "ztype", type_conversion: :direct, default_value: 1, notes: "Zone type"},
        %{original_field: "zone_exp_multiplier", phoenix_field: "zone_exp_multiplier", type_conversion: :direct, default_value: 0.0, notes: "Experience multiplier"},
        %{original_field: "walkspeed", phoenix_field: "walkspeed", type_conversion: :direct, default_value: 0.4, notes: "Walk speed"},
        %{original_field: "time_type", phoenix_field: "time_type", type_conversion: :direct, default_value: 2, notes: "Time type"},
        %{original_field: "fog_density", phoenix_field: "fog_density", type_conversion: :direct, default_value: 0.0, notes: "Fog density"},
        %{original_field: "flag_needed", phoenix_field: "flag_needed", type_conversion: :direct, default_value: nil, notes: "Required flag"},
        %{original_field: "canbind", phoenix_field: "canbind", type_conversion: :direct, default_value: 1, notes: "Can bind in zone"},
        %{original_field: "cancombat", phoenix_field: "cancombat", type_conversion: :direct, default_value: 1, notes: "Can combat in zone"},
        %{original_field: "canlevitate", phoenix_field: "canlevitate", type_conversion: :direct, default_value: 1, notes: "Can levitate in zone"},
        %{original_field: "castoutdoor", phoenix_field: "castoutdoor", type_conversion: :direct, default_value: 1, notes: "Can cast outdoor spells"},
        %{original_field: "hotzone", phoenix_field: "hotzone", type_conversion: :direct, default_value: 0, notes: "Hot zone flag"},
        %{original_field: "insttype", phoenix_field: "insttype", type_conversion: :direct, default_value: 0, notes: "Instance type"},
        %{original_field: "shutdowndelay", phoenix_field: "shutdowndelay", type_conversion: :direct, default_value: 5000, notes: "Shutdown delay"},
        %{original_field: "peqzone", phoenix_field: "peqzone", type_conversion: :direct, default_value: 1, notes: "PEQ zone flag"},
        %{original_field: "bypass_expansion_check", phoenix_field: "bypass_expansion_check", type_conversion: :direct, default_value: 0, notes: "Bypass expansion check"},
        %{original_field: "suspendbuffs", phoenix_field: "suspendbuffs", type_conversion: :direct, default_value: 0, notes: "Suspend buffs"},
        %{original_field: "rain_chance1", phoenix_field: "rain_chance1", type_conversion: :direct, default_value: 0, notes: "Rain chance 1"},
        %{original_field: "rain_chance2", phoenix_field: "rain_chance2", type_conversion: :direct, default_value: 0, notes: "Rain chance 2"},
        %{original_field: "rain_chance3", phoenix_field: "rain_chance3", type_conversion: :direct, default_value: 0, notes: "Rain chance 3"},
        %{original_field: "rain_chance4", phoenix_field: "rain_chance4", type_conversion: :direct, default_value: 0, notes: "Rain chance 4"},
        %{original_field: "rain_duration1", phoenix_field: "rain_duration1", type_conversion: :direct, default_value: 0, notes: "Rain duration 1"},
        %{original_field: "rain_duration2", phoenix_field: "rain_duration2", type_conversion: :direct, default_value: 0, notes: "Rain duration 2"},
        %{original_field: "rain_duration3", phoenix_field: "rain_duration3", type_conversion: :direct, default_value: 0, notes: "Rain duration 3"},
        %{original_field: "rain_duration4", phoenix_field: "rain_duration4", type_conversion: :direct, default_value: 0, notes: "Rain duration 4"},
        %{original_field: "snow_chance1", phoenix_field: "snow_chance1", type_conversion: :direct, default_value: 0, notes: "Snow chance 1"},
        %{original_field: "snow_chance2", phoenix_field: "snow_chance2", type_conversion: :direct, default_value: 0, notes: "Snow chance 2"},
        %{original_field: "snow_chance3", phoenix_field: "snow_chance3", type_conversion: :direct, default_value: 0, notes: "Snow chance 3"},
        %{original_field: "snow_chance4", phoenix_field: "snow_chance4", type_conversion: :direct, default_value: 0, notes: "Snow chance 4"},
        %{original_field: "snow_duration1", phoenix_field: "snow_duration1", type_conversion: :direct, default_value: 0, notes: "Snow duration 1"},
        %{original_field: "snow_duration2", phoenix_field: "snow_duration2", type_conversion: :direct, default_value: 0, notes: "Snow duration 2"},
        %{original_field: "snow_duration3", phoenix_field: "snow_duration3", type_conversion: :direct, default_value: 0, notes: "Snow duration 3"},
        %{original_field: "snow_duration4", phoenix_field: "snow_duration4", type_conversion: :direct, default_value: 0, notes: "Snow duration 4"},
        %{original_field: "gravity", phoenix_field: "gravity", type_conversion: :direct, default_value: 0.4, notes: "Zone gravity"},
        %{original_field: "type", phoenix_field: "type", type_conversion: :direct, default_value: 0, notes: "Zone type"}
      ],
      missing_in_phoenix: [],
      missing_in_original: [],
      type_mismatches: []
    }
  end

  @doc """
  Generate a summary of all schema comparisons.
  """
  defp generate_comparison_summary(comparisons) do
    total_mappings = comparisons |> Enum.map(&length(&1.field_mappings)) |> Enum.sum()
    total_missing_phoenix = comparisons |> Enum.map(&length(&1.missing_in_phoenix)) |> Enum.sum()
    total_missing_original = comparisons |> Enum.map(&length(&1.missing_in_original)) |> Enum.sum()
    total_type_mismatches = comparisons |> Enum.map(&length(&1.type_mismatches)) |> Enum.sum()
    
    custom_mappings = 
      comparisons
      |> Enum.flat_map(& &1.field_mappings)
      |> Enum.filter(fn mapping -> 
        mapping.type_conversion != :direct or 
        mapping.original_field != mapping.phoenix_field or
        String.contains?(mapping.notes, ["was ", "removed ", "Materia", "DKP"])
      end)
    
    %{
      total_tables: length(comparisons),
      total_field_mappings: total_mappings,
      total_missing_in_phoenix: total_missing_phoenix,
      total_missing_in_original: total_missing_original,
      total_type_mismatches: total_type_mismatches,
      custom_mappings_count: length(custom_mappings),
      custom_mappings: custom_mappings
    }
  end

  @doc """
  Get field differences for a specific table.
  """
  def get_field_differences(table_name) do
    comparison = 
      compare_schemas()
      |> Map.get(:comparisons)
      |> Enum.find(&(&1.table_name == table_name))
    
    case comparison do
      nil -> {:error, :table_not_found}
      comp -> {:ok, comp}
    end
  end

  @doc """
  Identify missing fields in Phoenix schema.
  """
  def identify_missing_fields(table_name) do
    case get_field_differences(table_name) do
      {:ok, comparison} -> comparison.missing_in_phoenix
      {:error, _} -> []
    end
  end

  @doc """
  Format schema comparison results for display.
  """
  def format_comparison_results(comparison_result) do
    summary = comparison_result.summary
    
    """
    
    === Schema Comparison Results ===
    📊 Analysis completed: #{DateTime.to_string(comparison_result.timestamp)}
    📋 Tables compared: #{summary.total_tables}
    🔗 Total field mappings: #{summary.total_field_mappings}
    ⚠️  Missing in Phoenix: #{summary.total_missing_in_phoenix}
    ➕ Missing in Original: #{summary.total_missing_in_original}
    🔄 Type mismatches: #{summary.total_type_mismatches}
    ⭐ Custom mappings: #{summary.custom_mappings_count}
    
    🎯 Key Custom Mappings:
    #{format_custom_mappings(summary.custom_mappings)}
    
    📋 Table Details:
    #{format_table_comparisons(comparison_result.comparisons)}
    """
  end

  defp format_custom_mappings(custom_mappings) do
    custom_mappings
    |> Enum.take(10)
    |> Enum.map(fn mapping ->
      "  • #{mapping.original_field} → #{mapping.phoenix_field} (#{mapping.notes})"
    end)
    |> Enum.join("\n")
  end

  defp format_table_comparisons(comparisons) do
    comparisons
    |> Enum.map(fn comp ->
      """
      
      📋 #{comp.table_name} → #{comp.phoenix_table}
        🔗 Mappings: #{length(comp.field_mappings)}
        ⚠️  Missing in Phoenix: #{length(comp.missing_in_phoenix)}
        ➕ Missing in Original: #{length(comp.missing_in_original)}
      """
    end)
    |> Enum.join("")
  end
end