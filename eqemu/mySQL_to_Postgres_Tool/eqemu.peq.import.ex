defmodule Mix.Tasks.Eqemu.Peq.Import do
  @moduledoc """
  Mix task for importing PEQ database into Phoenix EQEmu schema.
  
  This task provides a comprehensive CLI interface for parsing, converting,
  and importing PEQ database content with progress tracking and validation.
  
  ## Usage
  
      # Parse PEQ SQL file and generate migrations
      mix eqemu.peq.import --parse-only --file eqemu/migrations/peq.sql
      
      # Full import with validation
      mix eqemu.peq.import --file eqemu/migrations/peq.sql --validate
      
      # Import specific tables only
      mix eqemu.peq.import --tables accounts,characters,items --batch-size 500
      
      # Validate existing import
      mix eqemu.peq.import --validate-only
  """
  
  use Mix.Task
  
  alias PhoenixApp.EQEmuGame.{PeqParser, MigrationGenerator, ChunkedImporter, ImportValidator}
  alias PhoenixApp.Repo
  
  require Logger
  
  @shortdoc "Import PEQ database into Phoenix EQEmu schema"
  
  @default_options [
    file: "eqemu/migrations/peq.sql",
    batch_size: 1000,
    timeout: 60_000,
    output_dir: "tmp/eqemu_migration",
    validate: true,
    parse_only: false,
    validate_only: false,
    tables: nil,
    force: false,
    verbose: false
  ]
  
  def run(args) do
    # Start the application to ensure Repo is available
    Mix.Task.run("app.start")
    
    {options, _remaining_args, _invalid} = 
      OptionParser.parse(args, 
        strict: [
          file: :string,
          batch_size: :integer,
          timeout: :integer,
          output_dir: :string,
          validate: :boolean,
          parse_only: :boolean,
          validate_only: :boolean,
          tables: :string,
          force: :boolean,
          verbose: :boolean,
          help: :boolean
        ],
        aliases: [
          f: :file,
          b: :batch_size,
          t: :timeout,
          o: :output_dir,
          v: :validate,
          h: :help
        ]
      )
    
    final_options = Keyword.merge(@default_options, options)
    
    if final_options[:help] do
      print_help()
    else
      execute_import(final_options)
    end
  end
  
  defp execute_import(options) do
    Logger.configure(level: if(options[:verbose], do: :debug, else: :info))
    
    print_banner()
    print_options(options)
    
    cond do
      options[:validate_only] ->
        run_validation_only(options)
      
      options[:parse_only] ->
        run_parse_only(options)
      
      true ->
        run_full_import(options)
    end
  end
  
  defp run_validation_only(_options) do
    Logger.info("🔍 Running validation-only mode...")
    
    case ImportValidator.validate_complete_import() do
      {:passed, validator} ->
        Logger.info("✅ Validation PASSED - Import is valid!")
        print_validation_summary(validator)
        
      {:failed, validator} ->
        Logger.error("❌ Validation FAILED - Issues found in import")
        print_validation_summary(validator)
        System.halt(1)
    end
  end
  
  defp run_parse_only(options) do
    Logger.info("📖 Running parse-only mode...")
    
    case PeqParser.parse_peq_file(options[:file]) do
      {:ok, parsed_state} ->
        Logger.info("✅ Parsing completed successfully!")
        
        # Generate migrations
        case MigrationGenerator.generate_from_parsed_data(parsed_state, 
               output_dir: "priv/repo/migrations") do
          :ok ->
            Logger.info("🏗️ Phoenix migrations generated successfully!")
            Logger.info("📋 Next steps:")
            Logger.info("   1. Review generated migrations in priv/repo/migrations/")
            Logger.info("   2. Run: mix ecto.migrate")
            Logger.info("   3. Run full import: mix eqemu.peq.import --file #{options[:file]}")
            
          {:error, reason} ->
            Logger.error("❌ Migration generation failed: #{inspect(reason)}")
            System.halt(1)
        end
        
      {:error, reason} ->
        Logger.error("❌ Parsing failed: #{inspect(reason)}")
        System.halt(1)
    end
  end
  
  defp run_full_import(options) do
    Logger.info("🚀 Running full import process...")
    
    # Step 1: Parse PEQ file
    Logger.info("📖 Step 1: Parsing PEQ SQL file...")
    
    case PeqParser.parse_peq_file(options[:file]) do
      {:ok, parsed_state} ->
        Logger.info("✅ Parsing completed")
        
        # Step 2: Generate and run migrations if needed
        Logger.info("🏗️ Step 2: Ensuring database schema is ready...")
        
        case ensure_schema_ready(parsed_state, options) do
          :ok ->
            Logger.info("✅ Schema ready")
            
            # Step 3: Import data
            Logger.info("📊 Step 3: Importing data...")
            
            case import_data(parsed_state, options) do
              :ok ->
                Logger.info("✅ Data import completed")
                
                # Step 4: Validate import if requested
                if options[:validate] do
                  Logger.info("🔍 Step 4: Validating import...")
                  
                  case ImportValidator.validate_complete_import() do
                    {:passed, validator} ->
                      Logger.info("✅ Import validation PASSED!")
                      print_validation_summary(validator)
                      print_success_message()
                      
                    {:failed, validator} ->
                      Logger.error("❌ Import validation FAILED!")
                      print_validation_summary(validator)
                      
                      unless options[:force] do
                        Logger.error("Use --force to ignore validation errors")
                        System.halt(1)
                      end
                  end
                else
                  print_success_message()
                end
                
              {:error, reason} ->
                Logger.error("❌ Data import failed: #{inspect(reason)}")
                System.halt(1)
            end
            
          {:error, reason} ->
            Logger.error("❌ Schema preparation failed: #{inspect(reason)}")
            System.halt(1)
        end
        
      {:error, reason} ->
        Logger.error("❌ Parsing failed: #{inspect(reason)}")
        System.halt(1)
    end
  end
  
  defp ensure_schema_ready(parsed_state, _options) do
    # Check if EQEmu tables exist
    existing_tables = get_existing_eqemu_tables()
    
    if length(existing_tables) == 0 do
      Logger.info("📝 No EQEmu tables found, generating migrations...")
      
      case MigrationGenerator.generate_from_parsed_data(parsed_state, 
             output_dir: "priv/repo/migrations") do
        :ok ->
          Logger.info("🔄 Running migrations...")
          
          case Mix.Task.run("ecto.migrate") do
            :ok -> :ok
            _ -> {:error, :migration_failed}
          end
          
        error ->
          error
      end
    else
      Logger.info("✅ EQEmu tables already exist (#{length(existing_tables)} tables)")
      :ok
    end
  end
  
  defp import_data(parsed_state, options) do
    # Determine which tables to import
    tables_to_import = 
      if options[:tables] do
        String.split(options[:tables], ",") |> Enum.map(&String.trim/1)
      else
        Map.keys(parsed_state.data_inserts)
      end
    
    Logger.info("📋 Importing #{length(tables_to_import)} tables: #{Enum.join(tables_to_import, ", ")}")
    
    # Import each table
    results = 
      tables_to_import
      |> Enum.map(fn table_name ->
        import_table_data(table_name, parsed_state, options)
      end)
    
    # Check if all imports succeeded
    failed_imports = Enum.filter(results, &match?({:error, _}, &1))
    
    if length(failed_imports) > 0 do
      Logger.error("❌ #{length(failed_imports)} table imports failed")
      {:error, :import_failures}
    else
      Logger.info("✅ All table imports completed successfully")
      :ok
    end
  end
  
  defp import_table_data(table_name, parsed_state, options) do
    Logger.info("📊 Importing table: #{table_name}")
    
    # Get INSERT statements for this table
    inserts = Map.get(parsed_state.data_inserts, table_name, [])
    
    if length(inserts) == 0 do
      Logger.warning("⚠️  No data found for table #{table_name}")
      {:ok, %{processed: 0, failed: 0}}
    else
      # Create importer with progress callback
      progress_callback = fn progress ->
        if rem(progress.processed, options[:batch_size]) == 0 do
          Logger.info("   📈 #{table_name}: #{progress.percentage}% (#{progress.processed}/#{progress.total})")
        end
      end
      
      # Configure transformer and validator based on table
      {transformer, validator} = get_table_functions(table_name)
      
      importer = ChunkedImporter.new(
        table_name: get_phoenix_table_name(table_name),
        batch_size: options[:batch_size],
        timeout: options[:timeout],
        transformer: transformer,
        validator: validator,
        progress_callback: progress_callback
      )
      
      # Import the data
      ChunkedImporter.import_from_sql_inserts(importer, inserts)
    end
  end
  
  defp get_table_functions(table_name) do
    case table_name do
      "character_data" -> 
        {&ChunkedImporter.character_transformer/1, &ChunkedImporter.character_validator/1}
      
      "items" -> 
        {&ChunkedImporter.item_transformer/1, &ChunkedImporter.item_validator/1}
      
      "account" -> 
        {&ChunkedImporter.account_transformer/1, &ChunkedImporter.account_validator/1}
      
      _ -> 
        {nil, nil}
    end
  end
  
  defp get_phoenix_table_name(mysql_table_name) do
    case mysql_table_name do
      "character_data" -> "eqemu_characters"
      "account" -> "eqemu_accounts"
      "items" -> "eqemu_items"
      "guilds" -> "eqemu_guilds"
      "guild_members" -> "eqemu_guild_members"
      "zone" -> "eqemu_zones"
      name -> "eqemu_#{name}"
    end
  end
  
  defp get_existing_eqemu_tables do
    query = """
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name LIKE 'eqemu_%'
    """
    
    case Repo.query(query) do
      {:ok, %{rows: rows}} -> Enum.map(rows, &List.first/1)
      _ -> []
    end
  end
  
  defp print_banner do
    Logger.info("""
    
    ╔══════════════════════════════════════════════════════════════╗
    ║                    🎮 EQEmu PEQ Importer 🎮                  ║
    ║                                                              ║
    ║  Import Project EQ database into Phoenix EQEmu schema        ║
    ║  with comprehensive validation and progress tracking         ║
    ╚══════════════════════════════════════════════════════════════╝
    
    """)
  end
  
  defp print_options(options) do
    Logger.info("⚙️  Configuration:")
    Logger.info("   📁 Source file: #{options[:file]}")
    Logger.info("   📦 Batch size: #{options[:batch_size]}")
    Logger.info("   ⏱️  Timeout: #{options[:timeout]}ms")
    Logger.info("   📂 Output dir: #{options[:output_dir]}")
    Logger.info("   🔍 Validate: #{options[:validate]}")
    
    if options[:tables] do
      Logger.info("   📋 Tables: #{options[:tables]}")
    end
    
    Logger.info("")
  end
  
  defp print_validation_summary(validator) do
    Logger.info("📊 Validation Summary:")
    Logger.info("   ❌ Errors: #{length(validator.errors)}")
    Logger.info("   ⚠️  Warnings: #{length(validator.warnings)}")
    
    if Map.has_key?(validator.validation_results, :report_file) do
      Logger.info("   📄 Report: #{validator.validation_results.report_file}")
    end
    
    # Show top errors/warnings
    if length(validator.errors) > 0 do
      Logger.info("   🔝 Top Errors:")
      validator.errors
      |> Enum.take(3)
      |> Enum.each(&Logger.info("      - #{&1}"))
    end
    
    if length(validator.warnings) > 0 do
      Logger.info("   🔝 Top Warnings:")
      validator.warnings
      |> Enum.take(3)
      |> Enum.each(&Logger.info("      - #{&1}"))
    end
  end
  
  defp print_success_message do
    Logger.info("""
    
    ✅ PEQ Import Completed Successfully! ✅
    
    🎯 Next Steps:
    1. Start your Phoenix application: mix phx.server
    2. Visit the EQEmu admin panel: http://localhost:4000/eqemu/admin
    3. Test GraphQL queries: http://localhost:4000/api/graphql
    4. Configure your EQEmu C++ server to use the imported data
    5. Build and test your UE5 game client
    
    📚 Documentation:
    - EQEmu Integration Guide: eqemu/EQEMU_INTEGRATION_GUIDE.md
    - GraphQL Schema: lib/phoenix_app_web/schema/eqemu_types.ex
    - Admin Interface: lib/phoenix_app_web/live/eqemu_admin_live.ex
    
    🎮 Happy Gaming! 🎮
    """)
  end
  
  defp print_help do
    IO.puts("""
    EQEmu PEQ Database Importer
    
    USAGE:
        mix eqemu.peq.import [OPTIONS]
    
    OPTIONS:
        -f, --file FILE              PEQ SQL file path (default: eqemu/migrations/peq.sql)
        -b, --batch-size SIZE        Import batch size (default: 1000)
        -t, --timeout TIMEOUT       Batch timeout in ms (default: 60000)
        -o, --output-dir DIR         Output directory (default: tmp/eqemu_migration)
        -v, --validate               Validate import after completion (default: true)
        --parse-only                 Only parse and generate migrations
        --validate-only              Only validate existing import
        --tables TABLES              Comma-separated list of tables to import
        --force                      Continue despite validation errors
        --verbose                    Enable verbose logging
        -h, --help                   Show this help
    
    EXAMPLES:
        # Parse PEQ file and generate migrations only
        mix eqemu.peq.import --parse-only --file my_peq.sql
        
        # Full import with custom batch size
        mix eqemu.peq.import --file peq.sql --batch-size 500
        
        # Import specific tables only
        mix eqemu.peq.import --tables "accounts,characters,items"
        
        # Validate existing import
        mix eqemu.peq.import --validate-only
        
        # Force import ignoring validation errors
        mix eqemu.peq.import --force --verbose
    """)
  end
end