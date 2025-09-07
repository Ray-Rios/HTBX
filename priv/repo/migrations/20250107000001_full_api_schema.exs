defmodule PhoenixApp.Repo.Migrations.ConsolidatedEqemuSchema do
  use Ecto.Migration
  @disable_ddl_transaction true

  def up do
    # ============================================================================
    # USERS SYSTEM (API) - Keep existing users system
    # ============================================================================
    
    # Create users table (if not exists)
    create_if_not_exists table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :name, :string
      add :password_hash, :string, null: false
      add :confirmed_at, :utc_datetime
      add :is_online, :boolean, default: false
      add :is_admin, :boolean, default: false
      add :last_activity, :utc_datetime
      add :avatar_shape, :string
      add :avatar_color, :string
      add :avatar_file, :string
      add :two_factor_secret, :string
      add :two_factor_enabled, :boolean, default: false
      add :two_factor_backup_codes, {:array, :string}, default: []
      add :position_x, :float, default: 400.0
      add :position_y, :float, default: 300.0
      add :status, :string, default: "active"
      add :avatar_url, :string
      add :role, :string, default: "subscriber"
      timestamps(type: :utc_datetime)
    end

    create_if_not_exists unique_index(:users, [:email])
    create_if_not_exists index(:users, [:is_admin])
    create_if_not_exists index(:users, [:two_factor_enabled])

    # Create users tokens table (if not exists)
    create_if_not_exists table(:users_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false, type: :utc_datetime)
    end

    create_if_not_exists index(:users_tokens, [:user_id])
    create_if_not_exists unique_index(:users_tokens, [:context, :token])

    # ============================================================================
    #            GAME TABLES
    # ============================================================================
    
    # Accounts table (maps to Phoenix users with CASCADE DELETE)
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
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

    create unique_index(:accounts, [:eqemu_id])
    create unique_index(:accounts, [:name])
    create unique_index(:accounts, [:user_id])

    # Main Characters table (with CASCADE DELETE)
    create table(:characters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      
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
      add :anon, :integer, default: 0
      add :gm, :integer, default: 0
      add :face, :integer, default: 1
      add :hair_color, :integer, default: 1
      add :hair_style, :integer, default: 1
      add :beard, :integer, default: 0
      add :beard_color, :integer, default: 1
      add :eye_color_1, :integer, default: 1
      add :eye_color_2, :integer, default: 1
      add :show_helm, :integer, default: 1
      add :fatigue, :integer, default: 0      

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
      add :ebon_crystals, :integer, default: 0
      
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
      
      # PvP and other systems
      add :pvp_status, :integer, default: 0
      add :mailkey, :string, size: 16
      add :xtargets, :integer, default: 5
      add :firstlogon, :integer, default: 0
      add :e_aa_effects, :integer, default: 0
      add :e_percent_to_aa, :integer, default: 0
      add :e_expended_aa_spent, :integer, default: 0
      
      timestamps()
    end

    create unique_index(:characters, [:eqemu_id])
    create unique_index(:characters, [:name])
    create index(:characters, [:user_id])
    create index(:characters, [:account_id])
    create index(:characters, [:level])
    create index(:characters, [:zone_id])
    create index(:characters, [:race])
    create index(:characters, [:class])

    # Add cascade constraint for characters -> accounts
    execute """
    ALTER TABLE characters 
    ADD CONSTRAINT characters_account_cascade 
    FOREIGN KEY (account_id) 
    REFERENCES accounts(eqemu_id) 
    ON DELETE CASCADE
    """

    # Character stats table (separate from main character data)
    create table(:character_stats, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :character_id, references(:characters, type: :binary_id, on_delete: :delete_all), null: false
      add :eqemu_id, :integer, null: false
      
      # All the detailed stats
      add :str, :integer, default: 75
      add :sta, :integer, default: 75
      add :cha, :integer, default: 75
      add :dex, :integer, default: 75
      add :int, :integer, default: 75
      add :agi, :integer, default: 75
      add :wis, :integer, default: 75
      add :magic, :integer, default: 0
      add :cold, :integer, default: 0
      add :fire, :integer, default: 0
      add :poison, :integer, default: 0
      add :disease, :integer, default: 0
      add :corruption, :integer, default: 0
      
      timestamps()
    end

    create unique_index(:character_stats, [:character_id])
    create unique_index(:character_stats, [:eqemu_id])

    # Items table (based on PEQ items) - CLEAN VERSION
    create table(:items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :eqemu_id, :integer, null: false  # Original item ID from PEQ
      add :minstatus, :integer, default: 0
      add :name, :string, size: 64, null: false
      add :weight, :integer, default: 0  # Added from missing fields
      add :reqlevel, :integer, default: 0  # Added from missing fields
      
      # Core item stats
      add :agi, :integer, default: 0
      add :ac, :integer, default: 0
      add :accuracy, :integer, default: 0
      add :cha, :integer, default: 0
      add :dex, :integer, default: 0
      add :int, :integer, default: 0
      add :sta, :integer, default: 0
      add :str, :integer, default: 0
      add :wis, :integer, default: 0
      add :attack, :integer, default: 0
      add :hp, :integer, default: 0
      add :mana, :integer, default: 0
      add :endur, :integer, default: 0
      add :regen, :integer, default: 0
      add :manaregen, :integer, default: 0
      add :enduranceregen, :integer, default: 0
      
      # Item properties
      add :itemtype, :integer, default: 0
      add :itemclass, :integer, default: 0
      add :classes, :integer, default: 0
      add :races, :integer, default: 0
      add :slots, :integer, default: 0
      add :price, :integer, default: 0
      add :sellrate, :float, default: 1.0
      add :size, :integer, default: 0
      add :color, :integer, default: 0
      add :icon, :integer, default: 0
      add :material, :integer, default: 0
      add :delay, :integer, default: 0
      add :damage, :integer, default: 0
      add :range, :integer, default: 0
      
      # Flags and restrictions
      add :nodrop, :integer, default: 0
      add :norent, :integer, default: 0
      add :magic, :integer, default: 0
      add :lore, :string, size: 80
      add :loregroup, :integer, default: 0
      add :artifactflag, :integer, default: 0
      add :summonedflag, :integer, default: 0
      add :questitemflag, :integer, default: 0
      add :tradeskills, :integer, default: 0
      add :stackable, :integer, default: 0
      add :stacksize, :integer, default: 0
      
      # Effects and spells
      add :clickeffect, :integer, default: 0
      add :clicktype, :integer, default: 0
      add :clicklevel, :integer, default: 0
      add :proceffect, :integer, default: 0
      add :proctype, :integer, default: 0
      add :proclevel, :integer, default: 0
      add :worneffect, :integer, default: 0
      add :worntype, :integer, default: 0
      add :wornlevel, :integer, default: 0
      add :focuseffect, :integer, default: 0
      add :focustype, :integer, default: 0
      add :focuslevel, :integer, default: 0
      
      # Resistances
      add :cr, :integer, default: 0
      add :dr, :integer, default: 0
      add :fr, :integer, default: 0
      add :mr, :integer, default: 0
      add :pr, :integer, default: 0
      add :svcorruption, :integer, default: 0
      
      # Metadata
      add :updated, :utc_datetime, default: fragment("NOW()")
      add :comment, :text
      add :source, :string, size: 20, default: "Unknown"
      
      timestamps()
    end

    create unique_index(:items, [:eqemu_id])
    create index(:items, [:name])
    create index(:items, [:itemtype])
    create index(:items, [:classes])
    create index(:items, [:races])
    create index(:items, [:reqlevel])

    # Character inventory table
    create table(:character_inventory, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :character_id, references(:characters, type: :binary_id, on_delete: :delete_all), null: false
      add :item_id, references(:items, type: :binary_id), null: false
      add :slot_id, :integer, null: false
      add :charges, :integer, default: 1
      add :color, :integer, default: 0
      add :instnodrop, :integer, default: 0
      add :custom_data, :text

      timestamps()
    end

    create unique_index(:character_inventory, [:character_id, :slot_id])
    create index(:character_inventory, [:item_id])

    # Guilds table
    create table(:guilds, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :eqemu_id, :integer, null: false  # Original guild ID from PEQ
      add :name, :string, size: 32, null: false
      add :leader, :integer, default: 0
      add :moto_of_the_day, :text
      add :channel, :string, size: 128
      add :url, :text

      timestamps()
    end

    create unique_index(:guilds, [:eqemu_id])
    create unique_index(:guilds, [:name])

    # Guild members table
    create table(:guild_members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :guild_id, references(:guilds, type: :binary_id, on_delete: :delete_all), null: false
      add :character_id, references(:characters, type: :binary_id, on_delete: :delete_all), null: false
      add :rank, :integer, default: 0
      add :public_note, :text
      add :officer_note, :text

      timestamps()
    end

    create unique_index(:guild_members, [:guild_id, :character_id])
    create index(:guild_members, [:character_id])

    # Zones table
    create table(:zones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :eqemu_id, :integer, null: false  # Original zone ID from PEQ
      add :short_name, :string, size: 32, null: false
      add :long_name, :text, null: false
      add :safe_x, :float, default: 0.0
      add :safe_y, :float, default: 0.0
      add :safe_z, :float, default: 0.0
      add :safe_heading, :float, default: 0.0
      add :min_level, :integer, default: 1
      add :max_level, :integer, default: 255
      add :min_status, :integer, default: 0
      add :zoneidnumber, :integer, default: 0
      add :expansion, :integer, default: 0

      timestamps()
    end

    create unique_index(:zones, [:eqemu_id])
    create unique_index(:zones, [:short_name])
    create index(:zones, [:expansion])

    # ============================================================================
    # KEEP EXISTING CMS TABLES (if they exist)
    # ============================================================================
    
    # Posts, pages, comments, etc. - these should remain unchanged
    # They will be created by the existing migration if not present
  end

    # ============================================================================
    # API CONTENT MANAGEMENT SYSTEM
    # ============================================================================

    # Create posts table
    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :slug, :string, null: false
      add :content, :text, null: false
      add :excerpt, :text
      add :is_published, :boolean, default: false
      add :published_at, :utc_datetime
      add :featured_image, :string
      add :meta_description, :string
      add :tags, {:array, :string}, default: []
      add :status, :string, default: "draft"
      add :post_type, :string, default: "post"
      add :comment_status, :string, default: "open"
      add :menu_order, :integer, default: 0
      add :comment_count, :integer, default: 0
      add :parent_id, references(:posts, type: :binary_id, on_delete: :nilify_all)
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:posts, [:slug])
    create index(:posts, [:user_id])
    create index(:posts, [:is_published])
    create index(:posts, [:published_at])
    create index(:posts, [:tags])
    create index(:posts, [:parent_id])
    create index(:posts, [:status])
    create index(:posts, [:post_type])

    # Create pages table
    create table(:pages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :slug, :string, null: false
      add :content, :text, null: false
      add :is_published, :boolean, default: false
      add :meta_description, :string
      add :template, :string, default: "default"
      timestamps(type: :utc_datetime)
    end

    create unique_index(:pages, [:slug])
    create index(:pages, [:is_published])

    # Create comments table
    create table(:comments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text, null: false
      add :author_name, :string
      add :author_email, :string
      add :author_url, :string
      add :author_ip, :string
      add :status, :string, default: "pending"
      add :agent, :string
      add :type, :string, default: "comment"
      add :is_approved, :boolean, default: false
      add :post_id, references(:posts, type: :binary_id, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :parent_id, references(:comments, type: :binary_id, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:post_id])
    create index(:comments, [:user_id])
    create index(:comments, [:parent_id])
    create index(:comments, [:status])
    create index(:comments, [:is_approved])
    create index(:comments, [:inserted_at])

    # ============================================================================
    # API CMS SYSTEM
    # ============================================================================

    # Create options table
    create table(:options, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :value, :text, null: false
      add :autoload, :boolean, default: true
      timestamps(type: :utc_datetime)
    end

    create unique_index(:options, [:name])

    # Create CMS options table
    create table(:cms_options) do
      add :option_name, :string, null: false
      add :option_value, :text, null: false, default: ""
      add :autoload, :string, null: false, default: "yes"
      timestamps()
    end

    create unique_index(:cms_options, [:option_name])
    create index(:cms_options, [:autoload])

    # Create taxonomies table
    create table(:cms_taxonomies) do
      add :name, :string, null: false
      add :label, :string, null: false
      add :description, :text, null: false, default: ""
      add :hierarchical, :boolean, null: false, default: false
      add :public, :boolean, null: false, default: true
      add :object_type, {:array, :string}, null: false, default: []
      timestamps()
    end

    create unique_index(:cms_taxonomies, [:name])
    create index(:cms_taxonomies, [:hierarchical])
    create index(:cms_taxonomies, [:public])

    # Create terms table
    create table(:cms_terms) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text, null: false, default: ""
      add :count, :integer, null: false, default: 0
      add :parent_id, references(:cms_terms, on_delete: :nilify_all)
      add :taxonomy_id, references(:cms_taxonomies, on_delete: :delete_all), null: false
      timestamps()
    end

    create index(:cms_terms, [:taxonomy_id])
    create index(:cms_terms, [:parent_id])
    create index(:cms_terms, [:slug])
    create unique_index(:cms_terms, [:slug, :taxonomy_id])

    # Create term meta table
    create table(:cms_term_meta) do
      add :term_id, references(:cms_terms, on_delete: :delete_all), null: false
      add :meta_key, :string, null: false, default: ""
      add :meta_value, :text, null: false, default: ""
      timestamps()
    end

    create index(:cms_term_meta, [:term_id])
    create index(:cms_term_meta, [:meta_key])
    create index(:cms_term_meta, [:term_id, :meta_key])

    # Create CMS posts table
    create table(:cms_posts) do
      add :title, :text, null: false, default: ""
      add :content, :text, null: false, default: ""
      add :excerpt, :text, null: false, default: ""
      add :status, :string, null: false, default: "draft"
      add :post_type, :string, null: false, default: "post"
      add :slug, :string, null: false, default: ""
      add :password, :string, null: false, default: ""
      add :comment_status, :string, null: false, default: "open"
      add :ping_status, :string, null: false, default: "open"
      add :menu_order, :integer, null: false, default: 0
      add :post_parent_id, references(:cms_posts, on_delete: :nilify_all)
      add :author_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :guid, :string, null: false, default: ""
      add :comment_count, :integer, null: false, default: 0
      add :post_date, :naive_datetime
      add :post_date_gmt, :naive_datetime
      add :post_modified, :naive_datetime
      add :post_modified_gmt, :naive_datetime
      timestamps()
    end

    create index(:cms_posts, [:author_id])
    create index(:cms_posts, [:post_parent_id])
    create index(:cms_posts, [:status])
    create index(:cms_posts, [:post_type])
    create index(:cms_posts, [:slug])
    create index(:cms_posts, [:post_date])
    create unique_index(:cms_posts, [:slug, :post_type])

    # Create post meta table
    create table(:cms_post_meta) do
      add :post_id, references(:cms_posts, on_delete: :delete_all), null: false
      add :meta_key, :string, null: false, default: ""
      add :meta_value, :text, null: false, default: ""
      timestamps()
    end

    create index(:cms_post_meta, [:post_id])
    create index(:cms_post_meta, [:meta_key])
    create index(:cms_post_meta, [:post_id, :meta_key])

    # Create post term relationships table
    create table(:cms_post_term_relationships) do
      add :post_id, references(:cms_posts, on_delete: :delete_all), null: false
      add :term_id, references(:cms_terms, on_delete: :delete_all), null: false
      add :term_order, :integer, null: false, default: 0
      timestamps()
    end

    create index(:cms_post_term_relationships, [:post_id])
    create index(:cms_post_term_relationships, [:term_id])
    create unique_index(:cms_post_term_relationships, [:post_id, :term_id])

    # Create CMS comments table
    create table(:cms_comments) do
      add :post_id, references(:cms_posts, on_delete: :delete_all), null: false
      add :author_name, :string, null: false, default: ""
      add :author_email, :string, null: false, default: ""
      add :author_url, :string, null: false, default: ""
      add :author_ip, :string, null: false, default: ""
      add :content, :text, null: false, default: ""
      add :approved, :string, null: false, default: "1"
      add :agent, :string, null: false, default: ""
      add :type, :string, null: false, default: "comment"
      add :parent_id, references(:cms_comments, on_delete: :delete_all)
      add :user_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :comment_date, :naive_datetime
      add :comment_date_gmt, :naive_datetime
      timestamps()
    end

    create index(:cms_comments, [:post_id])
    create index(:cms_comments, [:parent_id])
    create index(:cms_comments, [:user_id])
    create index(:cms_comments, [:approved])
    create index(:cms_comments, [:comment_date])
    create index(:cms_comments, [:type])

    # Create comment meta table
    create table(:cms_comment_meta) do
      add :comment_id, references(:cms_comments, on_delete: :delete_all), null: false
      add :meta_key, :string, null: false, default: ""
      add :meta_value, :text, null: false, default: ""
      timestamps()
    end

    create index(:cms_comment_meta, [:comment_id])
    create index(:cms_comment_meta, [:meta_key])
    create index(:cms_comment_meta, [:comment_id, :meta_key])

    # ============================================================================
    # API ECOMMERCE SYSTEM
    # ============================================================================

    # Create categories table
    create table(:categories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :slug, :string, null: false
      add :is_active, :boolean, default: true
      timestamps(type: :utc_datetime)
    end

    create unique_index(:categories, [:slug])
    create index(:categories, [:is_active])

    # Create products table
    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :price, :decimal, precision: 10, scale: 2, null: false
      add :sku, :string
      add :stock_quantity, :integer, default: 0
      add :is_active, :boolean, default: true
      add :image_url, :string
      add :weight, :decimal, precision: 8, scale: 2
      add :dimensions, :string
      add :image, :string
      add :stripe_price_id, :string
      add :category_id, references(:categories, type: :binary_id, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create unique_index(:products, [:sku])
    create index(:products, [:category_id])
    create index(:products, [:is_active])
    create index(:products, [:stripe_price_id])

    # Create carts table
    create table(:carts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:carts, [:user_id])

    # Create cart items table
    create table(:cart_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :quantity, :integer, null: false, default: 1
      add :cart_id, references(:carts, type: :binary_id, on_delete: :delete_all), null: false
      add :product_id, references(:products, type: :binary_id, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:cart_items, [:cart_id, :product_id])
    create index(:cart_items, [:cart_id])
    create index(:cart_items, [:product_id])

    # Create orders table
    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string, null: false, default: "pending"
      add :total_amount, :decimal, precision: 10, scale: 2, null: false
      add :stripe_payment_intent_id, :string
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create index(:orders, [:user_id])
    create index(:orders, [:status])
    create index(:orders, [:stripe_payment_intent_id])

    # Create order items table
    create table(:order_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :quantity, :integer, null: false
      add :price, :decimal, precision: 10, scale: 2, null: false
      add :order_id, references(:orders, type: :binary_id, on_delete: :delete_all), null: false
      add :product_id, references(:products, type: :binary_id, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create index(:order_items, [:order_id])
    create index(:order_items, [:product_id])

    # ============================================================================
    # API FILE MANAGEMENT
    # ============================================================================

    # Create user files table
    create table(:user_files, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :filename, :string, null: false
      add :original_filename, :string, null: false
      add :content_type, :string, null: false
      add :file_size, :integer, null: false
      add :file_path, :string
      add :file, :string
      add :is_public, :boolean, default: false
      add :description, :text
      add :tags, {:array, :string}, default: []
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create index(:user_files, [:user_id])
    create index(:user_files, [:content_type])
    create index(:user_files, [:is_public])
    create index(:user_files, [:inserted_at])

    # ============================================================================
    # API CHAT SYSTEM
    # ============================================================================

    # Create chat channels table
    create table(:chat_channels, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :topic, :string
      add :channel_type, :string, default: "text"
      add :is_private, :boolean, default: false
      add :position, :integer, default: 0
      add :created_by_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create index(:chat_channels, [:channel_type])
    create index(:chat_channels, [:is_private])
    create index(:chat_channels, [:created_by_id])
    create index(:chat_channels, [:position])

    # Create chat threads table (must be before messages due to reference)
    create table(:chat_threads, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :is_archived, :boolean, default: false
      add :channel_id, references(:chat_channels, type: :binary_id, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create index(:chat_threads, [:channel_id])
    create index(:chat_threads, [:is_archived])

    # Create chat messages table
    create table(:chat_messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text, null: false
      add :message_type, :string, default: "text"
      add :is_pinned, :boolean, default: false
      add :edited_at, :utc_datetime
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :channel_id, references(:chat_channels, type: :binary_id, on_delete: :delete_all), null: false
      add :reply_to_id, references(:chat_messages, type: :binary_id, on_delete: :nilify_all)
      add :thread_id, references(:chat_threads, type: :binary_id, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create index(:chat_messages, [:channel_id])
    create index(:chat_messages, [:user_id])
    create index(:chat_messages, [:message_type])
    create index(:chat_messages, [:is_pinned])
    create index(:chat_messages, [:reply_to_id])
    create index(:chat_messages, [:thread_id])
    create index(:chat_messages, [:inserted_at])

    # Add parent_message_id to chat_threads after chat_messages exists
    alter table(:chat_threads) do
      add :parent_message_id, references(:chat_messages, type: :binary_id, on_delete: :delete_all), null: false
    end

    create index(:chat_threads, [:parent_message_id])

    # Create chat message attachments table
    create table(:chat_message_attachments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :filename, :string, null: false
      add :content_type, :string
      add :file_size, :integer
      add :file, :string, null: false
      add :message_id, references(:chat_messages, type: :binary_id, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create index(:chat_message_attachments, [:message_id])

    # Create chat reactions table
    create table(:chat_reactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :emoji, :string, null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :message_id, references(:chat_messages, type: :binary_id, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:chat_reactions, [:user_id, :message_id, :emoji])
    create index(:chat_reactions, [:message_id])

    # ============================================================================
    # PERFORMANCE INDEXES
    # ============================================================================
    
    # Performance indexes for common queries
    create index(:eqemu_characters, [:zone_id, :level])
    create index(:eqemu_characters, [:race, :class])
    create index(:eqemu_characters, [:last_login])
    create index(:eqemu_items, [:itemtype, :reqlevel])
    create index(:eqemu_items, [:classes, :races])
    create index(:eqemu_character_inventory, [:character_id, :item_id])
    create index(:eqemu_zones, [:min_level, :max_level])

    # Update existing users to be admins by default
    execute "UPDATE users SET is_admin = true WHERE is_admin = false"
  end

  def down do
    # Drop all tables in reverse order
    drop table(:chat_reactions)
    drop table(:chat_message_attachments)
    drop table(:chat_messages)
    drop table(:chat_threads)
    drop table(:chat_channels)
    drop table(:user_files)
    drop table(:order_items)
    drop table(:orders)
    drop table(:cart_items)
    drop table(:carts)
    drop table(:products)
    drop table(:categories)
    drop table(:cms_comment_meta)
    drop table(:cms_comments)
    drop table(:cms_post_term_relationships)
    drop table(:cms_post_meta)
    drop table(:cms_posts)
    drop table(:cms_term_meta)
    drop table(:cms_terms)
    drop table(:cms_taxonomies)
    drop table(:cms_options)
    drop table(:options)
    drop table(:comments)
    drop table(:pages)
    drop table(:posts)
    drop table(:guild_members)
    drop table(:guilds)
    drop table(:character_inventory)
    drop table(:character_stats)
    drop table(:zones)
    drop table(:items)
    drop table(:characters)
    drop table(:accounts)
    drop table(:users_tokens)
    drop table(:users)
  end
end