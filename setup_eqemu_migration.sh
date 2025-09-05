#!/bin/bash

# EQEmu PEQ Database Migration Setup Script
# Converts PEQ MySQL dump to Phoenix PostgreSQL schema

set -e

echo "🎮 EQEmu PEQ Database Migration Setup"
echo "======================================"

# Configuration
PEQ_SQL_FILE="eqemu/migrations/peq.sql"
TEMP_DIR="tmp/eqemu_migration"
CONVERTED_SQL_FILE="$TEMP_DIR/peq_converted.sql"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if PEQ SQL file exists
check_peq_file() {
    log_info "Checking for PEQ SQL file..."
    
    if [ ! -f "$PEQ_SQL_FILE" ]; then
        log_error "PEQ SQL file not found: $PEQ_SQL_FILE"
        log_info "Please ensure your peq.sql file is placed in eqemu/migrations/"
        log_info "You can download it from: https://github.com/ProjectEQ/peqdatabase"
        exit 1
    fi
    
    # Get file size
    FILE_SIZE=$(stat -f%z "$PEQ_SQL_FILE" 2>/dev/null || stat -c%s "$PEQ_SQL_FILE" 2>/dev/null || echo "unknown")
    log_success "Found PEQ SQL file (Size: $FILE_SIZE bytes)"
}

# Create temporary directory
setup_temp_dir() {
    log_info "Setting up temporary directory..."
    mkdir -p "$TEMP_DIR"
    log_success "Temporary directory created: $TEMP_DIR"
}

