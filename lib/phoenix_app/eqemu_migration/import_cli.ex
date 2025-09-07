defmodule PhoenixApp.EqemuMigration.ImportCli do
  @moduledoc """
  CLI interface for EQEmu data import
  """
  alias PhoenixApp.EqemuMigration.DataImporter
  require Logger

  def main(args \\ []) do
    case args do
      [] -> 
        import_default()
      [input_path] ->
        import_with_input(input_path)
      [input_path, output_path] ->
        import_with_paths(input_path, output_path)
      _ ->
        show_usage()
    end
  end

  defp import_default do
    input_path = "eqemu/mySQL_to_Postgres_Tool/postgres_peq_phoenix.sql"
    output_path = "eqemu/mySQL_to_Postgres_Tool/phoenix_import.sql"
    
    if File.exists?(input_path) do
      import_with_paths(input_path, output_path)
    else
      IO.puts("❌ Transformed SQL file not found: #{input_path}")
      IO.puts("Please run the SQL transformation first")
      show_usage()
    end
  end

  defp import_with_input(input_path) do
    output_path = String.replace(input_path, ".sql", "_import.sql")
    import_with_paths(input_path, output_path)
  end

  defp import_with_paths(input_path, output_path) do
    IO.puts("🔄 Creating Phoenix Import Script...")
    IO.puts("📁 Input:  #{input_path}")
    IO.puts("📁 Output: #{output_path}")
    IO.puts("")

    case DataImporter.create_import_script(input_path, output_path) do
      {:ok, _} ->
        show_success(output_path)
      {:error, reason} ->
        IO.puts("❌ Import script creation failed: #{reason}")
    end
  end

  defp show_success(output_path) do
    case DataImporter.get_import_stats(output_path) do
      {:error, reason} ->
        IO.puts("✅ Import script created: #{output_path}")
        IO.puts("❌ Could not read statistics: #{reason}")
      
      stats ->
        IO.puts("✅ Phoenix Import Script Created!")
        IO.puts("")
        IO.puts("📊 Import Statistics:")
        IO.puts("• Total INSERT statements: #{stats.total_inserts}")
        IO.puts("• Script size: #{format_bytes(stats.file_size)}")
        IO.puts("")
        IO.puts("📋 Tables to import:")
        
        Enum.each(stats.table_counts, fn {table, count} ->
          IO.puts("• #{table}: #{count} records")
        end)
        
        IO.puts("")
        IO.puts("🚀 Ready to import: #{output_path}")
        IO.puts("")
        IO.puts("Next steps:")
        IO.puts("1. Review the import script")
        IO.puts("2. Run: docker-compose exec web psql -h db -p 26257 -U root -d phoenixapp_dev -f #{output_path}")
        IO.puts("3. Verify data import")
    end
  end

  defp show_usage do
    IO.puts("""
    🔧 EQEmu Data Importer
    
    Usage:
      mix run -e "PhoenixApp.EqemuMigration.ImportCli.main()"
      mix run -e "PhoenixApp.EqemuMigration.ImportCli.main(['path/to/transformed.sql'])"
      mix run -e "PhoenixApp.EqemuMigration.ImportCli.main(['input.sql', 'output.sql'])"
    
    This tool creates a Phoenix-compatible import script from transformed EQEmu SQL:
    • Extracts INSERT statements for Phoenix tables
    • Transforms field names to match Phoenix schema
    • Creates a clean import script
    """)
  end

  defp format_bytes(bytes) do
    cond do
      bytes >= 1_048_576 -> "#{Float.round(bytes / 1_048_576, 1)} MB"
      bytes >= 1_024 -> "#{Float.round(bytes / 1_024, 1)} KB"
      true -> "#{bytes} bytes"
    end
  end
end