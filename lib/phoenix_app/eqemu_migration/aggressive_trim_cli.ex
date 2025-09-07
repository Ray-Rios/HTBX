defmodule PhoenixApp.EqemuMigration.AggressiveTrimCli do
  @moduledoc """
  CLI for aggressive SQL trimming to create a minimal development database.
  """

  alias PhoenixApp.EqemuMigration.AggressiveTrimmer
  require Logger

  def main do
    IO.puts("🔥 Starting AGGRESSIVE SQL Trimming for Minimal Development Database...")
    
    input_path = "eqemu/mySQL_to_Postgres_Tool/postgres_peq_trimmed.sql"
    output_path = "eqemu/mySQL_to_Postgres_Tool/postgres_peq_minimal.sql"
    
    IO.puts("📁 Input:  #{input_path}")
    IO.puts("📁 Output: #{output_path}")
    
    # Check if input file exists
    unless File.exists?(input_path) do
      IO.puts("❌ Error: Input file not found: #{input_path}")
      IO.puts("💡 Run the regular trimming first to create the input file.")
      System.halt(1)
    end
    
    # Get original file size
    original_size = File.stat!(input_path).size
    IO.puts("📊 Starting size: #{format_bytes(original_size)}")
    
    # Perform aggressive trimming
    case AggressiveTrimmer.trim_sql_file(input_path, output_path) do
      {:ok, _output_path} ->
        # Get new file size
        new_size = File.stat!(output_path).size
        reduction = original_size - new_size
        percentage = Float.round((reduction / original_size) * 100, 1)
        
        IO.puts("✅ AGGRESSIVE Trimming Complete!")
        IO.puts("")
        IO.puts("📊 Final Statistics:")
        IO.puts("• Starting size: #{format_bytes(original_size)}")
        IO.puts("• Final size: #{format_bytes(new_size)}")
        IO.puts("• Total reduction: #{format_bytes(reduction)} (#{percentage}%)")
        IO.puts("")
        IO.puts("🎯 Aggressive Trimming Applied:")
        IO.puts("• ❌ Removed non-essential tables entirely")
        IO.puts("• 📉 Accounts: Limited to 50 test accounts")
        IO.puts("• 👤 Characters: Limited to 100 test characters")
        IO.puts("• 🎒 Items: Limited to 1,000 essential items")
        IO.puts("• 👹 NPCs: Limited to 500 basic NPCs")
        IO.puts("• 🗺️  Zones: Limited to 50 core zones")
        IO.puts("• ✨ Spells: Limited to 500 core spells")
        IO.puts("• 💰 Loot: Minimal loot tables")
        IO.puts("• 🏪 Merchants: Basic merchant items only")
        IO.puts("")
        
        if new_size < 50 * 1_048_576 do  # 50MB
          IO.puts("🎉 SUCCESS: File is now under 50MB - perfect for development!")
        else
          IO.puts("⚠️  File is still over 50MB but significantly reduced")
        end
        
        IO.puts("")
        IO.puts("🚀 Ready to import: #{output_path}")
        IO.puts("")
        IO.puts("Next steps:")
        IO.puts("1. Review the minimal SQL file")
        IO.puts("2. Run: docker-compose exec web psql -h db -p 26257 -U root -d phoenixapp_dev -f #{output_path}")
        IO.puts("3. Test Phoenix integration with minimal dataset")
        
      {:error, reason} ->
        IO.puts("❌ Aggressive trimming failed: #{reason}")
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