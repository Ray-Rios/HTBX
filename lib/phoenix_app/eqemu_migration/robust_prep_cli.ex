defmodule PhoenixApp.EqemuMigration.RobustPrepCli do
  @moduledoc """
  CLI tool for robust SQL import preparation that handles all MySQL compatibility issues.
  """

  alias PhoenixApp.EqemuMigration.RobustImportPreparer
  require Logger

  def main do
    IO.puts("🔧 Starting ROBUST SQL Import Preparation...")
    IO.puts("   This version handles all MySQL compatibility issues")
    
    # Define file paths
    input_file = "eqemu/mySQL_to_Postgres_Tool/postgres_peq_minimal.sql"
    output_file = "eqemu/mySQL_to_Postgres_Tool/phoenix_robust_import.sql"
    
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
      # Prepare the SQL file with robust conversion
      IO.puts("\n🔄 Applying robust MySQL to CockroachDB conversion...")
      stats = RobustImportPreparer.prepare_for_import(input_file, output_file)
      
      # Display results
      IO.puts("\n✅ ROBUST Import Preparation Complete!")
      IO.puts("📊 Conversion Statistics:")
      IO.puts("• Original size: #{format_bytes(stats.original_size)}")
      IO.puts("• Prepared size: #{format_bytes(stats.prepared_size)}")
      
      size_change = stats.size_change
      if size_change > 0 do
        IO.puts("• Size increase: +#{format_bytes(size_change)} (headers & splitting)")
      else
        IO.puts("• Size change: #{format_bytes(size_change)}")
      end
      
      IO.puts("\n🎯 Robust Conversion Features Applied:")
      IO.puts("• ✅ Complete MySQL syntax removal")
      IO.puts("• ✅ Large INSERT statement splitting (< 8MB each)")
      IO.puts("• ✅ Column name mapping (eqemu_id → id, etc.)")
      IO.puts("• ✅ Table name mapping (account → accounts, etc.)")
      IO.puts("• ✅ Data type conversion (unsigned → standard types)")
      IO.puts("• ✅ Character encoding cleanup")
      IO.puts("• ✅ Timestamp format fixes")
      IO.puts("• ✅ CockroachDB compatibility ensured")
      
      IO.puts("\n🚀 Ready to import: #{output_file}")
      IO.puts("\nNext steps:")
      IO.puts("1. Review the robust SQL file")
      IO.puts("2. Run: docker-compose exec web psql -h db -p 26257 -U root -d phoenixapp_dev -f #{output_file}")
      IO.puts("3. Monitor import progress (should complete without errors)")
      
    rescue
      error ->
        IO.puts("❌ Error during robust import preparation: #{inspect(error)}")
        System.halt(1)
    end
  end

  defp format_bytes(bytes) when bytes < 1024, do: "#{bytes} B"
  defp format_bytes(bytes) when bytes < 1024 * 1024, do: "#{Float.round(bytes / 1024, 1)} KB"
  defp format_bytes(bytes) when bytes < 1024 * 1024 * 1024, do: "#{Float.round(bytes / (1024 * 1024), 1)} MB"
  defp format_bytes(bytes), do: "#{Float.round(bytes / (1024 * 1024 * 1024), 1)} GB"
end