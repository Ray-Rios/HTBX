defmodule PhoenixApp.Repo.Migrations.CreateEqemuSchema do
  use Ecto.Migration

  def change do
    # ============================================================================
    # CORE CHARACTER SYSTEM
    # ============================================================================
    
    # Main character data table (based on PEQ character_data)
    create table(:eqemu_characters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id), null: false
      
      # Original EQEmu fields
      add :eqemu_id, :integer, null: false  # Original character ID from PEQ
      add :account_id, :integer, null: false
      add :name, :string, size: 64, null: false
      add :last_name, :string, size: 64
      add :title, :string, size: 32
      add :suffix, :string, size: 32
      add :zone_id, :integer, default: 1
      add :zone_instance, :integer, default: 0
      add :y, :float, default: 0.0
      add :x, :float, default: 0.0
      add :z, :float, default: 0.0
      add :heading, :float, default: 0.0
      add :gender, :integer, default: 0
      add :race, :integer, default: 1
      add :class, :integer, default: 1
      add :level, :integer, default: 1
      add :deity, :integer, default: 396
      add :birthday, :integer, default: 0
      add :last_login, :integer, default: 0
      add :time_played, :integer, default: 0
      add :level2, :integer, default: 0
      add :anon, :integer, default: 0
      add :gm, :integer, default: 0
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
      
      # Stats
      add :hp, :integer, default: 100
      add :mana, :integer, default: 0
      add :endurance, :integer, default: 100
      add :intoxication, :integer, default: 0
      add :str, :integer, default: 75
      add :sta, :integer, default: 75
      add :cha, :integer, default: 75
      add :dex, :integer, default: 75
      add :int, :integer, default: 75
      add :agi, :integer, default: 75
      add :wis, :integer, default: 75
      
      # Currency
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
      add :radiant_crystals, :integer, default: 0
      add :career_radiant_crystals, :integer, default: 0
      add :ebon_crystals, :integer, default: 0
      add :career_ebon_crystals, :integer, default: 0
      
      # Experience
      add :exp, :integer, default: 0
      add :exp_enabled, :integer, default: 1
      add :aa_points_spent, :integer, default: 0
      add :aa_exp, :integer, default: 0
      add :aa_points, :integer, default: 0
      add :group_leadership_exp, :integer, default: 0
      add :raid_leadership_exp, :integer, default: 0
      add :group_leadership_points, :integer, default: 0
      add :raid_leadership_points, :integer, default: 0
      
      # PvP and Karma
      add :pvp_status, :integer, default: 0
      add :pvp_kills, :integer, default: 0
      add :pvp_deaths, :integer, default: 0
      add :pvp_current_points, :integer, default: 0
      add :pvp_career_points, :integer, default: 0
      add :pvp_best_kill_streak, :integer, default: 0
      add :pvp_worst_death_streak, :integer, default: 0
      add :pvp_current_kill_streak, :integer, default: 0
      add :pvp2, :integer, default: 0
      add :pvp_type, :integer, default: 0
      add :show_helm, :integer, default: 1
      add :fatigue, :integer, default: 0
      
      # Tribute and other systems
      add :tribute_time_remaining, :integer, default: 0
      add :tribute_career_points, :integer, default: 0
      add :tribute_points, :integer, default: 0
      add :tribute_active, :integer, default: 0
      add :endurance_percent, :integer, default: 100
      add :grouping_disabled, :integer, default: 0
      add :raid_grouped, :integer, default: 0
      add :mailkey, :string, size: 16
      add :xtargets, :integer, default: 5
      add :firstlogon, :integer, default: 0
      add :e_aa_effects, :integer, default: 0
      add :e_percent_to_aa, :integer, default: 0
      add :e_expended_aa_spent, :integer, default: 0
      add :boatname, :string, size: 16
      add :boatid, :integer, default: 0
      
      # Timestamps
      timestamps()
    end

    create unique_index(:eqemu_characters, [:eqemu_id])
    create unique_index(:eqemu_characters, [:name])
    create index(:eqemu_characters, [:user_id])
    create index(:eqemu_characters, [:account_id])
    create index(:eqemu_characters, [:level])
    create index(:eqemu_characters, [:zone_id])
    create index(:eqemu_characters, [:race])
    create index(:eqemu_characters, [:class])

    # ============================================================================
    # ITEMS SYSTEM
    # ============================================================================
    
    # Items table (based on PEQ items)
    create table(:eqemu_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :eqemu_id, :integer, null: false  # Original item ID from PEQ
      add :minstatus, :integer, default: 0
      add :name, :string, size: 64, null: false
      add :aagi, :integer, default: 0
      add :ac, :integer, default: 0
      add :accuracy, :integer, default: 0
      add :acha, :integer, default: 0
      add :adex, :integer, default: 0
      add :aint, :integer, default: 0
      add :artifactflag, :integer, default: 0
      add :asta, :integer, default: 0
      add :astr, :integer, default: 0
      add :attack, :integer, default: 0
      add :augrestrict, :integer, default: 0
      add :augslot1type, :integer, default: 0
      add :augslot1visible, :integer, default: 0
      add :augslot2type, :integer, default: 0
      add :augslot2visible, :integer, default: 0
      add :augslot3type, :integer, default: 0
      add :augslot3visible, :integer, default: 0
      add :augslot4type, :integer, default: 0
      add :augslot4visible, :integer, default: 0
      add :augslot5type, :integer, default: 0
      add :augslot5visible, :integer, default: 0
      add :augslot6type, :integer, default: 0
      add :augslot6visible, :integer, default: 0
      add :augtype, :integer, default: 0
      add :avoidance, :integer, default: 0
      add :awis, :integer, default: 0
      add :bagsize, :integer, default: 0
      add :bagslots, :integer, default: 0
      add :bagtype, :integer, default: 0
      add :bagwr, :integer, default: 0
      add :banedmgamt, :integer, default: 0
      add :banedmgraceamt, :integer, default: 0
      add :banedmgbody, :integer, default: 0
      add :banedmgrace, :integer, default: 0
      add :bardtype, :integer, default: 0
      add :bardvalue, :integer, default: 0
      add :book, :integer, default: 0
      add :casttime, :integer, default: 0
      add :casttime_, :integer, default: 0
      add :charmfile, :string, size: 32
      add :charmfileid, :string, size: 32
      add :classes, :integer, default: 0
      add :color, :integer, default: 0
      add :combateffects, :string, size: 10
      add :extradmgskill, :integer, default: 0
      add :extradmgamt, :integer, default: 0
      add :price, :integer, default: 0
      add :cr, :integer, default: 0
      add :damage, :integer, default: 0
      add :damageshield, :integer, default: 0
      add :deity, :integer, default: 0
      add :delay, :integer, default: 0
      add :augdistiller, :integer, default: 0
      add :dotshielding, :integer, default: 0
      add :dr, :integer, default: 0
      add :clicktype, :integer, default: 0
      add :clicklevel2, :integer, default: 0
      add :elemdmgtype, :integer, default: 0
      add :elemdmgamt, :integer, default: 0
      add :endur, :integer, default: 0
      add :factionamt1, :integer, default: 0
      add :factionamt2, :integer, default: 0
      add :factionamt3, :integer, default: 0
      add :factionamt4, :integer, default: 0
      add :factionmod1, :integer, default: 0
      add :factionmod2, :integer, default: 0
      add :factionmod3, :integer, default: 0
      add :factionmod4, :integer, default: 0
      add :filename, :string, size: 32
      add :focuseffect, :integer, default: 0
      add :fr, :integer, default: 0
      add :fvnodrop, :integer, default: 0
      add :haste, :integer, default: 0
      add :clicklevel, :integer, default: 0
      add :hp, :integer, default: 0
      add :regen, :integer, default: 0
      add :icon, :integer, default: 0
      add :idfile, :string, size: 30
      add :itemclass, :integer, default: 0
      add :itemtype, :integer, default: 0
      add :ldonprice, :integer, default: 0
      add :ldontheme, :integer, default: 0
      add :ldonsold, :integer, default: 0
      add :light, :integer, default: 0
      add :lore, :string, size: 80
      add :loregroup, :integer, default: 0
      add :magic, :integer, default: 0
      add :mana, :integer, default: 0
      add :manaregen, :integer, default: 0
      add :enduranceregen, :integer, default: 0
      add :material, :integer, default: 0
      add :herosforgemodel, :integer, default: 0
      add :maxcharges, :integer, default: 0
      add :mr, :integer, default: 0
      add :nodrop, :integer, default: 0
      add :norent, :integer, default: 0
      add :pendingloreflag, :integer, default: 0
      add :pr, :integer, default: 0
      add :procrate, :integer, default: 0
      add :races, :integer, default: 0
      add :range, :integer, default: 0
      add :reclevel, :integer, default: 0
      add :recskill, :integer, default: 0
      add :reqlevel, :integer, default: 0
      add :sellrate, :float, default: 1.0
      add :shielding, :integer, default: 0
      add :size, :integer, default: 0
      add :skillmodtype, :integer, default: 0
      add :skillmodvalue, :integer, default: 0
      add :slots, :integer, default: 0
      add :clickeffect, :integer, default: 0
      add :spellshield, :integer, default: 0
      add :strikethrough, :integer, default: 0
      add :stunresist, :integer, default: 0
      add :summonedflag, :integer, default: 0
      add :tradeskills, :integer, default: 0
      add :favor, :integer, default: 0
      add :weight, :integer, default: 0
      add :unk012, :integer, default: 0
      add :unk013, :integer, default: 0
      add :benefitflag, :integer, default: 0
      add :unk054, :integer, default: 0
      add :unk059, :integer, default: 0
      add :booktype, :integer, default: 0
      add :recastdelay, :integer, default: 0
      add :recasttype, :integer, default: 0
      add :guildfavor, :integer, default: 0
      add :unk123, :integer, default: 0
      add :unk124, :integer, default: 0
      add :attuneable, :integer, default: 0
      add :nopet, :integer, default: 0
      add :updated, :utc_datetime, default: fragment("NOW()")
      add :comment, :text
      add :unk127, :integer, default: 0
      add :pointtype, :integer, default: 0
      add :potionbelt, :integer, default: 0
      add :potionbeltslots, :integer, default: 0
      add :stacksize, :integer, default: 0
      add :notransfer, :integer, default: 0
      add :stackable, :integer, default: 0
      add :unk134, :string, size: 255
      add :unk137, :integer, default: 0
      add :proceffect, :integer, default: 0
      add :proctype, :integer, default: 0
      add :proclevel2, :integer, default: 0
      add :proclevel, :integer, default: 0
      add :unk142, :integer, default: 0
      add :worneffect, :integer, default: 0
      add :worntype, :integer, default: 0
      add :wornlevel2, :integer, default: 0
      add :wornlevel, :integer, default: 0
      add :unk147, :integer, default: 0
      add :focustype, :integer, default: 0
      add :focuslevel2, :integer, default: 0
      add :focuslevel, :integer, default: 0
      add :unk152, :integer, default: 0
      add :scrolleffect, :integer, default: 0
      add :scrolltype, :integer, default: 0
      add :scrolllevel2, :integer, default: 0
      add :scrolllevel, :integer, default: 0
      add :unk157, :integer, default: 0
      add :serialized, :utc_datetime
      add :verified, :utc_datetime
      add :serialization, :text
      add :source, :string, size: 20, default: "Unknown"
      add :unk033, :integer, default: 0
      add :lorefile, :string, size: 32
      add :unk014, :integer, default: 0
      add :svcorruption, :integer, default: 0
      add :skillmodmax, :integer, default: 0
      add :unk060, :integer, default: 0
      add :augslot1unk2, :integer, default: 0
      add :augslot2unk2, :integer, default: 0
      add :augslot3unk2, :integer, default: 0
      add :augslot4unk2, :integer, default: 0
      add :augslot5unk2, :integer, default: 0
      add :augslot6unk2, :integer, default: 0
      add :unk120, :integer, default: 0
      add :unk121, :integer, default: 0
      add :questitemflag, :integer, default: 0
      add :unk132, :text
      add :clickunk5, :integer, default: 0
      add :clickunk6, :string, size: 32
      add :clickunk7, :integer, default: 0
      add :procunk1, :integer, default: 0
      add :procunk2, :integer, default: 0
      add :procunk3, :integer, default: 0
      add :procunk4, :integer, default: 0
      add :procunk6, :string, size: 32
      add :procunk7, :integer, default: 0
      add :wornunk1, :integer, default: 0
      add :wornunk2, :integer, default: 0
      add :wornunk3, :integer, default: 0
      add :wornunk4, :integer, default: 0
      add :wornunk5, :integer, default: 0
      add :wornunk6, :string, size: 32
      add :wornunk7, :integer, default: 0
      add :focusunk1, :integer, default: 0
      add :focusunk2, :integer, default: 0
      add :focusunk3, :integer, default: 0
      add :focusunk4, :integer, default: 0
      add :focusunk5, :integer, default: 0
      add :focusunk6, :string, size: 32
      add :focusunk7, :integer, default: 0
      add :scrollunk1, :integer, default: 0
      add :scrollunk2, :integer, default: 0
      add :scrollunk3, :integer, default: 0
      add :scrollunk4, :integer, default: 0
      add :scrollunk5, :integer, default: 0
      add :scrollunk6, :string, size: 32
      add :scrollunk7, :integer, default: 0
      add :unk193, :integer, default: 0
      add :purity, :integer, default: 0
      add :evoitem, :integer, default: 0
      add :evoid, :integer, default: 0
      add :evolvinglevel, :integer, default: 0
      add :evomax, :integer, default: 0
      add :clickname, :string, size: 64
      add :procname, :string, size: 64
      add :wornname, :string, size: 64
      add :focusname, :string, size: 64
      add :scrollname, :string, size: 64
      add :dsmitigation, :integer, default: 0
      add :heroic_str, :integer, default: 0
      add :heroic_int, :integer, default: 0
      add :heroic_wis, :integer, default: 0
      add :heroic_agi, :integer, default: 0
      add :heroic_dex, :integer, default: 0
      add :heroic_sta, :integer, default: 0
      add :heroic_cha, :integer, default: 0
      add :heroic_pr, :integer, default: 0
      add :heroic_dr, :integer, default: 0
      add :heroic_fr, :integer, default: 0
      add :heroic_cr, :integer, default: 0
      add :heroic_mr, :integer, default: 0
      add :heroic_svcorrup, :integer, default: 0
      add :healamt, :integer, default: 0
      add :spelldmg, :integer, default: 0
      add :clairvoyance, :integer, default: 0
      add :backstabdmg, :integer, default: 0
      add :created, :string, size: 64
      add :elitematerial, :integer, default: 0
      add :ldonsellbackrate, :integer, default: 70
      add :scriptfileid, :integer, default: 0
      add :expendablearrow, :integer, default: 0
      add :powersourcecapacity, :integer, default: 0
      add :bardeffect, :integer, default: 0
      add :bardeffecttype, :integer, default: 0
      add :bardlevel2, :integer, default: 0
      add :bardlevel, :integer, default: 0
      add :bardunk1, :integer, default: 0
      add :bardunk2, :integer, default: 0
      add :bardunk3, :integer, default: 0
      add :bardunk4, :integer, default: 0
      add :bardunk5, :integer, default: 0
      add :bardname, :string, size: 64
      add :bardunk7, :integer, default: 0
      add :unk214, :integer, default: 0
      add :subtype, :integer, default: 0
      add :unk220, :integer, default: 0
      add :unk221, :integer, default: 0
      add :heirloom, :integer, default: 0
      add :unk223, :integer, default: 0
      add :unk224, :integer, default: 0
      add :unk225, :integer, default: 0
      add :unk226, :integer, default: 0
      add :unk227, :integer, default: 0
      add :unk228, :integer, default: 0
      add :unk229, :integer, default: 0
      add :unk230, :integer, default: 0
      add :unk231, :integer, default: 0
      add :unk232, :integer, default: 0
      add :unk233, :integer, default: 0
      add :unk234, :integer, default: 0
      add :placeable, :integer, default: 0
      add :unk236, :integer, default: 0
      add :unk237, :integer, default: 0
      add :unk238, :integer, default: 0
      add :unk239, :integer, default: 0
      add :unk240, :integer, default: 0
      add :unk241, :integer, default: 0
      add :epicitem, :integer, default: 0

      timestamps()
    end

    create unique_index(:eqemu_items, [:eqemu_id])
    create index(:eqemu_items, [:name])
    create index(:eqemu_items, [:itemtype])
    create index(:eqemu_items, [:classes])
    create index(:eqemu_items, [:races])
    create index(:eqemu_items, [:reqlevel])

    # ============================================================================
    # CHARACTER INVENTORY
    # ============================================================================
    
    # Character inventory (simplified from PEQ character_inventory)
    create table(:eqemu_character_inventory, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :character_id, references(:eqemu_characters, type: :binary_id), null: false
      add :item_id, references(:eqemu_items, type: :binary_id), null: false
      add :slot_id, :integer, null: false
      add :charges, :integer, default: 1
      add :color, :integer, default: 0
      add :augment_1, references(:eqemu_items, type: :binary_id)
      add :augment_2, references(:eqemu_items, type: :binary_id)
      add :augment_3, references(:eqemu_items, type: :binary_id)
      add :augment_4, references(:eqemu_items, type: :binary_id)
      add :augment_5, references(:eqemu_items, type: :binary_id)
      add :augment_6, references(:eqemu_items, type: :binary_id)
      add :instnodrop, :integer, default: 0
      add :custom_data, :text
      add :ornamenticon, :integer, default: 0
      add :ornamentidfile, :string, size: 32
      add :ornament_hero_model, :integer, default: 0

      timestamps()
    end

    create unique_index(:eqemu_character_inventory, [:character_id, :slot_id])
    create index(:eqemu_character_inventory, [:item_id])

    # ============================================================================
    # GUILDS SYSTEM
    # ============================================================================
    
    # Guilds table (based on PEQ guilds)
    create table(:eqemu_guilds, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :eqemu_id, :integer, null: false  # Original guild ID from PEQ
      add :name, :string, size: 32, null: false
      add :leader, :integer, default: 0
      add :moto_of_the_day, :text
      add :channel, :string, size: 128
      add :url, :text
      add :favor, :integer, default: 0
      add :tribute, :integer, default: 0

      timestamps()
    end

    create unique_index(:eqemu_guilds, [:eqemu_id])
    create unique_index(:eqemu_guilds, [:name])

    # Guild members (based on PEQ guild_members)
    create table(:eqemu_guild_members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :guild_id, references(:eqemu_guilds, type: :binary_id), null: false
      add :character_id, references(:eqemu_characters, type: :binary_id), null: false
      add :rank, :integer, default: 0
      add :tribute, :integer, default: 0
      add :last_tribute, :integer, default: 0
      add :banker, :integer, default: 0
      add :public_note, :text
      add :officer_note, :text
      add :total_tribute, :integer, default: 0
      add :last_tribute_time, :integer, default: 0

      timestamps()
    end

    create unique_index(:eqemu_guild_members, [:guild_id, :character_id])
    create index(:eqemu_guild_members, [:character_id])

    # ============================================================================
    # ZONES SYSTEM
    # ============================================================================
    
    # Zones table (based on PEQ zone)
    create table(:eqemu_zones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :eqemu_id, :integer, null: false  # Original zone ID from PEQ
      add :short_name, :string, size: 32, null: false
      add :long_name, :text, null: false
      add :map_file_name, :string, size: 100
      add :safe_x, :float, default: 0.0
      add :safe_y, :float, default: 0.0
      add :safe_z, :float, default: 0.0
      add :safe_heading, :float, default: 0.0
      add :graveyard_id, :float, default: 0.0
      add :min_level, :integer, default: 1
      add :max_level, :integer, default: 255
      add :min_status, :integer, default: 0
      add :zoneidnumber, :integer, default: 0
      add :version, :integer, default: 0
      add :timezone, :integer, default: 0
      add :maxclients, :integer, default: 0
      add :ruleset, :integer, default: 0
      add :note, :string, size: 80
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
      add :flag_needed, :string, size: 128
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

    create unique_index(:eqemu_zones, [:eqemu_id])
    create unique_index(:eqemu_zones, [:short_name])
    create index(:eqemu_zones, [:long_name])
    create index(:eqemu_zones, [:expansion])

    # ============================================================================
    # ACCOUNTS SYSTEM (for EQEmu integration)
    # ============================================================================
    
    # EQEmu accounts (maps to Phoenix users)
    create table(:eqemu_accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id), null: false
      add :eqemu_id, :integer, null: false  # Original account ID from PEQ
      add :name, :string, size: 30, null: false
      add :charname, :string, size: 64
      add :sharedplat, :integer, default: 0
      add :password, :string, size: 50
      add :status, :integer, default: 0
      add :ls_id, :string, size: 31
      add :lsaccount_id, :integer, default: 0
      add :gmspeed, :integer, default: 0
      add :revoked, :integer, default: 0
      add :karma, :integer, default: 0
      add :minilogin_ip, :string, size: 32
      add :hideme, :integer, default: 0
      add :rulesflag, :integer, default: 0
      add :suspendeduntil, :utc_datetime, default: fragment("NOW()")
      add :time_creation, :integer, default: 0
      add :expansion, :integer, default: 8

      timestamps()
    end

    create unique_index(:eqemu_accounts, [:eqemu_id])
    create unique_index(:eqemu_accounts, [:name])
    create unique_index(:eqemu_accounts, [:user_id])

    # ============================================================================
    # ADDITIONAL INDEXES FOR PERFORMANCE
    # ============================================================================
    
    # Performance indexes for common queries
    create index(:eqemu_characters, [:zone_id, :level])
    create index(:eqemu_characters, [:race, :class])
    create index(:eqemu_characters, [:last_login])
    create index(:eqemu_items, [:itemtype, :reqlevel])
    create index(:eqemu_items, [:classes, :races])
    create index(:eqemu_character_inventory, [:character_id, :item_id])
    create index(:eqemu_zones, [:min_level, :max_level])
  end
end