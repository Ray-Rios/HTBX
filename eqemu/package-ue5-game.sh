#!/bin/bash
# Fixed UE5 Packaging Script - Handles Fab plugin and headless packaging issues

set -e

echo "🎮 Fixed UE5 Packaging Script"
echo "============================="

# Configuration
PROJECT_NAME="ActionRPGMultiplayerStart"
PROJECT_FILE="$(pwd)/${PROJECT_NAME}.uproject"
OUTPUT_DIR="$(pwd)/Packaged"

# Find UE5 installation
UE_VERSIONS_DIR="/c/Program Files/Epic Games"
UE_EDITOR=""

echo "🔍 Looking for UE5 installation..."

if [[ -d "$UE_VERSIONS_DIR" ]]; then
    # Find UE5 installations
    UE_DIRS=$(find "$UE_VERSIONS_DIR" -maxdepth 1 -name "UE_*" -type d 2>/dev/null | sort -V)
    
    for UE_DIR in $UE_DIRS; do
        POTENTIAL_EDITOR="$UE_DIR/Engine/Binaries/Win64/UnrealEditor-Cmd.exe"
        if [[ -f "$POTENTIAL_EDITOR" ]]; then
            UE_EDITOR="$POTENTIAL_EDITOR"
            echo "✅ Found UE5 at: $UE_EDITOR"
            break
        fi
    done
fi

if [[ -z "$UE_EDITOR" ]] || [[ ! -f "$UE_EDITOR" ]]; then
    echo "❌ UE5 not found!"
    echo "Please install UE5 from Epic Games Launcher"
    echo "Expected location: $UE_VERSIONS_DIR/UE_5.4/Engine/Binaries/Win64/UnrealEditor-Cmd.exe"
    exit 1
fi

# Check project file
if [[ ! -f "$PROJECT_FILE" ]]; then
    echo "❌ Project file not found: $PROJECT_FILE"
    echo "Current directory: $(pwd)"
    echo "Available files:"
    ls -la *.uproject 2>/dev/null || echo "No .uproject files found"
    exit 1
fi

echo "✅ Project file: $PROJECT_FILE"

# Create output directory
mkdir -p "$OUTPUT_DIR"
echo "📁 Output directory: $OUTPUT_DIR"

# Packaging arguments - optimized to avoid Fab plugin issues
PACKAGE_ARGS=(
    "$PROJECT_FILE"
    "-run=Cook"
    "-targetplatform=Win64"
    "-clientconfig=Shipping"
    "-serverconfig=Shipping"
    "-nocompile"
    "-nocompileeditor"
    "-installed"
    "-nop4"
    "-project=$PROJECT_FILE"
    "-cook"
    "-stage"
    "-archive"
    "-archivedirectory=$OUTPUT_DIR"
    "-package"
    "-ue4exe=UnrealEditor-Cmd.exe"
    "-pak"
    "-prereqs"
    "-nodebuginfo"
    "-targetconfig=Shipping"
    "-utf8output"
    "-unattended"
    "-stdout"
    "-CrashForUAT"
    "-unversioned"
    "-compressed"
)

echo "🔨 Starting packaging process..."
echo "📋 Command: $UE_EDITOR ${PACKAGE_ARGS[*]}"

# Set environment to avoid UI issues
export UE_LOG_VERBOSITY=Error
export UE_DISABLE_PLUGINS="Fab"

# Run packaging
if "$UE_EDITOR" "${PACKAGE_ARGS[@]}"; then
    echo "✅ Packaging completed successfully!"
    
    # Check output
    if [[ -d "$OUTPUT_DIR/Windows" ]]; then
        echo "📁 Packaged game location: $OUTPUT_DIR/Windows"
        echo "📋 Contents:"
        ls -la "$OUTPUT_DIR/Windows"
        
        # Find and make executable
        GAME_EXE=$(find "$OUTPUT_DIR/Windows" -name "${PROJECT_NAME}.exe" -type f | head -1)
        if [[ -f "$GAME_EXE" ]]; then
            echo "🎮 Game executable: $GAME_EXE"
            echo "✅ Packaging successful!"
            
            # Create launch script
            cat > "$OUTPUT_DIR/Windows/launch-game.bat" << 'EOF'
@echo off
echo Starting ActionRPG Multiplayer Game...
echo.
echo Game Controls:
echo - WASD: Move
echo - Mouse: Look around
echo - Left Click: Attack
echo - Space: Jump
echo.
echo Starting game...
ActionRPGMultiplayerStart.exe
pause
EOF
            
            echo "🚀 Created launch script: $OUTPUT_DIR/Windows/launch-game.bat"
        else
            echo "⚠️ Game executable not found, but packaging completed"
        fi
    else
        echo "⚠️ Windows output directory not found"
        echo "Available output:"
        ls -la "$OUTPUT_DIR"
    fi
    
else
    RESULT=$?
    echo "❌ Packaging failed with exit code: $RESULT"
    
    # Show helpful error information
    echo ""
    echo "🔍 Troubleshooting:"
    echo "1. Check UE5 installation: $UE_EDITOR"
    echo "2. Verify project opens in UE5 Editor"
    echo "3. Try packaging manually in UE5 Editor:"
    echo "   File → Package Project → Windows (64-bit)"
    echo "4. Check full log at: C:\\Users\\error\\AppData\\Roaming\\Unreal Engine\\AutomationTool\\Logs"
    
    exit $RESULT
fi

echo "🎉 Packaging script completed!"