# Convert MySQL syntax to PostgreSQL
convert_mysql_to_postgresql() {
    log_info "Converting MySQL syntax to PostgreSQL..."
    log_warning "This may take several minutes for large files..."
    
    # Create the conversion script
    cat > "$TEMP_DIR/mysql_to_postgresql.py" << 'EOF'
#!/usr/bin/env python3
"""
MySQL to PostgreSQL Converter for PEQ Database
Converts MySQL dump syntax to PostgreSQL-compatible SQL
"""

import re
import sys
import os

def convert_mysql_to_postgresql(input_file, output_file):
    print(f"🔄 Converting {input_file} to PostgreSQL format...")
    
    with open(input_file, 'r', encoding='utf-8', errors='ignore') as infile:
        with open(output_file, 'w', encoding='utf-8') as outfile:
            line_count = 0
            converted_lines = 0
            
            # Write PostgreSQL header
            outfile.write("-- Converted PEQ Database for PostgreSQL\n")
            outfile.write("-- Original MySQL dump converted to PostgreSQL syntax\n\n")
            outfile.write("SET client_encoding = 'UTF8';\n")
            outfile.write("SET standard_conforming_strings = on;\n\n")
            
            for line in infile:
                line_count += 1
                original_line = line
                
                # Skip MySQL-specific comments and commands
                if (line.startswith('/*!') or 
                    line.startswith('--') or
                    'SET @' in line or
                    'SET NAMES' in line or
                    'SET character_set_client' in line or
                    'SET FOREIGN_KEY_CHECKS' in line or
                    'SET UNIQUE_CHECKS' in line or
                    'SET SQL_MODE' in line or
                    'SET TIME_ZONE' in line or
                    'SET SQL_NOTES' in line):
                    continue
                
                # Convert CREATE DATABASE
                if 'CREATE DATABASE' in line and 'IF NOT EXISTS' in line:
                    # Skip database creation - we'll use existing Phoenix DB
                    continue
                
                # Convert USE database
                if line.startswith('USE '):
                    continue
                
                # Convert DROP TABLE IF EXISTS
                line = re.sub(r'DROP TABLE IF EXISTS `([^`]+)`;', 
                             r'DROP TABLE IF EXISTS temp_\1 CASCADE;', line)
                
                # Convert CREATE TABLE
                if 'CREATE TABLE' in line:
                    # Convert table name with backticks to temp_ prefix
                    line = re.sub(r'CREATE TABLE `([^`]+)`', r'CREATE TEMPORARY TABLE temp_\1', line)
                    # Remove MySQL engine and charset specifications
                    line = re.sub(r'\) ENGINE=\w+ DEFAULT CHARSET=\w+;', ');', line)
                
                # Convert data types
                line = re.sub(r'\bint\(\d+\)', 'INTEGER', line)
                line = re.sub(r'\btinyint\(\d+\)', 'SMALLINT', line)
                line = re.sub(r'\bsmallint\(\d+\)', 'SMALLINT', line)
                line = re.sub(r'\bmediumint\(\d+\)', 'INTEGER', line)
                line = re.sub(r'\bbigint\(\d+\)', 'BIGINT', line)
                line = re.sub(r'\bfloat\(\d+,\d+\)', 'REAL', line)
                line = re.sub(r'\bdouble\(\d+,\d+\)', 'DOUBLE PRECISION', line)
                line = re.sub(r'\bdecimal\(\d+,\d+\)', 'DECIMAL', line)
                line = re.sub(r'\bvarchar\((\d+)\)', r'VARCHAR(\1)', line)
                line = re.sub(r'\btext\b', 'TEXT', line)
                line = re.sub(r'\blongtext\b', 'TEXT', line)
                line = re.sub(r'\bmediumtext\b', 'TEXT', line)
                line = re.sub(r'\btinytext\b', 'TEXT', line)
                line = re.sub(r'\bdatetime\b', 'TIMESTAMP', line)
                line = re.sub(r'\btimestamp\b', 'TIMESTAMP', line)
                
                # Convert AUTO_INCREMENT
                line = re.sub(r'\bAUTO_INCREMENT\b', '', line)
                
                # Convert unsigned
                line = re.sub(r'\bUNSIGNED\b', '', line)
                
                # Remove backticks
                line = re.sub(r'`([^`]+)`', r'\1', line)
                
                # Convert INSERT statements
                if line.startswith('INSERT INTO '):
                    # Convert table names in INSERT statements
                    line = re.sub(r'INSERT INTO ([a-zA-Z_]+)', r'INSERT INTO temp_\1', line)
                
                # Convert LOCK/UNLOCK TABLES
                if 'LOCK TABLES' in line or 'UNLOCK TABLES' in line:
                    continue
                
                # Convert SET statements for character set
                if line.startswith('SET ') and 'character_set_client' in line:
                    continue
                
                if line != original_line:
                    converted_lines += 1
                
                outfile.write(line)
                
                # Progress indicator
                if line_count % 10000 == 0:
                    print(f"📊 Processed {line_count} lines, converted {converted_lines} lines")
    
    print(f"✅ Conversion complete: {line_count} lines processed, {converted_lines} lines converted")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 mysql_to_postgresql.py <input_file> <output_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    if not os.path.exists(input_file):
        print(f"❌ Input file not found: {input_file}")
        sys.exit(1)
    
    convert_mysql_to_postgresql(input_file, output_file)
EOF

    # Run the conversion
    python3 "$TEMP_DIR/mysql_to_postgresql.py" "$PEQ_SQL_FILE" "$CONVERTED_SQL_FILE"
    
    if [ $? -eq 0 ]; then
        log_success "MySQL to PostgreSQL conversion completed"
    else
        log_error "Conversion failed"
        exit 1
    fi
}

# Create Phoenix migration
create_phoenix_migration() {
    log_info "Phoenix migration already created: priv/repo/migrations/20250903000001_create_eqemu_schema.exs"
    log_info "Run: mix ecto.migrate to create the schema"
}

# Create data import script
create_import_script() {
    log_info "Creating data import script..."
    
    cat > "$TEMP_DIR/import_peq_data.sql" << EOF
-- Import PEQ data into Phoenix EQEmu schema
-- This script maps temporary PEQ tables to Phoenix schema

-- Import accounts
INSERT INTO eqemu_accounts (id, user_id, eqemu_id, name, status, expansion, inserted_at, updated_at)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM users WHERE is_admin = true LIMIT 1),
    id,
    name,
    COALESCE(status, 0),
    COALESCE(expansion, 8),
    NOW(),
    NOW()
FROM temp_account
WHERE id IS NOT NULL
ON CONFLICT (eqemu_id) DO NOTHING;

