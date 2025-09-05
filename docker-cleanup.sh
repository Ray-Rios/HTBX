#!/bin/bash

# Project Cleanup Script - Uses Docker Compose for proper containerized cleanup
# This script should be used instead of direct file system operations

echo "🧹 Starting project cleanup via Docker Compose..."

# Clean Docker build cache
echo "🐳 Cleaning Docker build cache..."
docker system prune -f

# Clean unused Docker volumes (be careful with this)
echo "📦 Cleaning unused Docker volumes..."
docker volume prune -f


# Show disk usage after cleanup
echo "💾 Disk usage after cleanup:"
docker-compose run --rm web bash -c "du -sh /app/* 2>/dev/null | sort -hr | head -10"

echo "✅ Project cleanup completed!"
echo ""


# Clean UE5 build artifacts via web container
#echo "🎮 Cleaning UE5 build directories..."
#docker-compose run --rm web bash -c "
#    cd /app && 
#    rm -rf eqemu/Build/ eqemu/GameBuild/ eqemu/Packaged/ eqemu/DerivedDataCache/ eqemu/Intermediate/ eqemu/Saved/ 2>/dev/null || true &&
#    echo '✅ UE5 build directories cleaned'
#"