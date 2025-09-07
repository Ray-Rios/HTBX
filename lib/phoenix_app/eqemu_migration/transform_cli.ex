defmodule PhoenixApp.EqemuMigration.TransformCli do
  @moduledoc """
  CLI interface for SQL transformation
  """
  alias PhoenixApp.EqemuMigration.SqlTransformer
  require Logger

  def main(args \\ []) do
    case args do
      [] -> 
        transform_default()
      [input_path] ->
        transform_with_input(input_path)
      [input_path, output_path] ->
        transform_with_paths(input_path, output_path)
      _ ->
        show_usage()
    end
  end

  defp transform_default do
    input_path = "eqemu/mySQL_to_Postgres_Tool/postgres_peq.sql"
    output_path = "eqemu/mySQL_to_Postgres_Tool/postgres_peq_phoenix.sql"
    
    if File.exists?(input_path) do
      transform_with_paths(input_path, output_path)
    else
      IO.puts("❌ Default input file not found: #{input_path}")
      IO.puts("Please specify the path to your postgres_peq.sql file")
      show_usage()
    end
  end

  defp transform_with_input(input_path) do
    output_path = String.replace(input_path, ".sql", "_phoenix.sql")
    transform_with_paths(input_path, output_path)
  end

  defp transform_with_paths(input_path, output_path) do
    IO.puts("🔄 Starting SQL Transformation...")
    IO.puts("📁 Input:  #{input_path}")
    IO.puts("📁 Output: #{output_path}")
    IO.puts("")

    case SqlTransformer.transform_sql_file(input_path, output_path) do
      {:ok, _} ->
        show_success(input_path, output_path)
      {:error, reason} ->
        IO.puts("❌ Transformation failed: #{reason}")
    end
  end

  defp show_success(input_path, output_path) do
    stats = get_transformation_stats(input_path, output_path)
    
    IO.puts("✅ SQL Transformation Complete!")
    IO.puts("")
    IO.puts("📊 Transformation Statistics:")
    IO.puts("• Original size: #{format_bytes(stats.original_size)}")
    IO.puts("• Transformed size: #{format_bytes(stats.transformed_size)}")
    IO.puts("• Size reduction: #{format_bytes(stats.size_reduction)} (#{stats.reduction_percentage}%)")
    IO.puts("")
    IO.puts("🎯 Key Changes Applied:")
    IO.puts("• ✅ Table names updated (temp_account → accounts, etc.)")
    IO.puts("• ✅ Field names fixed (stra → str, chaa → cha, etc.)")
    IO.puts("• ✅ Augmentations → Materia system")
    IO.puts("• ✅ Tribute → DKP system")
    IO.puts("• ✅ Added Phoenix integration fields")
    IO.puts("• ✅ Removed unnecessary tables (grid entries, logs)")
    IO.puts("")
    IO.puts("🚀 Ready to import: #{output_path}")
    IO.puts("")
    IO.puts("Next steps:")
    IO.puts("1. Review the transformed SQL file")
    IO.puts("2. Run: docker-compose exec web psql -h db -U postgres -d phoenix_app_dev -f #{output_path}")
    IO.puts("3. Test Phoenix integration")
  end

  defp show_usage do
    IO.puts("""
    🔧 EQEmu SQL Transformer
    
    Usage:
      mix run -e "PhoenixApp.EqemuMigration.TransformCli.main()"
      mix run -e "PhoenixApp.EqemuMigration.TransformCli.main(['path/to/input.sql'])"
      mix run -e "PhoenixApp.EqemuMigration.TransformCli.main(['input.sql', 'output.sql'])"
    
    This tool transforms EQEmu postgres_peq.sql to match Phoenix schema:
    • Renames tables and fields
    • Adds missing Phoenix fields
    • Removes unnecessary data
    • Updates constraints
    """)
  end

  defp get_transformation_stats(original_path, transformed_path) do
    original_size = File.stat!(original_path).size
    transformed_size = File.stat!(transformed_path).size
    
    %{
      original_size: original_size,
      transformed_size: transformed_size,
      size_reduction: original_size - transformed_size,
      reduction_percentage: ((original_size - transformed_size) / original_size * 100) |> Float.round(1)
    }
  end

  defp format_bytes(bytes) do
    cond do
      bytes >= 1_048_576 -> "#{Float.round(bytes / 1_048_576, 1)} MB"
      bytes >= 1_024 -> "#{Float.round(bytes / 1_024, 1)} KB"
      true -> "#{bytes} bytes"
    end
  end
end