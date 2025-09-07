defmodule PhoenixApp.EqemuMigration.ImportPrepCli do
  @moduledoc """
  CLI tool for preparing EQEmu SQL files for Phoenix import.
  """

  alias PhoenixApp.EqemuMigration.ImportPreparer
  require Logger

  def main do
    IO.puts("🔧 Starting SQL Import Preparation...")
    
    # Define file paths
    input_file = "eqemu/mySQL_to_Postgres_Tool/postgres_peq_minimal.sql"
    output_file = "eqemu/mySQL_to_Postgres_Tool/phoenix_import_ready.sql"
    
    IO.puts("📁 Input:  #{input_file}")
    IO.puts("📁 Output: #{output_file}")
    
    # Check if input file exists
    unless File.exists?(input_file) do
      IO.puts("❌ Error: Input file not found: #{input_file}")
      System.halt(1)
    end
    
    # Get original file size
    original_size = File.stat!(input_file).size
    IO.puts("📊 Original size: #{format_bytes(original_size)}")
    
    try do
      # Create database backup first
      IO.puts("\n🔄 Creating database backup...")
      case ImportPreparer.create_database_backup() do
        {:ok, backup_file} ->
          IO.puts("✅ Database backup created: #{backup_file}")
        {:error, reason} ->
          IO.puts("⚠️  Warning: Could not create database backup: #{reason}")
          IO.puts("   Continuing with import preparation...")
      end
      
      # Prepare the SQL file
      IO.puts("\n🔄 Preparing SQL file for Phoenix import...")
      stats = ImportPreparer.prepare_for_import(input_file, output_file)
      
      # Display results
      IO.puts("\n✅ Import Preparation Complete!")
      IO.puts("📊 Preparation Statistics:")
      IO.puts("• Original size: #{format_bytes(stats.original_size)}")
      IO.puts("• Prepared size: #{format_bytes(stats.prepared_size)}")
      
      size_change = stats.size_change
      if size_change > 0 do
        IO.puts("• Size increase: +#{format_bytes(size_change)} (constraints & indexes added)")
      else
        IO.puts("• Size change: #{format_bytes(size_change)}")
      end
      
      IO.puts("\n🎯 Preparation Features Applied:")
      IO.puts("• ✅ Converted TEMPORARY tables to regular tables")
      IO.puts("• ✅ Removed MySQL-specific syntax")
      IO.puts("• ✅ Added Phoenix-specific constraints")
      IO.puts("• ✅ Added performance indexes")
      IO.puts("• ✅ Added import safety headers/footers")
      
      IO.puts("\n🚀 Ready to import: #{output_file}")
      IO.puts("\nNext steps:")
      IO.puts("1. Review the prepared SQL file")
      IO.puts("2. Run: docker-compose exec web psql -h db -p 26257 -U root -d phoenixapp_dev -f #{output_file}")
      IO.puts("3. Verify import success and data integrity")
      
    rescue
      error ->
        IO.puts("❌ Error during import preparation: #{inspect(error)}")
        System.halt(1)
    end
  end

  defp format_bytes(bytes) when bytes < 1024, do: "#{bytes} B"
  defp format_bytes(bytes) when bytes < 1024 * 1024, do: "#{Float.round(bytes / 1024, 1)} KB"
  defp format_bytes(bytes) when bytes < 1024 * 1024 * 1024, do: "#{Float.round(bytes / (1024 * 1024), 1)} MB"
  defp format_bytes(bytes), do: "#{Float.round(bytes / (1024 * 1024 * 1024), 1)} GB"
end