defmodule PhoenixApp.EqemuMigration.DatabaseAnalyzerTest do
  use ExUnit.Case, async: true
  
  alias PhoenixApp.EqemuMigration.DatabaseAnalyzer
  alias PhoenixApp.EqemuMigration.RowCounter
  alias PhoenixApp.EqemuMigration.TableInspector

  describe "DatabaseAnalyzer" do
    test "can analyze a sample SQL dump" do
      # Create a temporary test file
      sample_sql = """
      -- Sample EQEmu database dump
      CREATE TABLE `account` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `name` varchar(30) NOT NULL DEFAULT '',
        `password` varchar(50) NOT NULL DEFAULT '',
        `status` int(5) NOT NULL DEFAULT '0',
        `time_creation` int(11) unsigned NOT NULL DEFAULT '0',
        PRIMARY KEY (`id`),
        UNIQUE KEY `name` (`name`)
      ) ENGINE=MyISAM DEFAULT CHARSET=latin1;

      INSERT INTO `account` VALUES (1,'testuser','password123',0,1234567890),(2,'admin','adminpass',100,1234567891);

      CREATE TABLE `character_data` (
        `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
        `account_id` int(11) NOT NULL DEFAULT '0',
        `name` varchar(64) NOT NULL DEFAULT '',
        `level` tinyint(3) unsigned NOT NULL DEFAULT '0',
        PRIMARY KEY (`id`),
        KEY `account_id` (`account_id`)
      ) ENGINE=MyISAM DEFAULT CHARSET=latin1;

      INSERT INTO `character_data` VALUES (1,1,'TestChar',10),(2,1,'AltChar',5),(3,2,'AdminChar',60);
      """

      # Write to temporary file
      temp_file = System.tmp_dir!() <> "/test_dump.sql"
      File.write!(temp_file, sample_sql)

      try do
        # Test the analyzer
        assert {:ok, result} = DatabaseAnalyzer.analyze_dump(temp_file)
        
        # Verify basic structure
        assert is_map(result.tables)
        assert is_list(result.largest_tables)
        assert %DateTime{} = result.analysis_timestamp
        
        # Should find both tables
        assert Map.has_key?(result.tables, "account")
        assert Map.has_key?(result.tables, "character_data")
        
        # Check account table info
        account_info = result.tables["account"]
        assert account_info.name == "account"
        assert account_info.row_count == 2
        
        # Check character_data table info
        char_info = result.tables["character_data"]
        assert char_info.name == "character_data"
        assert char_info.row_count == 3
        
      after
        File.rm(temp_file)
      end
    end
  end

  describe "RowCounter" do
    test "can count rows in INSERT statements" do
      sample_sql = """
      INSERT INTO `test_table` VALUES (1,'test'),(2,'test2'),(3,'test3');
      INSERT INTO `another_table` VALUES (1,'single');
      """

      temp_file = System.tmp_dir!() <> "/test_rows.sql"
      File.write!(temp_file, sample_sql)

      try do
        assert {:ok, counts} = RowCounter.count_all_rows(temp_file)
        
        assert counts["test_table"] == 3
        assert counts["another_table"] == 1
        
        # Test statistics
        stats = RowCounter.get_size_statistics(counts)
        assert stats.total_tables == 2
        assert stats.total_rows == 4
        assert stats.average_rows == 2.0
        
      after
        File.rm(temp_file)
      end
    end
  end

  describe "TableInspector" do
    test "can extract table structure from CREATE TABLE statement" do
      create_statement = """
      CREATE TABLE `test_table` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `name` varchar(50) NOT NULL DEFAULT '',
        `status` int(5) DEFAULT '0',
        `created_at` timestamp NULL DEFAULT NULL,
        PRIMARY KEY (`id`),
        UNIQUE KEY `name_unique` (`name`)
      ) ENGINE=MyISAM DEFAULT CHARSET=latin1;
      """

      assert {:ok, structure} = TableInspector.extract_table_structure(create_statement)
      
      assert structure.name == "test_table"
      assert structure.engine == "myisam"
      assert structure.charset == "latin1"
      
      # Check columns
      assert length(structure.columns) == 4
      
      id_col = Enum.find(structure.columns, &(&1.name == "id"))
      assert id_col.type == "int(11)"
      assert id_col.auto_increment == true
      assert id_col.nullable == false
      
      name_col = Enum.find(structure.columns, &(&1.name == "name"))
      assert name_col.type == "varchar(50)"
      assert name_col.nullable == false
      assert name_col.default == ""
      
      # Check constraints
      pk_constraint = Enum.find(structure.constraints, &(&1.type == :primary_key))
      assert pk_constraint.columns == ["id"]
      
      unique_constraint = Enum.find(structure.constraints, &(&1.type == :unique))
      assert unique_constraint.columns == ["name"]
    end
  end
end