-- Import characters
INSERT INTO eqemu_characters (
    id, user_id, eqemu_id, account_id, name, race, class, level, 
    zone_id, x, y, z, heading, gender, hp, mana, endurance,
    str, sta, cha, dex, int, agi, wis, platinum, gold, silver, copper,
    exp, aa_points, inserted_at, updated_at
)
SELECT 
    gen_random_uuid(),
    (SELECT user_id FROM eqemu_accounts WHERE eqemu_id = temp_character_data.account_id LIMIT 1),
    id,
    account_id,
    name,
    COALESCE(race, 1),
    COALESCE(class, 1),
    COALESCE(level, 1),
    COALESCE(zone_id, 1),
    COALESCE(x, 0.0),
    COALESCE(y, 0.0),
    COALESCE(z, 0.0),
    COALESCE(heading, 0.0),
    COALESCE(gender, 0),
    COALESCE(hp, 100),
    COALESCE(mana, 0),
    COALESCE(endurance, 100),
    COALESCE(str, 75),
    COALESCE(sta, 75),
    COALESCE(cha, 75),
    COALESCE(dex, 75),
    COALESCE(int, 75),
    COALESCE(agi, 75),
    COALESCE(wis, 75),
    COALESCE(platinum, 0),
    COALESCE(gold, 0),
    COALESCE(silver, 0),
    COALESCE(copper, 0),
    COALESCE(exp, 0),
    COALESCE(aa_points, 0),
    NOW(),
    NOW()
FROM temp_character_data
WHERE id IS NOT NULL AND account_id IS NOT NULL
ON CONFLICT (eqemu_id) DO NOTHING;

-- Import items (limited to first 10000 for initial testing)
INSERT INTO eqemu_items (
    id, eqemu_id, name, damage, delay, itemtype, weight, price,
    ac, hp, mana, str, sta, cha, dex, int, agi, wis,
    classes, races, slots, reqlevel, inserted_at, updated_at
)
SELECT 
    gen_random_uuid(),
    id,
    COALESCE(name, 'Unknown Item'),
    COALESCE(damage, 0),
    COALESCE(delay, 0),
    COALESCE(itemtype, 0),
    COALESCE(weight, 0),
    COALESCE(price, 0),
    COALESCE(ac, 0),
    COALESCE(hp, 0),
    COALESCE(mana, 0),
    COALESCE(astr, 0),
    COALESCE(asta, 0),
    COALESCE(acha, 0),
    COALESCE(adex, 0),
    COALESCE(aint, 0),
    COALESCE(aagi, 0),
    COALESCE(awis, 0),
    COALESCE(classes, 0),
    COALESCE(races, 0),
    COALESCE(slots, 0),
    COALESCE(reqlevel, 0),
    NOW(),
    NOW()
FROM temp_items
WHERE id IS NOT NULL
LIMIT 10000
ON CONFLICT (eqemu_id) DO NOTHING;

-- Import zones
INSERT INTO eqemu_zones (
    id, eqemu_id, short_name, long_name, safe_x, safe_y, safe_z,
    min_level, max_level, expansion, inserted_at, updated_at
)
SELECT 
    gen_random_uuid(),
    zoneidnumber,
    short_name,
    COALESCE(long_name, short_name),
    COALESCE(safe_x, 0.0),
    COALESCE(safe_y, 0.0),
    COALESCE(safe_z, 0.0),
    COALESCE(min_level, 1),
    COALESCE(max_level, 255),
    COALESCE(expansion, 0),
    NOW(),
    NOW()
FROM temp_zone
WHERE zoneidnumber IS NOT NULL AND short_name IS NOT NULL
ON CONFLICT (eqemu_id) DO NOTHING;

-- Import guilds
INSERT INTO eqemu_guilds (
    id, eqemu_id, name, leader, inserted_at, updated_at
)
SELECT 
    gen_random_uuid(),
    id,
    name,
    COALESCE(leader, 0),
    NOW(),
    NOW()
FROM temp_guilds
WHERE id IS NOT NULL AND name IS NOT NULL
ON CONFLICT (eqemu_id) DO NOTHING;

