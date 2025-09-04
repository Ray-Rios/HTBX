@echo off
REM Project Cleanup Script - Uses Docker Compose for proper containerized cleanup
REM This script should be used instead of direct file system operations

echo 🧹 Starting project cleanup via Docker Compose...

REM Clean Docker build cache
echo 🐳 Cleaning Docker build cache...
docker system prune -f

REM Clean unused Docker volumes (be careful with this)
echo 📦 Cleaning unused Docker volumes...
docker volume prune -f

REM Clean temporary files via game service container
echo 🗑️ Cleaning temporary files...
docker-compose run --rm game_service bash -c "find /app -name '*.tmp' -delete 2>/dev/null || true && find /app -name '*.log' -delete 2>/dev/null || true && find /app -name '*.bak' -delete 2>/dev/null || true && echo '✅ Temporary files cleaned'"

echo 📋 To run specific cleanups:
echo    docker system prune -f
#echo    docker-compose run --rm web bash -c "rm -rf /app/rust_game/Build/"
#echo    docker-compose run --rm game_service bash -c "cargo clean"

echo ✅ Project cleanup completed!
echo.

REM Show disk usage after cleanup
echo 💾 Disk usage after cleanup:
docker-compose run --rm web bash -c "du -sh /app/* 2>/dev/null | sort -hr | head -10"

pause