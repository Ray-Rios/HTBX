#!/bin/bash

# EQEmu PEQ Database Import Script
# This script provides an easy way to import PEQ database via docker-compose

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PEQ_FILE="eqemu/migrations/peq.sql"
BATCH_SIZE=1000
VALIDATE=true
PARSE_ONLY=false
VALIDATE_ONLY=false
TABLES=""
FORCE=false
VERBOSE=false

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    🎮 EQEmu PEQ Importer 🎮                  ║"
    echo "║                                                              ║"
    echo "║  Docker-Compose wrapper for PEQ database import             ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_help() {
    echo "EQEmu PEQ Database Import Script"
    echo ""
    echo "USAGE:"
    echo "    $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "    -f, --file FILE              PEQ SQL file path (default: eqemu/migrations/peq.sql)"
    echo "    -b, --batch-size SIZE        Import batch size (default: 1000)"
    echo "    --validate                   Validate import after completion (default: true)"
    echo "    --no-validate                Skip validation"
    echo "    --parse-only                 Only parse and generate migrations"
    echo "    --validate-only              Only validate existing import"
    echo "    --tables TABLES              Comma-separated list of tables to import"
    echo "    --force                      Continue despite validation errors"
    echo "    --verbose                    Enable verbose logging"
    echo "    -h, --help                   Show this help"
    echo ""
    echo "EXAMPLES:"
    echo "    # Parse PEQ file and generate migrations only"
    echo "    $0 --parse-only --file my_peq.sql"
    echo ""
    echo "    # Full import with custom batch size"
    echo "    $0 --file peq.sql --batch-size 500"
    echo ""
    echo "    # Import specific tables only"
    echo "    $0 --tables \"accounts,characters,items\""
    echo ""
    echo "    # Validate existing import"
    echo "    $0 --validate-only"
    echo ""
    echo "    # Force import ignoring validation errors"
    echo "    $0 --force --verbose"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--file)
            PEQ_FILE="$2"
            shift 2
            ;;
        -b|--batch-size)
            BATCH_SIZE="$2"
            shift 2
            ;;
        --validate)
            VALIDATE=true
            shift
            ;;
        --no-validate)
            VALIDATE=false
            shift
            ;;
        --parse-only)
            PARSE_ONLY=true
            shift
            ;;
        --validate-only)
            VALIDATE_ONLY=true
            shift
            ;;
        --tables)
            TABLES="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            print_help
            exit 1
            ;;
    esac
done

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    print_error "docker-compose is not installed or not in PATH"
    exit 1
fi

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml not found in current directory"
    exit 1
fi

print_banner

print_info "Configuration:"
print_info "  📁 PEQ File: $PEQ_FILE"
print_info "  📦 Batch Size: $BATCH_SIZE"
print_info "  🔍 Validate: $VALIDATE"
print_info "  📋 Parse Only: $PARSE_ONLY"
print_info "  ✅ Validate Only: $VALIDATE_ONLY"
if [ -n "$TABLES" ]; then
    print_info "  📊 Tables: $TABLES"
fi
print_info "  💪 Force: $FORCE"
print_info "  🔊 Verbose: $VERBOSE"
echo ""

# Check if PEQ file exists (if not parse-only or validate-only)
if [ "$PARSE_ONLY" = false ] && [ "$VALIDATE_ONLY" = false ]; then
    if [ ! -f "$PEQ_FILE" ]; then
        print_error "PEQ file not found: $PEQ_FILE"
        print_info "Please ensure your PEQ SQL file is available at the specified path"
        exit 1
    fi
    
    # Get file size for info
    FILE_SIZE=$(du -h "$PEQ_FILE" | cut -f1)
    print_info "PEQ file size: $FILE_SIZE"
fi

# Build the mix command
MIX_ARGS="eqemu.peq.import"

if [ -n "$PEQ_FILE" ]; then
    MIX_ARGS="$MIX_ARGS --file $PEQ_FILE"
fi

if [ -n "$BATCH_SIZE" ]; then
    MIX_ARGS="$MIX_ARGS --batch-size $BATCH_SIZE"
fi

if [ "$VALIDATE" = true ]; then
    MIX_ARGS="$MIX_ARGS --validate"
fi

if [ "$PARSE_ONLY" = true ]; then
    MIX_ARGS="$MIX_ARGS --parse-only"
fi

if [ "$VALIDATE_ONLY" = true ]; then
    MIX_ARGS="$MIX_ARGS --validate-only"
fi

if [ -n "$TABLES" ]; then
    MIX_ARGS="$MIX_ARGS --tables $TABLES"
fi

if [ "$FORCE" = true ]; then
    MIX_ARGS="$MIX_ARGS --force"
fi

if [ "$VERBOSE" = true ]; then
    MIX_ARGS="$MIX_ARGS --verbose"
fi

print_info "Starting PEQ import process..."
print_info "Command: mix $MIX_ARGS"
echo ""

# Ensure database is running
print_info "Ensuring database service is running..."
docker-compose up -d db

# Wait for database to be ready
print_info "Waiting for database to be ready..."
sleep 5

# Check database health
if docker-compose exec db cockroach sql --insecure --host=localhost -e 'SELECT 1;' > /dev/null 2>&1; then
    print_success "Database is ready"
else
    print_error "Database is not responding"
    print_info "Trying to start database service..."
    docker-compose restart db
    sleep 10
    
    if docker-compose exec db cockroach sql --insecure --host=localhost -e 'SELECT 1;' > /dev/null 2>&1; then
        print_success "Database is now ready"
    else
        print_error "Failed to connect to database"
        exit 1
    fi
fi

# Run the import command in the web container
print_info "Running PEQ import in Phoenix container..."
echo ""

if docker-compose exec web mix $MIX_ARGS; then
    print_success "PEQ import completed successfully!"
    echo ""
    print_info "Next steps:"
    print_info "1. Start Phoenix server: docker-compose up web"
    print_info "2. Visit admin panel: http://localhost:4000/eqemu/admin"
    print_info "3. Test GraphQL API: http://localhost:4000/api/graphql"
    print_info "4. Configure EQEmu C++ server integration"
    echo ""
else
    print_error "PEQ import failed!"
    echo ""
    print_info "Troubleshooting:"
    print_info "1. Check the logs above for specific error messages"
    print_info "2. Verify your PEQ SQL file is valid"
    print_info "3. Ensure database has enough disk space"
    print_info "4. Try with --verbose flag for more details"
    print_info "5. Use --parse-only to test parsing without import"
    echo ""
    exit 1
fi

print_success "🎮 EQEmu PEQ Import Script completed! 🎮"