-- Show import summary
SELECT 'Accounts' as table_name, COUNT(*) as record_count FROM eqemu_accounts
UNION ALL
SELECT 'Characters', COUNT(*) FROM eqemu_characters
UNION ALL
SELECT 'Items', COUNT(*) FROM eqemu_items
UNION ALL
SELECT 'Zones', COUNT(*) FROM eqemu_zones
UNION ALL
SELECT 'Guilds', COUNT(*) FROM eqemu_guilds;
EOF

    log_success "Import script created: $TEMP_DIR/import_peq_data.sql"
}

# Create usage instructions
create_instructions() {
    log_info "Creating usage instructions..."
    
    cat > "$TEMP_DIR/IMPORT_INSTRUCTIONS.md" << 'EOF'
# EQEmu PEQ Database Import Instructions

## Overview
This guide helps you import your PEQ (Project EQ) database into your Phoenix EQEmu application.

## Prerequisites
- PEQ SQL dump file placed in `eqemu/migrations/peq.sql`
- Phoenix application with PostgreSQL database
- Docker and docker-compose setup

## Step-by-Step Import Process

### 1. Prepare the Database
```bash
# Start your Phoenix application
docker-compose up -d db

# Run Phoenix migrations to create EQEmu schema
docker-compose exec web mix ecto.migrate
```

### 2. Import PEQ Data
```bash
# Load the converted SQL into temporary tables
docker-compose exec db psql -U postgres -d phoenix_app_dev -f /tmp/eqemu_migration/peq_converted.sql

# Import data into Phoenix schema
docker-compose exec db psql -U postgres -d phoenix_app_dev -f /tmp/eqemu_migration/import_peq_data.sql
```

### 3. Verify Import
```bash
# Run the Phoenix importer script
docker-compose exec web mix run priv/repo/eqemu_peq_importer.exs
```

### 4. Test GraphQL API
```bash
# Test the EQEmu GraphQL endpoints
curl -X POST http://localhost:4000/api/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ eqemuCharacters { id name level race class } }"}'
```

## Important Notes

### Data Size Considerations
- The PEQ database is very large (50MB+ SQL file)
- Initial import may take 30+ minutes
- Consider importing in batches for better performance

### Schema Mapping
- Original PEQ IDs are preserved in `eqemu_id` fields
- Phoenix UUIDs are used as primary keys
- All data is linked to Phoenix user accounts

### Customization
- Edit `import_peq_data.sql` to customize data mapping
- Modify field mappings based on your needs
- Add additional tables as required

## Troubleshooting

### Common Issues
1. **File too large**: Split the SQL file into smaller chunks
2. **Memory issues**: Increase Docker memory limits
3. **Timeout errors**: Import in smaller batches
4. **Character encoding**: Ensure UTF-8 encoding

### Performance Tips
- Use `COPY` instead of `INSERT` for large datasets
- Create indexes after import, not before
- Consider using `UNLOGGED` tables for temporary data
- Vacuum and analyze after import

## Next Steps
After successful import:
1. Test character creation in Phoenix
2. Verify item data in GraphQL
3. Test zone transitions
4. Configure UE5 game integration
5. Set up pixel streaming

## Support
- Check Phoenix logs: `docker-compose logs web`
- Check database logs: `docker-compose logs db`
- Verify data: Connect to database and run queries
EOF

    log_success "Instructions created: $TEMP_DIR/IMPORT_INSTRUCTIONS.md"
}

# Main execution
main() {
    log_info "Starting EQEmu PEQ migration setup..."
    
    check_peq_file
    setup_temp_dir
    convert_mysql_to_postgresql
    create_phoenix_migration
    create_import_script
    create_instructions
    
    log_success "EQEmu PEQ migration setup completed!"
    echo ""
    log_info "Next steps:"
    echo "  1. Review the instructions: $TEMP_DIR/IMPORT_INSTRUCTIONS.md"
    echo "  2. Run Phoenix migrations: docker-compose exec web mix ecto.migrate"
    echo "  3. Import PEQ data using the generated scripts"
    echo "  4. Test your EQEmu GraphQL API"
    echo ""
    log_warning "Note: The PEQ database is very large. Import may take 30+ minutes."
}

# Run main function
main "$@"