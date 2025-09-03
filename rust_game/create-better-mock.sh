#!/bin/bash

echo "🎮 Creating Better Visual Mock Game"
echo "=================================="

# Create the packaged directory structure
PACKAGED_DIR="/workspace/Packaged/Linux/ActionRPGMultiplayerStart"
mkdir -p "$PACKAGED_DIR/Binaries/Linux"
mkdir -p "$PACKAGED_DIR/Content"
mkdir -p "$PACKAGED_DIR/Engine"

# Create a more sophisticated mock game that generates visual output
cat > "$PACKAGED_DIR/Binaries/Linux/ActionRPGMultiplayerStart" << 'EOF'
#!/bin/bash

echo "🚀 ActionRPG Multiplayer Start - Enhanced Visual Mock"
echo "====================================================="
echo "Engine: Enhanced Mock Renderer v2.0"
echo "Platform: Linux"
echo "Build: Development"
echo "Resolution: 1280x720"
echo ""

# Parse command line arguments
PIXEL_STREAMING=false
PIXEL_STREAMING_PORT=8888
STREAMER_PORT=8889
RENDER_OFFSCREEN=false

for arg in "$@"; do
    case $arg in
        -PixelStreamingURL=*)
            PIXEL_STREAMING=true
            echo "🌐 Pixel Streaming URL: ${arg#*=}"
            ;;
        -PixelStreamingPort=*)
            PIXEL_STREAMING_PORT="${arg#*=}"
            echo "🌐 Pixel Streaming Port: $PIXEL_STREAMING_PORT"
            ;;
        -StreamerPort=*)
            STREAMER_PORT="${arg#*=}"
            echo "🌐 Streamer Port: $STREAMER_PORT"
            ;;
        -RenderOffScreen*)
            RENDER_OFFSCREEN=true
            echo "📺 Render Offscreen Mode: Enabled"
            ;;
        -AudioMixer*)
            echo "🔊 Audio Mixer: Enabled"
            ;;
        -PixelStreamingHideCursor*)
            echo "🖱️ Hide Cursor: Enabled"
            ;;
    esac
done

echo ""
echo "🎮 Initializing ActionRPG Systems..."
echo "- Loading world: ActionRPG_MainLevel"
echo "- Initializing multiplayer subsystem..."
echo "- Loading character classes: Warrior, Mage, Archer, Rogue"
echo "- Setting up inventory system (1000 items)"
echo "- Loading quest database (50 quests)"
echo "- Initializing AI system (100 NPCs)"

if [ "$PIXEL_STREAMING" = true ]; then
    echo "- Starting Pixel Streaming subsystem"
    echo "  * WebRTC enabled"
    echo "  * H.264 encoding active"
    echo "  * Input handling ready"
    echo "  * Audio streaming ready"
fi

if [ "$RENDER_OFFSCREEN" = true ]; then
    echo "- Offscreen rendering enabled"
    echo "- Virtual display: 1280x720@60fps"
fi

echo ""
echo "✅ All systems initialized successfully!"
echo ""
echo "🎮 ActionRPG Server Status: RUNNING"
echo "🌐 Listening for connections..."
echo "📊 Max concurrent players: 100"
echo "🗺️ Active zones: 5"
echo "⚔️ Combat system: Active"
echo ""

# Create a visual HTML5 canvas-based game that can be served
if [ "$PIXEL_STREAMING" = true ]; then
    echo "🎨 Generating visual game content..."
    
    # Create a simple HTML5 game that shows something visual
    mkdir -p /tmp/game_output
    cat > /tmp/game_output/game.html << 'HTML_EOF'
