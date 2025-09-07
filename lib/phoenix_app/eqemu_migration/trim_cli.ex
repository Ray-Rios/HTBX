defmodule PhoenixApp.EqemuMigration.TrimCli do
  @moduledoc """
  CLI for running advanced SQL file trimming to reduce database size.
  """

  alias PhoenixApp.EqemuMigration.AdvancedTrimmer
  require Logger

  def main do
    IO.puts("🔄 Starting Advanced SQL Trimming...")
    
    input_path = "eqemu/mySQL_to_Postgres_Tool/postgres_peq_phoenix.sql"
    output_path = "eqemu/mySQL_to_Postgres_Tool/postgres_peq_trimmed.sql"
    
    IO.puts("📁 Input:  #{input_path}")
    IO.puts("📁 Output: #{output_path}")
    
    # Check if input file exists
    unless File.exists?(input_path) do
      IO.puts("❌ Error: Input file not found: #{input_path}")
      System.halt(1)
    end
    
    # Get original file size
    original_size = File.stat!(input_path).size
    IO.puts("📊 Original size: #{format_bytes(original_size)}")
    
    # Perform trimming
    case AdvancedTrimmer.trim_sql_file(input_path, output_path) do
      {:ok, _output_path} ->
        # Get new file size
        new_size = File.stat!(output_path).size
        reduction = original_size - new_size
        percentage = Float.round((reduction / original_size) * 100, 1)
        
        IO.puts("✅ Advanced Trimming Complete!")
        IO.puts("")
        IO.puts("📊 Trimming Statistics:")
        IO.puts("• Original size: #{format_bytes(original_size)}")
        IO.puts("• Trimmed size: #{format_bytes(new_size)}")
        IO.puts("• Size reduction: #{format_bytes(reduction)} (#{percentage}%)")
        IO.puts("• Max rows per table: 15,000")
        IO.puts("")
        IO.puts("🎯 Key Trimming Strategies Applied:")
        IO.puts("• ✅ Items: Kept lower-ID items (< 100,000)")
        IO.puts("• ✅ NPCs: Kept level ≤ 50, ID < 50,000")
        IO.puts("• ✅ Spawns: Focused on starter zones")
        IO.puts("• ✅ Loot: Kept higher-chance drops")
        IO.puts("• ✅ Merchants: Basic items only")
        IO.puts("• ✅ Skills: Standard classes, level ≤ 60")
        IO.puts("• ✅ Spells: Essential spells with class restrictions")
        IO.puts("")
        IO.puts("🚀 Ready to import: #{output_path}")
        IO.puts("")
        IO.puts("Next steps:")
        IO.puts("1. Review the trimmed SQL file")
        IO.puts("2. Run: docker-compose exec web psql -h db -p 26257 -U root -d phoenixapp_dev -f #{output_path}")
        IO.puts("3. Test Phoenix integration")
        
      {:error, reason} ->
        IO.puts("❌ Trimming failed: #{reason}")
        System.halt(1)
    end
  end

  defp format_bytes(bytes) when is_integer(bytes) do
    cond do
      bytes >= 1_073_741_824 -> "#{Float.round(bytes / 1_073_741_824, 1)} GB"
      bytes >= 1_048_576 -> "#{Float.round(bytes / 1_048_576, 1)} MB"
      bytes >= 1_024 -> "#{Float.round(bytes / 1_024, 1)} KB"
      true -> "#{bytes} bytes"
    end
  end
end