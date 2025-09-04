defmodule PhoenixApp.Repo.Migrations.CreateEqemuSchema do
  use Ecto.Migration

  def change do
    # Characters
    create table(:eqemu_characters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id), null: false
      add :character_id, :integer, null: false  # Original EQEmu character ID
      add :name, :string, null: false
      add :level, :integer, default: 1
      add :race, :integer, null: false
      add :class, :integer, null: false
      add :gender, :integer, default: 0
      add :zone_id, :integer, default: 1
      add :zone_instance, :integer, default: 0
      add :x, :float, default: 0.0
      add :y, :float, default: 0.0
      add :z, :float, default: 0.0
      add :heading, :float, default: 0.0
      add :hp, :integer, default: 100
      add :mana, :integer, default: 0
      add :endurance, :integer, default: 100
      add :experience, :bigint, default: 0
      add :aa_points_spent, :integer, default: 0
      add :aa_exp, :integer, default: 0
      add :platinum, :integer, default: 0
      add :gold, :integer, default: 0
      add :silver, :integer, default: 0
      add :copper, :integer, default: 0
      add :platinum_bank, :integer, default: 0
      add :gold_bank, :integer, default: 0
      add :silver_bank, :integer, default: 0
      add :copper_bank, :integer, default: 0
      add :platinum_cursor, :integer, default: 0
      add :gold_cursor, :integer, default: 0
      add :silver_cursor, :integer, default: 0
      add :copper_cursor, :integer, default: 0
      add :skills, :text  # JSON array of skill values
      add :pp_skills, :text  # JSON array of practice point skills
      add :languages, :text  # JSON array of language skills
      add :face, :integer, default: 1
      add :hair_color, :integer, default: 1
      add :hair_style, :integer, default: 1
      add :beard, :integer, default: 0
      add :beard_color, :integer, default: 1
      add :eye_color_1, :integer, default: 1
      add :eye_color_2, :integer, default: 1
      add :drakkin_heritage, :integer, default: 0
      add :drakkin_tattoo, :integer, default: 0
      add :drakkin_details, :integer, default: 0
      add :deity, :integer, default: 0
      add :guild_id, :integer, default: 0
      add :guild_rank, :integer, default: 0
      add :birthday, :integer, default: 0
      add :last_login, :utc_datetime
      add :time_played, :integer, default: 0
      add :pvp_status, :integer, default: 0
      add :level2, :integer, default: 0
      add :anon, :integer, default: 0
      add :gm, :integer, default: 0
      add :intoxication, :integer, default: 0
      add :exp_enabled, :integer, default: 1
      add :aa_points_spent_old, :integer, default: 0
      add :aa_points, :integer, default: 0
      add :group_leadership_exp, :integer, default: 0
      add :raid_leadership_exp, :integer, default: 0
      add :group_leadership_points, :integer, default: 0
      add :raid_leadership_points, :integer, default: 0
      add :points, :integer, default: 0
      add :cur_hp, :integer, default: 0
      add :mana_regen_rate, :integer, default: 0
      add :endurance_regen_rate, :integer, default: 0
      add :groupAutoConsent, :integer, default: 0
      add :raidAutoConsent, :integer, default: 0
      add :guildAutoConsent, :integer, default: 0
      add :leadership_exp_on, :integer, default: 0
      add :RestTimer, :integer, default: 0
      add :air_remaining, :integer, default: 0
      add :autosplit_enabled, :integer, default: 0
      add :lfp, :integer, default: 0
      add :lfg, :integer, default: 0
      add :mailkey, :string
      add :xtargets, :integer, default: 5
      add :firstlogon, :integer, default: 0
      add :e_aa_effects, :integer, default: 0
      add :e_percent_to_aa, :integer, default: 0
      add :e_expended_aa_spent, :integer, default: 0
      add :aa_points_spent_old2, :integer, default: 0
      add :e_last_invsnapshot, :integer, default: 0
      add :deleted_at, :utc_datetime

      timestamps()
    end

    create unique_index(:eqemu_characters, [:character_id])
    create unique_index(:eqemu_characters, [:name])
    create index(:eqemu_characters, [:user_id])
    create index(:eqemu_characters, [:level])
    create index(:eqemu_characters, [:zone_id])
    create index(:eqemu_characters, [:guild_id])
    create index(:eqemu_characters, [:deleted_at])

    # Character Stats
    create table(:eqemu_character_stats, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :character_id, references(:eqemu_characters, type: :binary_id), null: false
      add :str, :integer, default: 75
      add :sta, :integer, default: 75
      add :cha, :integer, default: 75
      add :dex, :integer, default: 75
      add :int, :integer, default: 75
      add :agi, :integer, default: 75
      add :wis, :integer, default: 75
      add :atk, :integer, default: 100
      add :ac, :integer, default: 0
      add :hp_regen_rate, :integer, default: 1
      add :mana_regen_rate, :integer, default: 1
      add :endurance_regen_rate, :integer, default: 1
      add :attack_speed, :float, default: 0.0
      add :accuracy, :integer, default: 0
      add :avoidance, :integer, default: 0
      add :combat_effects, :integer, default: 0
      add :shielding, :integer, default: 0
      add :spell_shielding, :integer, default: 0
      add :dot_shielding, :integer, default: 0
      add :damage_shield, :integer, default: 0
      add :damage_shield_mitigation, :integer, default: 0
      add :heroic_str, :integer, default: 0
      add :heroic_int, :integer, default: 0
      add :heroic_wis, :integer, default: 0
      add :heroic_agi, :integer, default: 0
      add :heroic_dex, :integer, default: 0
      add :heroic_sta, :integer, default: 0
      add :heroic_cha, :integer, default: 0
      add :mr, :integer, default: 0
      add :fr, :integer, default: 0
      add :cr, :integer, default: 0
      add :pr, :integer, default: 0
      add :dr, :integer, default: 0
      add :corrup, :integer, default: 0

      timestamps()
    end

    create unique_index(:eqemu_character_stats, [:character_id])

    # Items
    create table(:eqemu_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :item_id, :integer, null: false  # Original EQEmu item ID
      add :name, :string, null: false
      add :lore, :text
      add :idfile, :string
      add :lorefile, :string
      add :nodrop, :integer, default: 0
      add :norent, :integer, default: 0
      add :nodonate, :integer, default: 0
      add :cantune, :integer, default: 0
      add :noswap, :integer, default: 0
      add :size, :integer, default: 0
      add :weight, :integer, default: 0
      add :item_type, :integer, default: 0
      add :icon, :integer, default: 0
      add :price, :integer, default: 0
      add :sellrate, :float, default: 1.0
      add :favor, :integer, default: 0
      add :guildfavor, :integer, default: 0
      add :pointtype, :integer, default: 0
      add :bagtype, :integer, default: 0
      add :bagslots, :integer, default: 0
      add :bagsize, :integer, default: 0
      add :bagwr, :integer, default: 0
      add :book, :integer, default: 0
      add :booktype, :integer, default: 0
      add :filename, :string
      add :banedmgrace, :integer, default: 0
      add :banedmgbody, :integer, default: 0
      add :banedmgamt, :integer, default: 0
      add :magic, :integer, default: 0
      add :casttime_, :integer, default: 0
      add :reqlevel, :integer, default: 0
      add :bardtype, :integer, default: 0
      add :bardvalue, :integer, default: 0
      add :light, :integer, default: 0
      add :delay, :integer, default: 0
      add :elemdmgtype, :integer, default: 0
      add :elemdmgamt, :integer, default: 0
      add :range_, :integer, default: 0
      add :damage, :integer, default: 0
      add :color, :integer, default: 0
      add :prestige, :integer, default: 0
      add :classes, :integer, default: 0
      add :races, :integer, default: 0
      add :deity, :integer, default: 0
      add :skillmodtype, :integer, default: 0
      add :skillmodvalue, :integer, default: 0
      add :banedmgraceamt, :integer, default: 0
      add :banedmgbodyamt, :integer, default: 0
      add :worntype, :integer, default: 0
      add :ac, :integer, default: 0
      add :accuracy, :integer, default: 0
      add :aagi, :integer, default: 0
      add :acha, :integer, default: 0
      add :adex, :integer, default: 0
      add :aint, :integer, default: 0
      add :asta, :integer, default: 0
      add :astr, :integer, default: 0
      add :awis, :integer, default: 0
      add :hp, :integer, default: 0
      add :mana, :integer, default: 0
      add :endur, :integer, default: 0
      add :atk, :integer, default: 0
      add :cr, :integer, default: 0
      add :dr, :integer, default: 0
      add :fr, :integer, default: 0
      add :mr, :integer, default: 0
      add :pr, :integer, default: 0
      add :svcorruption, :integer, default: 0
      add :haste, :integer, default: 0
      add :damageshield, :integer, default: 0

      timestamps()
    end

    create unique_index(:eqemu_items, [:item_id])
    create index(:eqemu_items, [:name])
    create index(:eqemu_items, [:item_type])
    create index(:eqemu_items, [:classes])
    create index(:eqemu_items, [:races])

    # Character Inventory
    create table(:eqemu_character_inventory, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :character_id, references(:eqemu_characters, type: :binary_id), null: false
      add :item_id, references(:eqemu_items, type: :binary_id), null: false
      add :slotid, :integer, null: false
      add :charges, :integer, default: 1
      add :color, :integer, default: 0
      add :augslot1, :binary_id
      add :augslot2, :binary_id
      add :augslot3, :binary_id
      add :augslot4, :binary_id
      add :augslot5, :binary_id
      add :augslot6, :binary_id
      add :instnodrop, :integer, default: 0
      add :custom_data, :text
      add :ornamenticon, :integer, default: 0
      add :ornamentidfile, :string
      add :ornament_hero_model, :integer, default: 0

      timestamps()
    end

    create unique_index(:eqemu_character_inventory, [:character_id, :slotid])
    create index(:eqemu_character_inventory, [:item_id])

    # Guilds
    create table(:eqemu_guilds, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :guild_id, :integer, null: false  # Original EQEmu guild ID
      add :name, :string, null: false
      add :leader, :integer, default: 0
      add :moto_of_the_day, :text
      add :channel, :string
      add :url, :string
      add :favor, :integer, default: 0
      add :tribute, :integer, default: 0

      timestamps()
    end

    create unique_index(:eqemu_guilds, [:guild_id])
    create unique_index(:eqemu_guilds, [:name])

    # Guild Members
    create table(:eqemu_guild_members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :guild_id, references(:eqemu_guilds, type: :binary_id), null: false
      add :character_id, references(:eqemu_characters, type: :binary_id), null: false
      add :rank_, :integer, default: 0
      add :tribute_enable, :integer, default: 0
      add :total_tribute, :integer, default: 0
      add :last_tribute, :integer, default: 0
      add :banker, :integer, default: 0
      add :public_note, :text
      add :officer_note, :text

      timestamps()
    end

    create unique_index(:eqemu_guild_members, [:guild_id, :character_id])

    # Zones
    create table(:eqemu_zones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :zoneidnumber, :integer, null: false  # Original EQEmu zone ID
      add :short_name, :string, null: false
      add :long_name, :string, null: false
      add :file_name, :string
      add :map_file_name, :string
      add :safe_x, :float, default: 0.0
      add :safe_y, :float, default: 0.0
      add :safe_z, :float, default: 0.0
      add :safe_heading, :float, default: 0.0
      add :graveyard_id, :float, default: 0.0
      add :min_level, :integer, default: 1
      add :min_status, :integer, default: 0
      add :zoneidnumber, :integer, default: 0
      add :version, :integer, default: 0
      add :timezone, :integer, default: 0
      add :maxclients, :integer, default: 0
      add :ruleset, :integer, default: 0
      add :note, :text
      add :underworld, :float, default: 0.0
      add :minclip, :float, default: 450.0
      add :maxclip, :float, default: 450.0
      add :fog_minclip, :float, default: 450.0
      add :fog_maxclip, :float, default: 450.0
      add :fog_blue, :integer, default: 0
      add :fog_red, :integer, default: 0
      add :fog_green, :integer, default: 0
      add :sky, :integer, default: 1
      add :ztype, :integer, default: 1
      add :zone_exp_multiplier, :decimal, default: 0.00
      add :walkspeed, :float, default: 0.4
      add :time_type, :integer, default: 2
      add :fog_red1, :integer, default: 0
      add :fog_green1, :integer, default: 0
      add :fog_blue1, :integer, default: 0
      add :fog_minclip1, :float, default: 450.0
      add :fog_maxclip1, :float, default: 450.0
      add :fog_red2, :integer, default: 0
      add :fog_green2, :integer, default: 0
      add :fog_blue2, :integer, default: 0
      add :fog_minclip2, :float, default: 450.0
      add :fog_maxclip2, :float, default: 450.0
      add :fog_red3, :integer, default: 0
      add :fog_green3, :integer, default: 0
      add :fog_blue3, :integer, default: 0
      add :fog_minclip3, :float, default: 450.0
      add :fog_maxclip3, :float, default: 450.0
      add :fog_red4, :integer, default: 0
      add :fog_green4, :integer, default: 0
      add :fog_blue4, :integer, default: 0
      add :fog_minclip4, :float, default: 450.0
      add :fog_maxclip4, :float, default: 450.0
      add :flag_needed, :string
      add :canbind, :integer, default: 1
      add :cancombat, :integer, default: 1
      add :canlevitate, :integer, default: 1
      add :castoutdoor, :integer, default: 1
      add :hotzone, :integer, default: 0
      add :insttype, :integer, default: 0
      add :shutdowndelay, :bigint, default: 5000
      add :peqzone, :integer, default: 1
      add :expansion, :integer, default: 0
      add :suspendbuffs, :integer, default: 0
      add :rain_chance1, :integer, default: 0
      add :rain_chance2, :integer, default: 0
      add :rain_chance3, :integer, default: 0
      add :rain_chance4, :integer, default: 0
      add :rain_duration1, :integer, default: 0
      add :rain_duration2, :integer, default: 0
      add :rain_duration3, :integer, default: 0
      add :rain_duration4, :integer, default: 0
      add :snow_chance1, :integer, default: 0
      add :snow_chance2, :integer, default: 0
      add :snow_chance3, :integer, default: 0
      add :snow_chance4, :integer, default: 0
      add :snow_duration1, :integer, default: 0
      add :snow_duration2, :integer, default: 0
      add :snow_duration3, :integer, default: 0
      add :snow_duration4, :integer, default: 0
      add :gravity, :float, default: 0.4
      add :type, :integer, default: 0
      add :skylock, :integer, default: 0
      add :fast_regen_hp, :integer, default: 180
      add :fast_regen_mana, :integer, default: 180
      add :fast_regen_endurance, :integer, default: 180
      add :npc_max_aggro_dist, :integer, default: 600
      add :max_movement_update_range, :integer, default: 600

      timestamps()
    end

    create unique_index(:eqemu_zones, [:zoneidnumber])
    create unique_index(:eqemu_zones, [:short_name])
    create index(:eqemu_zones, [:long_name])
    create index(:eqemu_zones, [:expansion])

    # NPCs
    create table(:eqemu_npcs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :npc_id, :integer, null: false  # Original EQEmu NPC ID
      add :name, :string, null: false
      add :lastname, :string
      add :level, :integer, default: 1
      add :race, :integer, default: 1
      add :class, :integer, default: 1
      add :bodytype, :integer, default: 1
      add :hp, :integer, default: 100
      add :mana, :integer, default: 0
      add :gender, :integer, default: 0
      add :texture, :integer, default: 0
      add :helmtexture, :integer, default: 0
      add :herosforgemodel, :integer, default: 0
      add :size, :float, default: 6.0
      add :hp_regen_rate, :integer, default: 1
      add :mana_regen_rate, :integer, default: 1
      add :loottable_id, :integer, default: 0
      add :merchant_id, :integer, default: 0
      add :alt_currency_id, :integer, default: 0
      add :npc_spells_id, :integer, default: 0
      add :npc_spells_effects_id, :integer, default: 0
      add :npc_faction_id, :integer, default: 0
      add :adventure_template_id, :integer, default: 0
      add :trap_template, :integer, default: 0
      add :mindmg, :integer, default: 1
      add :maxdmg, :integer, default: 1
      add :attack_count, :integer, default: -1
      add :npcspecialattks, :string
      add :special_abilities, :text
      add :aggroradius, :integer, default: 70
      add :assistradius, :integer, default: 0
      add :face, :integer, default: 1
      add :luclin_hairstyle, :integer, default: 1
      add :luclin_haircolor, :integer, default: 1
      add :luclin_eyecolor, :integer, default: 1
      add :luclin_eyecolor2, :integer, default: 1
      add :luclin_beardcolor, :integer, default: 1
      add :luclin_beard, :integer, default: 0
      add :drakkin_heritage, :integer, default: 0
      add :drakkin_tattoo, :integer, default: 0
      add :drakkin_details, :integer, default: 0
      add :armortint_id, :integer, default: 0
      add :armortint_red, :integer, default: 0
      add :armortint_green, :integer, default: 0
      add :armortint_blue, :integer, default: 0
      add :d_melee_texture1, :integer, default: 0
      add :d_melee_texture2, :integer, default: 0
      add :ammo_idfile, :string, default: "IT10"
      add :prim_melee_type, :integer, default: 28
      add :sec_melee_type, :integer, default: 28
      add :ranged_type, :integer, default: 7
      add :runspeed, :float, default: 1.25
      add :mr, :integer, default: 0
      add :cr, :integer, default: 0
      add :dr, :integer, default: 0
      add :fr, :integer, default: 0
      add :pr, :integer, default: 0
      add :corrup, :integer, default: 0
      add :phr, :integer, default: 0
      add :see_invis, :integer, default: 0
      add :see_invis_undead, :integer, default: 0
      add :qglobal, :integer, default: 0
      add :ac, :integer, default: 0
      add :npc_aggro, :integer, default: 0
      add :spawn_limit, :integer, default: 0
      add :attack_speed, :float, default: 0.0
      add :attack_delay, :integer, default: 30
      add :findable, :integer, default: 0
      add :str, :integer, default: 75
      add :sta, :integer, default: 75
      add :dex, :integer, default: 75
      add :agi, :integer, default: 75
      add :int, :integer, default: 80
      add :wis, :integer, default: 75
      add :cha, :integer, default: 75
      add :see_hide, :integer, default: 0
      add :see_improved_hide, :integer, default: 0
      add :trackable, :integer, default: 1
      add :isbot, :integer, default: 0
      add :exclude, :integer, default: 1
      add :atk, :integer, default: 0
      add :accuracy, :integer, default: 0
      add :avoidance, :integer, default: 0
      add :left_ring_idfile, :string, default: "IT10"
      add :right_ring_idfile, :string, default: "IT10"
      add :exp_pct, :integer, default: 100
      add :greed, :integer, default: 0
      add :engage_notice, :integer, default: 0
      add :ignore_despawn, :integer, default: 0
      add :avoidance_cap, :integer, default: 0

      timestamps()
    end

    create unique_index(:eqemu_npcs, [:npc_id])
    create index(:eqemu_npcs, [:name])
    create index(:eqemu_npcs, [:level])
    create index(:eqemu_npcs, [:race])
    create index(:eqemu_npcs, [:class])

    # NPC Spawns
    create table(:eqemu_npc_spawns, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :spawn_id, :integer, null: false
      add :zone_id, references(:eqemu_zones, type: :binary_id), null: false
      add :npc_id, references(:eqemu_npcs, type: :binary_id), null: false
      add :x, :float, default: 0.0
      add :y, :float, default: 0.0
      add :z, :float, default: 0.0
      add :heading, :float, default: 0.0
      add :respawntime, :integer, default: 0
      add :variance, :integer, default: 0
      add :pathgrid, :integer, default: 0
      add :condition_value_filter, :integer, default: 1
      add :cond_id, :integer, default: 0
      add :enabled, :integer, default: 1
      add :animation, :integer, default: 0
      add :boot_respawntime, :integer, default: 0
      add :clear_timer_onboot, :integer, default: 0
      add :boot_variance, :integer, default: 0
      add :force_z, :integer, default: 0
      add :min_expansion, :integer, default: 0
      add :max_expansion, :integer, default: 0

      timestamps()
    end

    create unique_index(:eqemu_npc_spawns, [:spawn_id])
    create index(:eqemu_npc_spawns, [:zone_id])
    create index(:eqemu_npc_spawns, [:npc_id])

    # Spells
    create table(:eqemu_spells, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :spell_id, :integer, null: false
      add :name, :string, null: false
      add :player_1, :string, default: "BLUE_TRAIL"
      add :teleport_zone, :string
      add :you_cast, :string
      add :other_casts, :string
      add :cast_on_you, :string
      add :cast_on_other, :string
      add :spell_fades, :string
      add :range_, :integer, default: 100
      add :aoerange, :integer, default: 0
      add :pushback, :float, default: 0.0
      add :pushup, :float, default: 0.0
      add :cast_time, :integer, default: 0
      add :recovery_time, :integer, default: 0
      add :recast_time, :integer, default: 0
      add :buffdurationformula, :integer, default: 7
      add :buffduration, :integer, default: 65
      add :AEDuration, :integer, default: 0
      add :mana, :integer, default: 0
      add :effect_base_value1, :integer, default: 100
      add :effect_base_value2, :integer, default: 0
      add :effect_base_value3, :integer, default: 0
      add :effect_base_value4, :integer, default: 0
      add :effect_base_value5, :integer, default: 0
      add :effect_base_value6, :integer, default: 0
      add :effect_base_value7, :integer, default: 0
      add :effect_base_value8, :integer, default: 0
      add :effect_base_value9, :integer, default: 0
      add :effect_base_value10, :integer, default: 0
      add :effect_base_value11, :integer, default: 0
      add :effect_base_value12, :integer, default: 0
      add :effect_limit_value1, :integer, default: 0
      add :effect_limit_value2, :integer, default: 0
      add :effect_limit_value3, :integer, default: 0
      add :effect_limit_value4, :integer, default: 0
      add :effect_limit_value5, :integer, default: 0
      add :effect_limit_value6, :integer, default: 0
      add :effect_limit_value7, :integer, default: 0
      add :effect_limit_value8, :integer, default: 0
      add :effect_limit_value9, :integer, default: 0
      add :effect_limit_value10, :integer, default: 0
      add :effect_limit_value11, :integer, default: 0
      add :effect_limit_value12, :integer, default: 0
      add :max1, :integer, default: 0
      add :max2, :integer, default: 0
      add :max3, :integer, default: 0
      add :max4, :integer, default: 0
      add :max5, :integer, default: 0
      add :max6, :integer, default: 0
      add :max7, :integer, default: 0
      add :max8, :integer, default: 0
      add :max9, :integer, default: 0
      add :max10, :integer, default: 0
      add :max11, :integer, default: 0
      add :max12, :integer, default: 0
      add :icon, :integer, default: 0
      add :memicon, :integer, default: 0
      add :components1, :integer, default: -1
      add :components2, :integer, default: -1
      add :components3, :integer, default: -1
      add :components4, :integer, default: -1
      add :component_counts1, :integer, default: 1
      add :component_counts2, :integer, default: 1
      add :component_counts3, :integer, default: 1
      add :component_counts4, :integer, default: 1
      add :NoexpendReagent1, :integer, default: -1
      add :NoexpendReagent2, :integer, default: -1
      add :NoexpendReagent3, :integer, default: -1
      add :NoexpendReagent4, :integer, default: -1
      add :formula1, :integer, default: 100
      add :formula2, :integer, default: 100
      add :formula3, :integer, default: 100
      add :formula4, :integer, default: 100
      add :formula5, :integer, default: 100
      add :formula6, :integer, default: 100
      add :formula7, :integer, default: 100
      add :formula8, :integer, default: 100
      add :formula9, :integer, default: 100
      add :formula10, :integer, default: 100
      add :formula11, :integer, default: 100
      add :formula12, :integer, default: 100
      add :LightType, :integer, default: 0
      add :goodEffect, :integer, default: 0
      add :Activated, :integer, default: 0
      add :resisttype, :integer, default: 0
      add :effectid1, :integer, default: 254
      add :effectid2, :integer, default: 254
      add :effectid3, :integer, default: 254
      add :effectid4, :integer, default: 254
      add :effectid5, :integer, default: 254
      add :effectid6, :integer, default: 254
      add :effectid7, :integer, default: 254
      add :effectid8, :integer, default: 254
      add :effectid9, :integer, default: 254
      add :effectid10, :integer, default: 254
      add :effectid11, :integer, default: 254
      add :effectid12, :integer, default: 254
      add :targettype, :integer, default: 2
      add :basediff, :integer, default: 0
      add :skill, :integer, default: 98
      add :zonetype, :integer, default: -1
      add :EnvironmentType, :integer, default: 0
      add :TimeOfDay, :integer, default: 0
      add :classes1, :integer, default: 255
      add :classes2, :integer, default: 255
      add :classes3, :integer, default: 255
      add :classes4, :integer, default: 255
      add :classes5, :integer, default: 255
      add :classes6, :integer, default: 255
      add :classes7, :integer, default: 255
      add :classes8, :integer, default: 255
      add :classes9, :integer, default: 255
      add :classes10, :integer, default: 255
      add :classes11, :integer, default: 255
      add :classes12, :integer, default: 255
      add :classes13, :integer, default: 255
      add :classes14, :integer, default: 255
      add :classes15, :integer, default: 255
      add :classes16, :integer, default: 255
      add :CastingAnim, :integer, default: 44
      add :TargetAnim, :integer, default: 13
      add :TravelType, :integer, default: 0
      add :SpellAffectIndex, :integer, default: -1
      add :disallow_sit, :integer, default: 0
      add :deities0, :integer, default: 0
      add :deities1, :integer, default: 0
      add :deities2, :integer, default: 0
      add :deities3, :integer, default: 0
      add :deities4, :integer, default: 0
      add :deities5, :integer, default: 0
      add :deities6, :integer, default: 0
      add :deities7, :integer, default: 0
      add :deities8, :integer, default: 0
      add :deities9, :integer, default: 0
      add :deities10, :integer, default: 0
      add :deities11, :integer, default: 0
      add :deities12, :integer, default: 0
      add :deities13, :integer, default: 0
      add :deities14, :integer, default: 0
      add :deities15, :integer, default: 0
      add :deities16, :integer, default: 0
      add :field142, :integer, default: 100
      add :field143, :integer, default: 0
      add :new_icon, :integer, default: 161
      add :spellanim, :integer, default: 0
      add :uninterruptable, :integer, default: 0
      add :ResistDiff, :integer, default: -150
      add :dot_stacking_exempt, :integer, default: 0
      add :deleteable, :integer, default: 0
      add :RecourseLink, :integer, default: 0
      add :no_partial_resist, :integer, default: 0
      add :field152, :integer, default: 0
      add :field153, :integer, default: 0
      add :short_buff_box, :integer, default: -1
      add :descnum, :integer, default: 0
      add :typedescnum, :integer, default: 0
      add :effectdescnum, :integer, default: 0
      add :effectdescnum2, :integer, default: 0
      add :npc_no_los, :integer, default: 0
      add :field160, :integer, default: 0
      add :reflectable, :integer, default: 0
      add :bonushate, :integer, default: 0
      add :field163, :integer, default: 100
      add :field164, :integer, default: -150
      add :ldon_trap, :integer, default: 0
      add :EndurCost, :integer, default: 0
      add :EndurTimerIndex, :integer, default: 0
      add :IsDiscipline, :integer, default: 0
      add :field169, :integer, default: 0
      add :field170, :integer, default: 0
      add :field171, :integer, default: 0
      add :field172, :integer, default: 0
      add :HateAdded, :integer, default: 0
      add :EndurUpkeep, :integer, default: 0
      add :numhitstype, :integer, default: 0
      add :numhits, :integer, default: 0
      add :pvpresistbase, :integer, default: -150
      add :pvpresistcalc, :integer, default: 100
      add :pvpresistcap, :integer, default: -150
      add :spell_category, :integer, default: -99
      add :pvp_duration, :integer, default: 0
      add :pvp_duration_cap, :integer, default: 0
      add :pcnpc_only_flag, :integer, default: 0
      add :cast_not_standing, :integer, default: 0
      add :can_mgb, :integer, default: 0
      add :nodispell, :integer, default: -1
      add :npc_category, :integer, default: 0
      add :npc_usefulness, :integer, default: 0
      add :MinResist, :integer, default: 0
      add :MaxResist, :integer, default: 0
      add :viral_targets, :integer, default: 0
      add :viral_timer, :integer, default: 0
      add :nimbuseffect, :integer, default: 0
      add :ConeStartAngle, :integer, default: 0
      add :ConeStopAngle, :integer, default: 0
      add :sneaking, :integer, default: 0
      add :not_extendable, :integer, default: 0
      add :field198, :integer, default: 0
      add :field199, :integer, default: 1
      add :suspendable, :integer, default: 0
      add :viral_range, :integer, default: 0
      add :songcap, :integer, default: 0
      add :field203, :integer, default: 0
      add :field204, :integer, default: 0
      add :no_block, :integer, default: 0
      add :field206, :integer, default: -1
      add :spellgroup, :integer, default: 0
      add :rank_, :integer, default: 0
      add :field209, :integer, default: -1
      add :field210, :integer, default: 1
      add :CastRestriction, :integer, default: 0
      add :allowrest, :integer, default: 0
      add :InCombat, :integer, default: 0
      add :OutofCombat, :integer, default: 0
      add :field215, :integer, default: 0
      add :field216, :integer, default: 0
      add :field217, :integer, default: 0
      add :aemaxtargets, :integer, default: 0
      add :maxtargets, :integer, default: 0
      add :field220, :integer, default: 0
      add :field221, :integer, default: 0
      add :field222, :integer, default: 0
      add :field223, :integer, default: 0
      add :persistdeath, :integer, default: 0
      add :field225, :integer, default: 0
      add :field226, :integer, default: 0
      add :min_dist, :float, default: 0.0
      add :min_dist_mod, :float, default: 0.0
      add :max_dist, :float, default: 0.0
      add :max_dist_mod, :float, default: 0.0
      add :min_range, :integer, default: 0
      add :field232, :integer, default: 0
      add :field233, :integer, default: 0
      add :field234, :integer, default: 0
      add :field235, :integer, default: 0
      add :field236, :integer, default: 0

      timestamps()
    end

    create unique_index(:eqemu_spells, [:spell_id])
    create index(:eqemu_spells, [:name])
    create index(:eqemu_spells, [:skill])

    # Tasks (Quests)
    create table(:eqemu_tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :task_id, :integer, null: false  # Original EQEmu task ID
      add :type, :integer, default: 0
      add :duration, :integer, default: 0
      add :duration_code, :integer, default: 0
      add :title, :string, null: false
      add :description, :text
      add :reward, :text
      add :rewardid, :integer, default: 0
      add :cashreward, :integer, default: 0
      add :xpreward, :integer, default: 0
      add :rewardmethod, :integer, default: 2
      add :reward_radiant_crystals, :integer, default: 0
      add :reward_ebon_crystals, :integer, default: 0
      add :minlevel, :integer, default: 1
      add :maxlevel, :integer, default: 65
      add :level_spread, :integer, default: 0
      add :min_players, :integer, default: 0
      add :max_players, :integer, default: 0
      add :repeatable, :integer, default: 1
      add :faction_reward, :integer, default: 0
      add :completion_emote, :string
      add :replay_timer_seconds, :integer, default: 0
      add :request_timer_seconds, :integer, default: 0

      timestamps()
    end

    create unique_index(:eqemu_tasks, [:task_id])
    create index(:eqemu_tasks, [:title])
    create index(:eqemu_tasks, [:type])
    create index(:eqemu_tasks, [:minlevel])
    create index(:eqemu_tasks, [:maxlevel])

    # Character Tasks (Quest Progress)
    create table(:eqemu_character_tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :character_id, references(:eqemu_characters, type: :binary_id), null: false
      add :task_id, references(:eqemu_tasks, type: :binary_id), null: false
      add :slot, :integer, default: 0
      add :type, :integer, default: 0
      add :acceptedtime, :utc_datetime
      add :completedtime, :utc_datetime

      timestamps()
    end

    create unique_index(:eqemu_character_tasks, [:character_id, :task_id])
    create index(:eqemu_character_tasks, [:completedtime])

    # Factions
    create table(:eqemu_factions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :faction_id, :integer, null: false
      add :name, :string, null: false
      add :base, :integer, default: 0
      add :see_illusion, :integer, default: 0
      add :min_cap, :integer, default: -2000
      add :max_cap, :integer, default: 2000

      timestamps()
    end

    create unique_index(:eqemu_factions, [:faction_id])
    create index(:eqemu_factions, [:name])

    # Character Faction Values
    create table(:eqemu_character_faction_values, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :character_id, references(:eqemu_characters, type: :binary_id), null: false
      add :faction_id, references(:eqemu_factions, type: :binary_id), null: false
      add :current_value, :integer, default: 0

      timestamps()
    end

    create unique_index(:eqemu_character_faction_values, [:character_id, :faction_id])

    # Loot Tables
    create table(:eqemu_loot_tables, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :loottable_id, :integer, null: false
      add :name, :string
      add :mincash, :integer, default: 0
      add :maxcash, :integer, default: 0
      add :avgcoin, :integer, default: 0
      add :done, :integer, default: 0

      timestamps()
    end

    create unique_index(:eqemu_loot_tables, [:loottable_id])

    # Loot Table Entries
    create table(:eqemu_loot_table_entries, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :loot_table_id, references(:eqemu_loot_tables, type: :binary_id), null: false
      add :lootdrop_id, :integer, null: false
      add :multiplier, :integer, default: 1
      add :droplimit, :integer, default: 0
      add :mindrop, :integer, default: 0
      add :probability, :float, default: 100.0

      timestamps()
    end

    create index(:eqemu_loot_table_entries, [:loot_table_id])
    create index(:eqemu_loot_table_entries, [:lootdrop_id])

    # Merchants
    create table(:eqemu_merchants, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :merchant_id, :integer, null: false
      add :slot, :integer, null: false
      add :item_id, references(:eqemu_items, type: :binary_id), null: false
      add :faction_required, :integer, default: -100
      add :level_required, :integer, default: 0
      add :alt_currency_cost, :integer, default: 0
      add :classes_required, :integer, default: 65535
      add :probability, :integer, default: 100
      add :bucket_name, :string
      add :bucket_value, :string
      add :bucket_comparison, :integer, default: 0
      add :min_expansion, :integer, default: 0
      add :max_expansion, :integer, default: 0
      add :content_flags, :string
      add :content_flags_disabled, :string

      timestamps()
    end

    create unique_index(:eqemu_merchants, [:merchant_id, :slot])
    create index(:eqemu_merchants, [:item_id])

    # Doors
    create table(:eqemu_doors, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :door_id, :integer, null: false
      add :zone_id, references(:eqemu_zones, type: :binary_id), null: false
      add :name, :string, null: false
      add :pos_y, :float, default: 0.0
      add :pos_x, :float, default: 0.0
      add :pos_z, :float, default: 0.0
      add :heading, :float, default: 0.0
      add :opentype, :integer, default: 31
      add :guild, :integer, default: 0
      add :lockpick, :integer, default: 0
      add :keyitem, :integer, default: 0
      add :nokeyring, :integer, default: 0
      add :triggerdoor, :integer, default: 0
      add :triggertype, :integer, default: 0
      add :doorisopen, :integer, default: 0
      add :door_param, :integer, default: 0
      add :dest_zone, :string, default: "NONE"
      add :dest_instance, :integer, default: 0
      add :dest_x, :float, default: 0.0
      add :dest_y, :float, default: 0.0
      add :dest_z, :float, default: 0.0
      add :dest_heading, :float, default: 0.0
      add :invert_state, :integer, default: 0
      add :incline, :integer, default: 0
      add :size, :integer, default: 100
      add :buffer, :float, default: 0.0
      add :client_version_mask, :integer, default: 4294967295
      add :is_ldon_door, :integer, default: 0
      add :dz_switch_id, :integer, default: 0
      add :min_expansion, :integer, default: 0
      add :max_expansion, :integer, default: 0
      add :content_flags, :string
      add :content_flags_disabled, :string

      timestamps()
    end

    create unique_index(:eqemu_doors, [:door_id])
    create index(:eqemu_doors, [:zone_id])
    create index(:eqemu_doors, [:name])
  end
end