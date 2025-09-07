#!/usr/bin/env elixir

# Load the migration modules
Code.require_file("lib/phoenix_app/eqemu_migration/row_counter.ex")
Code.require_file("lib/phoenix_app/eqemu_migration/database_analyzer.ex")
Code.require_file("lib/phoenix_app/eqemu_migration/table_inspector.ex")
Code.require_file("lib/phoenix_app/eqemu_migration/table_filter.ex")
Code.require_file("lib/phoenix_app/eqemu_migration/table_mappings.ex")
Code.require_file("lib/phoenix_app/eqemu_migration/schema_comparator.ex")
Code.require_file("lib/phoenix_app/eqemu_migration/cli.ex")

alias PhoenixApp.EqemuMigration.RowCounter
alias PhoenixApp.EqemuMigration.TableFilter
alias PhoenixApp.EqemuMigration.TableMappings
alias PhoenixApp.EqemuMigration.SchemaComparator
alias PhoenixApp.EqemuMigration.CLI

IO.puts("🔍 Testing EQEMU Migration Tools...")

# Test with the actual dump file
file_path = "eqemu/mySQL_to_Postgres_Tool/postgres_peq.sql"

case File.stat(file_path) do
  {:ok, %{size: size}} ->
    IO.puts("📁 Found dump file: #{file_path}")
    IO.puts("📊 File size: #{Float.round(size / (1024 * 1024), 1)} MB")
    
    IO.puts("\n🔍 Starting row count analysis...")
    
    case RowCounter.count_all_rows(file_path) do
      {:ok, counts} ->
        IO.puts("✅ Analysis complete!")
        
        # Show some statistics
        stats = RowCounter.get_size_statistics(counts)
        IO.puts("\n📈 Statistics:")
        IO.puts("  Total tables: #{stats.total_tables}")
        IO.puts("  Total rows: #{stats.total_rows}")
        IO.puts("  Average rows per table: #{stats.average_rows}")
        IO.puts("  Tables over 6,000 rows: #{stats.tables_over_6000}")
        
        # Show exclusion analysis
        IO.puts(TableFilter.format_exclusion_analysis(counts))
        
        # Show filtered statistics
        filtered_counts = TableFilter.filter_table_counts(counts)
        filtered_stats = RowCounter.get_size_statistics(filtered_counts)
        
        IO.puts("\n🎯 After Filtering (Essential Tables Only):")
        IO.puts("  Tables: #{filtered_stats.total_tables}")
        IO.puts("  Total rows: #{filtered_stats.total_rows}")
        IO.puts("  Tables over 6,000 rows: #{filtered_stats.tables_over_6000}")
        
        if filtered_stats.tables_over_6000 > 0 do
          IO.puts("\n⚠️  Large tables that still need trimming:")
          filtered_counts
          |> Enum.filter(fn {_table, count} -> count > 6000 end)
          |> Enum.sort_by(fn {_table, count} -> count end, :desc)
          |> Enum.with_index(1)
          |> Enum.each(fn {{table, count}, index} ->
            IO.puts("  #{index}. #{table}: #{count} rows")
          end)
        else
          IO.puts("\n✅ All remaining tables are within the 6,000 row limit!")
        end
        
        # Show clean table mappings
        IO.puts("\n" <> String.duplicate("=", 60))
        IO.puts("🎯 Clean Table Mappings (No More eqemu_ Prefix!):")
        IO.puts(TableMappings.format_mapping_summary())
        
        # Test schema comparison
        IO.puts("\n" <> String.duplicate("=", 60))
        IO.puts("🔍 Testing Schema Comparison System...")
        
        comparison_result = SchemaComparator.compare_schemas()
        IO.puts(SchemaComparator.format_comparison_results(comparison_result))
        
      {:error, reason} ->
        IO.puts("❌ Error: #{inspect(reason)}")
    end
    
  {:error, reason} ->
    IO.puts("❌ Cannot access file: #{inspect(reason)}")
end