#!/bin/bash
set -e

# ----------------------------
# Environment variables are loaded by docker-compose
# ----------------------------
echo "Current MIX_ENV: $MIX_ENV"
echo "DATABASE_URL: ${DATABASE_URL:0:30}..."

# ----------------------------
# Generate secrets (dev only)
# ----------------------------
if [ "$MIX_ENV" = "dev" ]; then
  if [ -z "$SECRET_KEY_BASE" ] || [[ "$SECRET_KEY_BASE" == GENERATE_WITH_mix_phx.gen.secret* ]]; then
    echo "Generating SECRET_KEY_BASE for dev..."
    export SECRET_KEY_BASE=$(mix phx.gen.secret 64)
  fi

  if [ -z "$LIVE_VIEW_SIGNING_SALT" ] || [[ "$LIVE_VIEW_SIGNING_SALT" == GENERATE_WITH_mix_phx.gen.secret* ]]; then
    echo "Generating LIVE_VIEW_SIGNING_SALT for dev..."
    export LIVE_VIEW_SIGNING_SALT=$(mix phx.gen.secret 32)
  fi
  
  if [ -z "$GUARDIAN_SECRET_KEY" ] || [ "$GUARDIAN_SECRET_KEY" == "GENERATE_WITH_mix_guardian.gen.secret" ]; then
    echo "Generating GUARDIAN_SECRET_KEY for dev..."
    export GUARDIAN_SECRET_KEY=$(mix guardian.gen.secret)
  fi
else
  # ----------------------------
  # Fail fast in prod if secrets are missing
  # ----------------------------
  if [ -z "$SECRET_KEY_BASE" ]; then
    echo "❌ ERROR: SECRET_KEY_BASE is not set in prod!"
    exit 1
  fi
  if [ -z "$LIVE_VIEW_SIGNING_SALT" ]; then
    echo "❌ ERROR: LIVE_VIEW_SIGNING_SALT is not set in prod!"
    exit 1
  fi
  if [ -z "$DATABASE_URL" ]; then
    echo "❌ ERROR: DATABASE_URL is not set in prod!"
    exit 1
  fi
fi

echo "SECRET_KEY_BASE: ${SECRET_KEY_BASE:0:8}..."
echo "LIVE_VIEW_SIGNING_SALT: ${LIVE_VIEW_SIGNING_SALT:0:8}..."

# ----------------------------
# Wait for database
# ----------------------------
echo "Waiting for PostgreSQL to be ready..."
until pg_isready -h db -p 5432 -U postgres &> /dev/null; do
  echo "Waiting for database..."
  sleep 2
done
echo "PostgreSQL is ready!"

# ----------------------------
# Create database using Ecto
# ----------------------------
echo "Creating database..."
mix ecto.create --quiet || echo "Database already exists or creation failed, continuing..."

# ----------------------------
# Run Ecto migrations with retry
# ----------------------------
echo "Running migrations..."
for i in {1..3}; do
  if mix ecto.migrate; then
    echo "Migrations completed successfully"
    break
  else
    echo "Migration attempt $i failed, retrying in 5 seconds..."
    sleep 5
  fi
done

# ----------------------------
# Wait for Redis
# ----------------------------
echo "Waiting for Redis to be ready..."
until redis-cli -h redis ping | grep -q PONG; do
  sleep 1
done
echo "Redis is ready!"

# ----------------------------
# Start Phoenix server
# ----------------------------
echo "Starting Phoenix server..."
exec mix phx.server