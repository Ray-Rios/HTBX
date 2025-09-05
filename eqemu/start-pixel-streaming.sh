#!/bin/bash

# EQEmu Pixel Streaming Startup Script
echo "🎮 Starting EQEmu Pixel Streaming Server..."

# Set environment variables
export DISPLAY=${DISPLAY:-:99}
export PIXEL_STREAMING_PORT=${PIXEL_STREAMING_PORT:-8888}
export WEB_PORT=${WEB_PORT:-9070}
export GAME_EXECUTABLE=${GAME_EXECUTABLE:-/app/game/eqemuue5.sh}

# Create necessary directories
mkdir -p /app/logs
mkdir -p /app/game
mkdir -p /tmp/.X11-unix

# Start virtual display server
echo "🖥️  Starting virtual display server..."
Xvfb $DISPLAY -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &
XVFB_PID=$!

# Wait for display to be ready
sleep 3

# Start window manager
echo "🪟 Starting window manager..."
DISPLAY=$DISPLAY fluxbox &
FLUXBOX_PID=$!

# Wait for window manager
sleep 2

# Start audio system
echo "🔊 Starting audio system..."
pulseaudio --start --log-target=syslog &

# Check if UE5 game executable exists
if [ -f "$GAME_EXECUTABLE" ]; then
    echo "🎮 Found UE5 game executable: $GAME_EXECUTABLE"
    echo "🎮 Game will be started on demand by pixel streaming server"
else
    echo "⚠️  UE5 game executable not found: $GAME_EXECUTABLE"
    echo "🔧 Creating mock game executable for development..."
    
    # Create mock game executable
    cat > /app/game/eqemuue5.sh << 'EOF'
#!/bin/bash
echo "🎭 Mock EQEmu UE5 Game Starting..."
echo "🎮 This is a development placeholder"
echo "🔧 Replace with actual UE5 packaged game"

# Simulate game running
while true; do
    echo "🎮 Mock game tick: $(date)"
    sleep 10
done
EOF
    chmod +x /app/game/eqemuue5.sh
fi

# Start the pixel streaming server
echo "🚀 Starting pixel streaming server..."
cd /app
node pixel-streaming-server.js &
SERVER_PID=$!

# Function to handle shutdown
cleanup() {
    echo "🛑 Shutting down EQEmu Pixel Streaming Server..."
    
    # Kill processes
    [ ! -z "$SERVER_PID" ] && kill $SERVER_PID 2>/dev/null
    [ ! -z "$FLUXBOX_PID" ] && kill $FLUXBOX_PID 2>/dev/null
    [ ! -z "$XVFB_PID" ] && kill $XVFB_PID 2>/dev/null
    
    # Stop audio
    pulseaudio --kill 2>/dev/null
    
    echo "✅ Cleanup complete"
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Wait for the server process
wait $SERVER_PID

# If we get here, the server has stopped
echo "❌ Pixel streaming server has stopped"
cleanup