# PEQ Database Analysis & Phoenix Integration

## 🎯 **Overview**
Analysis of your PEQ (Project EQ) database dump and integration strategy with Phoenix EQEmu schema.

## 📊 **PEQ Database Structure Analysis**

### **Core Tables Identified**
Based on the PEQ SQL dump, here are the key tables we need to integrate:

#### **Character System (20+ tables)**
```sql
-- Primary character data
character_data              # Main character information
character_alternate_abilities # AA system
character_bandolier        # Equipment sets
character_bind             # Bind points
character_buffs            # Active buffs
character_currency         # Alternative currencies
character_disciplines     # Discipline abilities
character_inventory        # Items and equipment
character_languages        # Known languages
character_leadership_abilities # Leadership AAs
character_material         # Appearance/textures
character_memmed_spells    # Memorized spells
character_pet_info         # Pet data
character_skills           # Skill levels
character_spells           # Known spells
character_tasks            # Quest progress
```

#### **Items System (1 massive table)**
```sql
items                      # 240+ columns of item data
-- Includes: stats, effects, restrictions, appearance, etc.
```

#### **World/Zone System**
```sql
zone                       # Zone definitions and properties
zone_points               # Zone connections/portals
zone_flags                # Zone access flags
start_zones               # Starting locations
```

#### **Guild System**
```sql
guilds                    # Guild information
guild_members             # Guild membership
guild_ranks               # Guild rank definitions
guild_relations           # Guild alliances/wars
guild_bank                # Guild bank items
```

#### **Account System**
```sql
account                   # Player accounts
account_flags             # Account permissions
account_ip                # IP tracking
account_rewards           # Account rewards
```

## 🔄 **Schema Comparison: PEQ vs Phoenix**

### **Key Differences**

| Aspect | PEQ (MySQL) | Phoenix (PostgreSQL) |
|--------|-------------|---------------------|
| **Primary Keys** | Integer AUTO_INCREMENT | UUID with binary_id |
| **User System** | Separate account table | Integrated with Phoenix users |
| **Timestamps** | Unix timestamps (INTEGER) | PostgreSQL TIMESTAMP |
| **Character Set** | latin1 | UTF-8 |
| **Foreign Keys** | Limited constraints | Full referential integrity |
| **Data Types** | MySQL-specific types | PostgreSQL standard types |

### **Field Mapping Examples**

#### **Character Data Mapping**
```elixir
# PEQ character_data -> Phoenix eqemu_characters
PEQ Field               Phoenix Field           Notes
---------               -------------           -----
id                   -> eqemu_id              # Preserve original ID
account_id           -> account_id            # Link to eqemu_accounts
name                 -> name                  # Character name
last_login           -> last_login           # Unix timestamp
time_played          -> time_played          # Seconds played
level                -> level                # Character level
race                 -> race                 # Race ID
class                -> class                # Class ID
zone_id              -> zone_id              # Current zone
x, y, z, heading     -> x, y, z, heading     # Position
hp, mana, endurance  -> hp, mana, endurance  # Current stats
str, sta, cha, etc.  -> str, sta, cha, etc.  # Base stats
platinum, gold, etc. -> platinum, gold, etc. # Currency
```

#### **Items Data Mapping**
```elixir
# PEQ items -> Phoenix eqemu_items
PEQ Field               Phoenix Field           Notes
---------               -------------           -----
id                   -> eqemu_id              # Preserve original ID
name                 -> name                  # Item name
damage               -> damage                # Weapon damage
delay                -> delay                 # Weapon delay
ac                   -> ac                    # Armor class
hp, mana, endur      -> hp, mana, endur       # Stat bonuses
astr, asta, etc.     -> str, sta, etc.        # Attribute bonuses
classes              -> classes               # Class restrictions
races                -> races                # Race restrictions
slots                -> slots                # Equipment slots
reqlevel             -> reqlevel             # Level requirement
```

## ⚠️ **Challenges & Considerations**

### **1. Data Volume**
- **PEQ SQL File**: 50MB+ compressed, 200MB+ uncompressed
- **Items Table**: 100,000+ items with 240+ columns each
- **Character Data**: Complex relationships across 20+ tables
- **Import Time**: 30+ minutes for full database

### **2. Data Type Conversions**
```sql
-- MySQL -> PostgreSQL conversions needed
int(10) unsigned     -> INTEGER
tinyint(4)          -> SMALLINT
varchar(64)         -> VARCHAR(64)
text                -> TEXT
datetime            -> TIMESTAMP
float               -> REAL
```

### **3. Character Encoding**
- **PEQ**: latin1 character set
- **Phoenix**: UTF-8 encoding
- **Risk**: Character name corruption
- **Solution**: Proper encoding conversion during import

