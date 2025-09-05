#!/bin/bash

# Migration Cleanup Script
# Removes redundant game-related migrations and keeps only essential ones

echo "🧹 Cleaning up redundant migrations..."

# Keep these essential migrations (don't delete)
KEEP_MIGRATIONS=(
    "20240101000001_create_users.exs"
    "20240101000002_add_user_enhancements.exs"
    "20240101000003_create_commerce_tables.exs"
    "20240101000004_create_content_tables.exs"
    "20240101000005_create_files_tables.exs"
    "20240101000006_create_chat_tables.exs"
    "20240101000007_add_user_status_and_avatar.exs"
    "20240101000009_create_users_tokens.exs"
    "20250831015222_add_missing_product_fields.exs"
    "20250831025652_add_position_to_chat_channels.exs"
    "20250831031136_add_thread_id_to_chat_messages.exs"
    "20250903100000_consolidated_schema.exs"
)

# Remove these redundant game migrations
REMOVE_MIGRATIONS=(
    "20250831154343_create_game_tables.exs"
    "20250901000001_create_cms_users.exs"
    "20250901000002_create_cms_posts.exs"
    "20250901000003_create_cms_user_meta.exs"
    "20250901000004_create_cms_taxonomies.exs"
    "20250901000005_create_cms_terms.exs"
    "20250901000006_create_cms_term_meta.exs"
    "20250901000007_create_cms_post_term_relationships.exs"
    "20250901000008_create_cms_comments.exs"
    "20250901000009_create_cms_comment_meta.exs"
    "20250901000010_create_cms_options.exs"
    "20250901000011_create_cms_post_meta.exs"
    "20250902091000_add_missing_game_cms_tables.exs"
    "20250902092000_create_all_game_cms_tables.exs"
    "20250903000001_create_eqemu_schema.exs"
    "20250903000002_create_simple_eqemu_schema.exs"
)

# Create backup directory
BACKUP_DIR="priv/repo/migrations_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📦 Creating backup in $BACKUP_DIR"

# Move redundant migrations to backup
for migration in "${REMOVE_MIGRATIONS[@]}"; do
    if [ -f "priv/repo/migrations/$migration" ]; then
        echo "🗂️  Backing up: $migration"
        mv "priv/repo/migrations/$migration" "$BACKUP_DIR/"
    else
        echo "⚠️  Not found: $migration"
    fi
done

echo ""
echo "✅ Migration cleanup complete!"
echo ""
echo "📋 Remaining migrations:"
ls -la priv/repo/migrations/

echo ""
echo "📦 Backed up migrations in: $BACKUP_DIR"
echo ""
echo "🔄 Next steps:"
echo "  1. Reset your database: mix ecto.reset"
echo "  2. Run migrations: mix ecto.migrate"
echo "  3. Test your GraphQL API"
echo ""
echo "⚠️  If you need to restore any migrations, they're in the backup directory."