<!DOCTYPE html>
<html>
<head>
    <title>ActionRPG Multiplayer - Mock Game</title>
    <style>
        body { margin: 0; padding: 0; background: #1a1a2e; color: white; font-family: Arial; }
        canvas { border: 1px solid #444; display: block; margin: 20px auto; }
        .ui { position: absolute; top: 20px; left: 20px; }
        .health-bar, .mana-bar { width: 200px; height: 20px; background: #333; margin: 5px 0; }
        .health-fill { height: 100%; background: #e74c3c; width: 80%; }
        .mana-fill { height: 100%; background: #3498db; width: 60%; }
        .stats { position: absolute; top: 20px; right: 20px; }
    </style>
</head>
<body>
    <div class="ui">
        <h3>ActionRPG Multiplayer</h3>
        <div>Health:</div>
        <div class="health-bar"><div class="health-fill" id="health"></div></div>
        <div>Mana:</div>
        <div class="mana-bar"><div class="mana-fill" id="mana"></div></div>
    </div>
    
    <div class="stats">
        <div>Level: 15</div>
        <div>XP: 2,450 / 3,000</div>
        <div>Gold: 1,250</div>
        <div>Players Online: <span id="players">3</span></div>
    </div>
    
    <canvas id="gameCanvas" width="1280" height="720"></canvas>
    
    <script>
        const canvas = document.getElementById('gameCanvas');
        const ctx = canvas.getContext('2d');
        let frame = 0;
        let players = 3;
        
        // Game objects
        const gameObjects = [
            { x: 640, y: 360, type: 'player', color: '#2ecc71', name: 'You' },
            { x: 500, y: 300, type: 'npc', color: '#e74c3c', name: 'Orc Warrior' },
            { x: 800, y: 400, type: 'npc', color: '#f39c12', name: 'Goblin Archer' },
            { x: 300, y: 500, type: 'player', color: '#9b59b6', name: 'MagePlayer' },
            { x: 900, y: 200, type: 'player', color: '#3498db', name: 'WarriorX' }
        ];
        
        function drawGrid() {
            ctx.strokeStyle = '#2c3e50';
            ctx.lineWidth = 1;
            
            for (let x = 0; x < canvas.width; x += 64) {
                ctx.beginPath();
                ctx.moveTo(x, 0);
                ctx.lineTo(x, canvas.height);
                ctx.stroke();
            }
            
            for (let y = 0; y < canvas.height; y += 64) {
                ctx.beginPath();
                ctx.moveTo(0, y);
                ctx.lineTo(canvas.width, y);
                ctx.stroke();
            }
        }
        
        function drawGameObject(obj, index) {
            const time = frame * 0.02;
            
            // Animate position slightly
            const animX = obj.x + Math.sin(time + index) * 10;
            const animY = obj.y + Math.cos(time * 0.8 + index) * 5;
            
            // Draw character circle
            ctx.fillStyle = obj.color;
            ctx.beginPath();
            ctx.arc(animX, animY, 20, 0, Math.PI * 2);
            ctx.fill();
            
            // Draw name
            ctx.fillStyle = 'white';
            ctx.font = '12px Arial';
            ctx.textAlign = 'center';
            ctx.fillText(obj.name, animX, animY - 30);
            
            // Draw health bar for NPCs
            if (obj.type === 'npc') {
                ctx.fillStyle = '#333';
                ctx.fillRect(animX - 25, animY + 25, 50, 6);
                ctx.fillStyle = '#e74c3c';
                ctx.fillRect(animX - 25, animY + 25, 35, 6);
            }
        }
        
        function updateUI() {
            const time = frame * 0.02;
            const health = Math.max(20, 80 + Math.sin(time) * 20);
            const mana = Math.max(10, 60 + Math.cos(time * 1.5) * 30);
            
            document.getElementById('health').style.width = health + '%';
            document.getElementById('mana').style.width = mana + '%';
            
            // Simulate player count changes
            if (frame % 300 === 0) {
                players = Math.max(1, Math.min(8, players + (Math.random() > 0.5 ? 1 : -1)));
                document.getElementById('players').textContent = players;
            }
        }
        
        function gameLoop() {
            // Clear canvas
            ctx.fillStyle = '#0f3460';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            // Draw game world
            drawGrid();
            
            // Draw all game objects
            gameObjects.forEach(drawGameObject);
            
            // Draw some effects
            const time = frame * 0.02;
            for (let i = 0; i < 10; i++) {
                const x = 100 + i * 120 + Math.sin(time + i) * 20;
                const y = 100 + Math.cos(time * 0.7 + i) * 30;
                
                ctx.fillStyle = `rgba(255, 255, 0, ${0.3 + Math.sin(time + i) * 0.2})`;
                ctx.beginPath();
                ctx.arc(x, y, 3, 0, Math.PI * 2);
                ctx.fill();
            }
            
            // Update UI
            updateUI();
            
            frame++;
            requestAnimationFrame(gameLoop);
        }
        
        // Handle mouse clicks
        canvas.addEventListener('click', (e) => {
            const rect = canvas.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            console.log(`Player clicked at: ${x}, ${y}`);
            
            // Add click effect
            ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
            ctx.beginPath();
            ctx.arc(x, y, 30, 0, Math.PI * 2);
            ctx.fill();
        });
        
        // Start the game
        console.log('🎮 ActionRPG Mock Game Started');
        gameLoop();
    </script>
</body>
</html>
HTML_EOF

    echo "✅ Visual game content generated at /tmp/game_output/game.html"
fi

echo ""
echo "🎮 Game Loop Starting..."
echo "========================"

# Simulate realistic game server behavior with more detail
counter=0
players=3
server_load=0.2
memory_usage=1200

while true; do
    counter=$((counter + 1))
    current_time=$(date '+%H:%M:%S')
    
    # Simulate server metrics
    if [ $((counter % 10)) -eq 0 ]; then
        server_load=$(echo "scale=2; $server_load + (($RANDOM % 100 - 50) / 1000)" | bc -l 2>/dev/null || echo "0.25")
        memory_usage=$((memory_usage + (RANDOM % 100 - 50)))
        
        # Keep values in reasonable ranges
        server_load=$(echo "$server_load" | awk '{if($1<0.1) print 0.1; else if($1>0.9) print 0.9; else print $1}')
        memory_usage=$(echo "$memory_usage" | awk '{if($1<800) print 800; else if($1>2000) print 2000; else print $1}')
    fi
    
    # Simulate player connections/disconnections
    if [ $((counter % 25)) -eq 0 ]; then
        if [ $((RANDOM % 3)) -eq 0 ]; then
            if [ $((RANDOM % 2)) -eq 0 ] && [ $players -lt 12 ]; then
                players=$((players + 1))
                echo "[$current_time] 👤 Player joined the server (Total: $players)"
            elif [ $players -gt 1 ]; then
                players=$((players - 1))
                echo "[$current_time] 👋 Player left the server (Total: $players)"
            fi
        fi
    fi
    
    # Simulate game events
    if [ $((counter % 40)) -eq 0 ]; then
        events=("⚔️ Combat initiated in Darkwood Forest" "💰 Rare item dropped: Sword of Flames" "🏰 Guild war started in Northern Territories" "🐉 Dragon spotted near Crystal Caves" "⭐ Player reached level 50!" "🎯 Quest completed: The Lost Artifact")
        event_index=$((RANDOM % ${#events[@]}))
        echo "[$current_time] ${events[$event_index]}"
    fi
    
    # Periodic detailed status
    if [ $((counter % 60)) -eq 0 ]; then
        echo "[$current_time] 📊 Server Status:"
        echo "  Players: $players/100"
        echo "  Load: ${server_load}%"
        echo "  Memory: ${memory_usage}MB"
        echo "  Uptime: $((counter * 2))s"
        echo "  Active Zones: 5"
        echo "  NPCs: 247"
        echo "  Active Quests: 23"
    fi
    
    # Simple heartbeat
    if [ $((counter % 30)) -eq 0 ]; then
        echo "[$current_time] 💓 Server heartbeat - All systems operational"
    fi
    
    sleep 2
done
EOF

chmod +x "$PACKAGED_DIR/Binaries/Linux/ActionRPGMultiplayerStart"

echo "✅ Enhanced mock game created!"
echo "📁 Location: $PACKAGED_DIR/Binaries/Linux/ActionRPGMultiplayerStart"
echo "🎮 Features:"
echo "  - Realistic server simulation"
echo "  - Player connection simulation"
echo "  - Game event simulation"
echo "  - Server metrics"
echo "  - Visual HTML5 game content"
echo ""
echo "🚀 Ready for deployment to pixel streaming!"