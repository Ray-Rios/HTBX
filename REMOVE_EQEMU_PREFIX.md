# Remove EQEMU_ Prefix - Action Plan

## Problem
The Phoenix app currently uses `eqemu_` prefixed table names (like `eqemu_accounts`, `eqemu_characters`) which makes the migration mapping unnecessarily complex.

## Solution
Remove the `eqemu_` prefix from all table names to create clean, direct mappings:

**Before (Complex):**
```
account → eqemu_accounts (17 field mappings, 0 missing in Phoenix, 1 missing in original)
character_data → eqemu_characters (62 field mappings, 0 missing in Phoenix, 3 missing in original)
```

**After (Simple):**
```
account → accounts (direct mapping)
character_data → characters (direct mapping)
```

## Files Created/Updated

### ✅ Database Migration
- `priv/repo/migrations/20250106000003_remove_eqemu_prefix.exs`
  - Renames all `eqemu_*` tables to remove prefix
  - Updates foreign key constraints
  - Updates index names

### ✅ Schema Updates
- `lib/phoenix_app/eqemu_game/account.ex` - Updated table name
- `lib/phoenix_app/eqemu_game/character.ex` - Updated table name
- `update_schema_names.exs` - Script to update GraphQL types

### ✅ Migration Tools
- `lib/phoenix_app/eqemu_migration/table_mappings.ex` - Clean mapping definitions
- Updated table filter to use correct names

## Steps to Complete

### 1. Run Database Migration
```bash
docker-compose exec web mix ecto.migrate
```

### 2. Update Schema References
```bash
docker-compose exec web elixir update_schema_names.exs
```

### 3. Update Remaining Schemas
Need to update these files to use new table names:
- All remaining schema files in `lib/phoenix_app/eqemu_game/`
- GraphQL resolvers in `lib/phoenix_app_web/resolvers/`
- Any LiveView components that reference the old names

### 4. Test the Changes
```bash
# Test database connection
docker-compose exec web mix ecto.reset

# Test GraphQL schema
docker-compose exec web iex -S mix
# Then test queries in IEx
```

## Benefits After Completion

### 🎯 Simplified Mappings
- `account` → `accounts` (instead of `account` → `eqemu_accounts`)
- `character_data` → `characters` (instead of `character_data` → `eqemu_characters`)
- `items` → `items` (direct 1:1 mapping!)

### 📊 Reduced Complexity
- No more confusing `eqemu_` prefix in table names
- Direct field mappings without prefix translation
- Cleaner GraphQL schema (`:character` instead of `:eqemu_character`)
- Simpler migration scripts

### 🔧 Better Developer Experience
- Table names match EQEmu conventions
- Less cognitive overhead when working with schemas
- Easier to understand database structure
- More intuitive API endpoints

## Migration Impact

This change will:
✅ **Simplify** all future migration work  
✅ **Reduce** mapping complexity by ~50%  
✅ **Improve** code readability  
✅ **Maintain** all existing functionality  
❌ **Require** updating existing references (one-time cost)  

The benefits far outweigh the one-time update cost!