### **4. Foreign Key Relationships**
- **PEQ**: Minimal foreign key constraints
- **Phoenix**: Full referential integrity
- **Challenge**: Orphaned records in PEQ data
- **Solution**: Data cleanup during import

## 🛠️ **Migration Strategy**

### **Phase 1: Schema Creation**
```bash
# Create Phoenix EQEmu schema
mix ecto.migrate
```

### **Phase 2: Data Conversion**
```bash
# Convert MySQL dump to PostgreSQL
./setup_eqemu_migration.sh
```

### **Phase 3: Data Import**
```sql
-- Import into temporary tables
\i tmp/eqemu_migration/peq_converted.sql

-- Convert to Phoenix schema
\i tmp/eqemu_migration/import_peq_data.sql
```

### **Phase 4: Data Validation**
```elixir
# Run Phoenix importer for validation
mix run priv/repo/eqemu_peq_importer.exs
```

## 📋 **Relevant vs Irrelevant Fields**

### **Essential Fields (Keep)**
```elixir
# Character essentials
:name, :level, :race, :class, :zone_id
:x, :y, :z, :heading  # Position
:hp, :mana, :endurance  # Current stats
:str, :sta, :cha, :dex, :int, :agi, :wis  # Base stats
:platinum, :gold, :silver, :copper  # Currency
:exp, :aa_points  # Experience

# Item essentials  
:name, :damage, :delay, :ac  # Basic properties
:hp, :mana, :str, :sta, etc.  # Stat bonuses
:classes, :races, :slots  # Restrictions
:reqlevel, :itemtype  # Requirements
```

### **Optional Fields (Consider)**
```elixir
# Advanced character features
:aa_points_spent, :tribute_points  # Advanced systems
:pvp_kills, :pvp_deaths  # PvP stats
:group_leadership_exp  # Leadership
:drakkin_heritage, :drakkin_tattoo  # Drakkin race

# Advanced item features
:focuseffect, :proceffect  # Item effects
:augslot1type, :augslot2type  # Augmentation
:heroic_str, :heroic_int  # Heroic stats
```

### **Irrelevant Fields (Skip)**
```elixir
# Legacy/unused fields
:unk012, :unk013, :unk054  # Unknown fields
:unk123, :unk124, :unk127  # Unknown fields
:serialized, :verified  # Internal tracking
:source, :created  # Development fields
```

## 🎯 **Recommended Approach**

### **1. Minimal Viable Import**
Start with essential tables only:
- ✅ **Accounts** (link to Phoenix users)
- ✅ **Characters** (basic character data)
- ✅ **Items** (essential items only, ~1000 items)
- ✅ **Zones** (major zones only)
- ✅ **Guilds** (basic guild system)

### **2. Incremental Expansion**
Add complexity gradually:
- 🔄 **Character Inventory** (equipped items)
- 🔄 **Character Skills** (skill levels)
- 🔄 **Character Spells** (known spells)
- 🔄 **Full Item Database** (all 100k+ items)

### **3. Advanced Features**
Implement later:
- 🔄 **AA System** (Alternate Advancement)
- 🔄 **Quest System** (tasks and progress)
- 🔄 **Pet System** (character pets)
- 🔄 **Tribute System** (tribute points)

## 🚀 **Next Steps**

### **Immediate Actions**
1. **Run Migration Setup**: `./setup_eqemu_migration.sh`
2. **Create Phoenix Schema**: `mix ecto.migrate`
3. **Test Small Import**: Import 100 characters first
4. **Validate Data**: Check GraphQL queries work
5. **Test UE5 Integration**: Verify game can load data

### **Performance Optimization**
1. **Batch Processing**: Import in chunks of 1000 records
2. **Index Creation**: Create indexes after import
3. **Data Cleanup**: Remove orphaned records
4. **Memory Management**: Monitor PostgreSQL memory usage

### **Integration Testing**
1. **GraphQL API**: Test all EQEmu queries
2. **Character Creation**: Create new characters
3. **Item Lookup**: Search and filter items
4. **Zone Loading**: Load zone data in UE5
5. **Real-time Updates**: Test live character updates

## ✅ **Success Criteria**

Your PEQ integration will be successful when:
- ✅ All essential character data imports correctly
- ✅ Items can be searched and equipped
- ✅ Zones load with proper safe points
- ✅ GraphQL API returns valid EQEmu data
- ✅ UE5 game can connect and load characters
- ✅ Real-time updates work through Phoenix LiveView

The PEQ database is incredibly comprehensive - you have access to 20+ years of EverQuest content and data. With proper migration, you'll have a complete MMO database powering your modern UE5 EverQuest experience!