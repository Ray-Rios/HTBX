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
