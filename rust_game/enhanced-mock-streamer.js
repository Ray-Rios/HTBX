#!/usr/bin/env node

// Enhanced Mock UE5 Game Streamer with Visual Output
const WebSocket = require('ws');
const http = require('http');
const fs = require('fs');

console.log('🚀 Enhanced ActionRPG Mock Streamer Starting...');
console.log('Engine: Enhanced Mock Renderer v2.0');
console.log('Platform: Linux');
console.log('Build: Development');
console.log('Resolution: 1280x720');
console.log('');

// Parse command line arguments
let pixelStreamingURL = 'ws://localhost:9070';
let renderOffscreen = false;

process.argv.forEach(arg => {
    if (arg.startsWith('-PixelStreamingURL=')) {
        pixelStreamingURL = arg.split('=')[1];
        console.log('🌐 Pixel Streaming URL:', pixelStreamingURL);
    }
    if (arg.includes('-RenderOffScreen')) {
        renderOffscreen = true;
        console.log('📺 Render Offscreen Mode: Enabled');
    }
});

console.log('');
console.log('🎮 Initializing ActionRPG Systems...');
console.log('- Loading world: ActionRPG_MainLevel');
console.log('- Initializing multiplayer subsystem...');
console.log('- Loading character classes: Warrior, Mage, Archer, Rogue');
console.log('- Setting up inventory system (1000 items)');
console.log('- Loading quest database (50 quests)');
console.log('- Initializing AI system (100 NPCs)');
console.log('- Starting Pixel Streaming subsystem');
console.log('  * WebRTC enabled');
console.log('  * H.264 encoding active');
console.log('  * Input handling ready');
console.log('  * Audio streaming ready');

if (renderOffscreen) {
    console.log('- Offscreen rendering enabled');
    console.log('- Virtual display: 1280x720@60fps');
}

console.log('');
console.log('✅ All systems initialized successfully!');
console.log('');
console.log('🎮 ActionRPG Server Status: RUNNING');
console.log('🌐 Listening for connections...');
console.log('📊 Max concurrent players: 100');
console.log('🗺️ Active zones: 5');
console.log('⚔️ Combat system: Active');
console.log('');

// Game state
let gameState = {
    players: 0,
    serverLoad: 0.2,
    memoryUsage: 1200,
    tick: 0,
    isStreaming: false,
    phoenixApiBase: 'http://localhost:4000/api/pixel-streaming'
};

// Connect to pixel streaming signaling server
let ws = null;
let reconnectInterval = null;

function connectToSignalingServer() {
    console.log('🔌 Connecting to signaling server:', pixelStreamingURL);
    
    try {
        ws = new WebSocket(pixelStreamingURL);
        
        ws.on('open', () => {
            console.log('✅ Connected to pixel streaming signaling server');
            gameState.isStreaming = true;
            
            // Send streamer identification
            ws.send(JSON.stringify({
                type: 'streamer',
                id: 'ActionRPGMultiplayerStart',
                resolution: '1280x720',
                fps: 60
            }));
            
            console.log('📡 Streamer registration sent');
            console.log('🎥 Mock video stream active');
            
            // Clear reconnect interval if connected
            if (reconnectInterval) {
                clearInterval(reconnectInterval);
                reconnectInterval = null;
            }
        });
        
        ws.on('message', (data) => {
            try {
                const message = JSON.parse(data);
                handleSignalingMessage(message);
            } catch (e) {
                console.log('📨 Received raw message:', data.toString());
            }
        });
        
        ws.on('close', () => {
            console.log('❌ Disconnected from signaling server');
            gameState.isStreaming = false;
            ws = null;
            
            // Try to reconnect
            if (!reconnectInterval) {
                reconnectInterval = setInterval(() => {
                    console.log('🔄 Attempting to reconnect...');
                    connectToSignalingServer();
                }, 5000);
            }
        });
        
        ws.on('error', (error) => {
            console.log('❌ WebSocket error:', error.message);
        });
        
    } catch (error) {
        console.log('❌ Failed to connect:', error.message);
        
        // Try to reconnect
        if (!reconnectInterval) {
            reconnectInterval = setInterval(() => {
                console.log('🔄 Attempting to reconnect...');
                connectToSignalingServer();
            }, 5000);
        }
    }
}

function handleSignalingMessage(message) {
    switch (message.type) {
        case 'viewer_connected':
            console.log('👤 Viewer connected to stream');
            break;
        case 'viewer_disconnected':
            console.log('👋 Viewer disconnected from stream');
            break;
        case 'input':
            handleGameInput(message);
            break;
        default:
            console.log('📨 Signaling message:', message.type);
    }
}

function handleGameInput(input) {
    if (input.mouse) {
        console.log(`🖱️ Mouse input: ${input.mouse.x}, ${input.mouse.y}`);
    }
    if (input.keyboard) {
        console.log(`⌨️ Keyboard input: ${input.keyboard.key}`);
    }
}

// Fetch real game data from Phoenix API
async function fetchGameData() {
    try {
        const response = await fetch(`${gameState.phoenixApiBase}/game-data`);
        if (response.ok) {
            return await response.json();
        }
    } catch (error) {
        console.log('📡 Could not fetch game data from Phoenix API, using mock data');
    }
    return null;
}

async function fetchPlayerData() {
    try {
        const response = await fetch(`${gameState.phoenixApiBase}/players`);
        if (response.ok) {
            return await response.json();
        }
    } catch (error) {
        console.log('📡 Could not fetch player data from Phoenix API');
    }
    return null;
}

// Generate visual game content
async function generateVisualContent() {
    console.log('🎨 Generating visual game content...');
    
    // Try to get real game data
    const gameData = await fetchGameData();
    const playerData = await fetchPlayerData();
    
    const gameHTML = `<!DOCTYPE html>
<html>
<head>
    <title>ActionRPG Multiplayer - Enhanced Mock</title>
    <style>
        body { margin: 0; padding: 0; background: #0f1419; color: white; font-family: 'Segoe UI', Arial; overflow: hidden; }
        canvas { display: block; margin: 0 auto; background: #1a1a2e; }
        .ui { position: absolute; top: 20px; left: 20px; z-index: 100; }
        .health-bar, .mana-bar { width: 200px; height: 20px; background: #333; margin: 5px 0; border-radius: 10px; overflow: hidden; }
        .health-fill { height: 100%; background: linear-gradient(90deg, #e74c3c, #c0392b); width: 80%; transition: width 0.3s; }
        .mana-fill { height: 100%; background: linear-gradient(90deg, #3498db, #2980b9); width: 60%; transition: width 0.3s; }
        .stats { position: absolute; top: 20px; right: 20px; text-align: right; }
        .minimap { position: absolute; bottom: 20px; right: 20px; width: 200px; height: 150px; background: rgba(0,0,0,0.7); border: 2px solid #444; border-radius: 5px; }
        .chat { position: absolute; bottom: 20px; left: 20px; width: 300px; height: 150px; background: rgba(0,0,0,0.7); border: 2px solid #444; border-radius: 5px; padding: 10px; overflow-y: auto; }
        .status { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center; font-size: 24px; color: #2ecc71; }
    </style>
</head>
<body>
    <div class="ui">
        <h3 style="margin: 0 0 10px 0; color: #2ecc71;">ActionRPG Multiplayer</h3>
        <div style="font-size: 12px; margin-bottom: 5px;">Health:</div>
        <div class="health-bar"><div class="health-fill" id="health"></div></div>
        <div style="font-size: 12px; margin-bottom: 5px;">Mana:</div>
        <div class="mana-bar"><div class="mana-fill" id="mana"></div></div>
    </div>
    
    <div class="stats">
        <div><strong>Level:</strong> 15</div>
        <div><strong>XP:</strong> 2,450 / 3,000</div>
        <div><strong>Gold:</strong> 1,250</div>
        <div><strong>Players Online:</strong> <span id="players">3</span></div>
        <div><strong>Server:</strong> <span id="server-status">Active</span></div>
    </div>
    
    <div class="minimap">
        <div style="padding: 5px; font-size: 12px; border-bottom: 1px solid #444;">Minimap</div>
        <canvas id="minimap" width="196" height="120"></canvas>
    </div>
    
    <div class="chat">
        <div style="font-size: 12px; border-bottom: 1px solid #444; padding-bottom: 5px; margin-bottom: 5px;">Chat</div>
        <div id="chat-content" style="font-size: 11px; line-height: 1.4;"></div>
    </div>
    
    <canvas id="gameCanvas" width="1280" height="720"></canvas>
    
    <div class="status" id="connection-status">
        🎮 ActionRPG Server Connected<br>
        <div style="font-size: 16px; margin-top: 10px;">Enhanced Mock Renderer Active</div>
    </div>
    
    <script>
        const canvas = document.getElementById('gameCanvas');
        const ctx = canvas.getContext('2d');
        const minimap = document.getElementById('minimap');
        const minimapCtx = minimap.getContext('2d');
        
        let frame = 0;
        let players = 3;
        let chatMessages = [
            '[System] Welcome to ActionRPG Multiplayer!',
            '[Player1] Anyone want to raid the dragon cave?',
            '[Player2] I need help with the crystal quest',
            '[System] Server performance: Excellent'
        ];
        
        // Game objects with more variety
        const gameObjects = [
            { x: 640, y: 360, type: 'player', color: '#2ecc71', name: 'You', class: 'Warrior' },
            { x: 500, y: 300, type: 'npc', color: '#e74c3c', name: 'Orc Warrior', hp: 0.8 },
            { x: 800, y: 400, type: 'npc', color: '#f39c12', name: 'Goblin Archer', hp: 0.6 },
            { x: 300, y: 500, type: 'player', color: '#9b59b6', name: 'MagePlayer', class: 'Mage' },
            { x: 900, y: 200, type: 'player', color: '#3498db', name: 'WarriorX', class: 'Warrior' },
            { x: 200, y: 600, type: 'npc', color: '#e67e22', name: 'Fire Elemental', hp: 0.9 },
            { x: 1000, y: 500, type: 'treasure', color: '#f1c40f', name: 'Treasure Chest' }
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
            
            // Animate position
            const animX = obj.x + Math.sin(time + index) * 10;
            const animY = obj.y + Math.cos(time * 0.8 + index) * 5;
            
            // Draw character/object
            ctx.fillStyle = obj.color;
            ctx.beginPath();
            
            if (obj.type === 'treasure') {
                // Draw treasure as diamond
                ctx.save();
                ctx.translate(animX, animY);
                ctx.rotate(time + index);
                ctx.fillRect(-15, -15, 30, 30);
                ctx.restore();
            } else {
                // Draw as circle
                ctx.arc(animX, animY, obj.type === 'player' ? 25 : 20, 0, Math.PI * 2);
                ctx.fill();
            }
            
            // Draw name
            ctx.fillStyle = 'white';
            ctx.font = '12px Arial';
            ctx.textAlign = 'center';
            ctx.fillText(obj.name, animX, animY - 35);
            
            // Draw class for players
            if (obj.class) {
                ctx.font = '10px Arial';
                ctx.fillStyle = '#bdc3c7';
                ctx.fillText(obj.class, animX, animY - 45);
            }
            
            // Draw health bar for NPCs
            if (obj.type === 'npc' && obj.hp !== undefined) {
                const barWidth = 40;
                const barHeight = 6;
                
                ctx.fillStyle = '#333';
                ctx.fillRect(animX - barWidth/2, animY + 30, barWidth, barHeight);
                ctx.fillStyle = obj.hp > 0.5 ? '#2ecc71' : obj.hp > 0.2 ? '#f39c12' : '#e74c3c';
                ctx.fillRect(animX - barWidth/2, animY + 30, barWidth * obj.hp, barHeight);
            }
        }
        
        function drawMinimap() {
            minimapCtx.fillStyle = '#0f3460';
            minimapCtx.fillRect(0, 0, minimap.width, minimap.height);
            
            // Draw objects on minimap
            gameObjects.forEach((obj, index) => {
                const mapX = (obj.x / canvas.width) * minimap.width;
                const mapY = (obj.y / canvas.height) * minimap.height;
                
                minimapCtx.fillStyle = obj.color;
                minimapCtx.beginPath();
                minimapCtx.arc(mapX, mapY, obj.type === 'player' ? 4 : 3, 0, Math.PI * 2);
                minimapCtx.fill();
            });
        }
        
        function updateUI() {
            const time = frame * 0.02;
            const health = Math.max(20, 80 + Math.sin(time) * 20);
            const mana = Math.max(10, 60 + Math.cos(time * 1.5) * 30);
            
            document.getElementById('health').style.width = health + '%';
            document.getElementById('mana').style.width = mana + '%';
            
            // Simulate player count changes
            if (frame % 300 === 0) {
                players = Math.max(1, Math.min(12, players + (Math.random() > 0.5 ? 1 : -1)));
                document.getElementById('players').textContent = players;
            }
            
            // Update chat occasionally
            if (frame % 600 === 0) {
                const newMessages = [
                    '[Player3] Great teamwork everyone!',
                    '[System] New quest available: Ancient Ruins',
                    '[Player4] Trading rare items at the market',
                    '[System] Server uptime: ' + Math.floor(frame / 60) + ' minutes'
                ];
                chatMessages.push(newMessages[Math.floor(Math.random() * newMessages.length)]);
                if (chatMessages.length > 8) chatMessages.shift();
                
                document.getElementById('chat-content').innerHTML = chatMessages.join('<br>');
            }
        }
        
        function drawEffects() {
            const time = frame * 0.02;
            
            // Floating particles
            for (let i = 0; i < 15; i++) {
                const x = 100 + i * 80 + Math.sin(time + i) * 30;
                const y = 100 + Math.cos(time * 0.7 + i) * 40;
                const alpha = 0.3 + Math.sin(time + i) * 0.2;
                
                ctx.fillStyle = \`rgba(255, 255, 100, \${alpha})\`;
                ctx.beginPath();
                ctx.arc(x, y, 2 + Math.sin(time + i) * 2, 0, Math.PI * 2);
                ctx.fill();
            }
            
            // Magic circles around players
            gameObjects.filter(obj => obj.type === 'player').forEach((player, index) => {
                const time = frame * 0.02;
                const animX = player.x + Math.sin(time + index) * 10;
                const animY = player.y + Math.cos(time * 0.8 + index) * 5;
                
                ctx.strokeStyle = \`rgba(52, 152, 219, \${0.5 + Math.sin(time * 2 + index) * 0.3})\`;
                ctx.lineWidth = 2;
                ctx.beginPath();
                ctx.arc(animX, animY, 40 + Math.sin(time * 3 + index) * 5, 0, Math.PI * 2);
                ctx.stroke();
            });
        }
        
        function gameLoop() {
            // Clear canvas
            ctx.fillStyle = '#0f3460';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            // Draw game world
            drawGrid();
            drawEffects();
            
            // Draw all game objects
            gameObjects.forEach(drawGameObject);
            
            // Update UI
            updateUI();
            drawMinimap();
            
            frame++;
            requestAnimationFrame(gameLoop);
        }
        
        // Handle interactions
        canvas.addEventListener('click', (e) => {
            const rect = canvas.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            console.log(\`Player clicked at: \${x}, \${y}\`);
            
            // Add click effect
            ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
            ctx.beginPath();
            ctx.arc(x, y, 30, 0, Math.PI * 2);
            ctx.fill();
            
            setTimeout(() => {
                // Effect fades automatically in next frame
            }, 100);
        });
        
        // Fetch real data periodically
        async function fetchRealData() {
            try {
                const response = await fetch('${gameState.phoenixApiBase}/players');
                if (response.ok) {
                    const data = await response.json();
                    document.getElementById('players').textContent = data.total || players;
                    
                    // Update chat with recent events
                    if (data.recent_events) {
                        data.recent_events.forEach(event => {
                            if (Math.random() < 0.3) { // Only show some events to avoid spam
                                chatMessages.push('[System] ' + event.message);
                                if (chatMessages.length > 8) chatMessages.shift();
                                document.getElementById('chat-content').innerHTML = chatMessages.join('<br>');
                            }
                        });
                    }
                }
            } catch (error) {
                console.log('Could not fetch real-time data');
            }
        }
        
        // Start the game
        console.log('🎮 Enhanced ActionRPG Mock Game Started');
        console.log('🔗 Connected to Phoenix API at ${gameState.phoenixApiBase}');
        
        setTimeout(() => {
            document.getElementById('connection-status').style.display = 'none';
        }, 3000);
        
        // Fetch real data every 30 seconds
        setInterval(fetchRealData, 30000);
        fetchRealData(); // Initial fetch
        
        gameLoop();
    </script>
</body>
</html>`;
    
    // Write the HTML file
    require('fs').writeFileSync('/tmp/game_output/enhanced_game.html', gameHTML);
    console.log('✅ Enhanced visual game content generated');
}

// Start the enhanced mock game
console.log('🎮 Game Loop Starting...');
console.log('========================');

// Generate visual content
generateVisualContent();

// Connect to signaling server
connectToSignalingServer();

// Game simulation loop
let counter = 0;
setInterval(() => {
    counter++;
    gameState.tick = counter;
    
    const currentTime = new Date().toLocaleTimeString();
    
    // Simulate server metrics
    if (counter % 10 === 0) {
        gameState.serverLoad += (Math.random() - 0.5) * 0.05;
        gameState.memoryUsage += Math.floor((Math.random() - 0.5) * 100);
        
        // Keep values in reasonable ranges
        gameState.serverLoad = Math.max(0.1, Math.min(0.9, gameState.serverLoad));
        gameState.memoryUsage = Math.max(800, Math.min(2000, gameState.memoryUsage));
    }
    
    // Simulate player connections/disconnections
    if (counter % 25 === 0) {
        if (Math.random() < 0.3) {
            if (Math.random() > 0.5 && gameState.players < 12) {
                gameState.players++;
                console.log(`[${currentTime}] 👤 Player joined the server (Total: ${gameState.players})`);
            } else if (gameState.players > 0) {
                gameState.players--;
                console.log(`[${currentTime}] 👋 Player left the server (Total: ${gameState.players})`);
            }
        }
    }
    
    // Simulate game events
    if (counter % 40 === 0) {
        const events = [
            '⚔️ Combat initiated in Darkwood Forest',
            '💰 Rare item dropped: Sword of Flames',
            '🏰 Guild war started in Northern Territories',
            '🐉 Dragon spotted near Crystal Caves',
            '⭐ Player reached level 50!',
            '🎯 Quest completed: The Lost Artifact',
            '🔮 Magic portal opened in Ancient Ruins',
            '👑 New guild leader elected',
            '🛡️ Legendary armor discovered',
            '🌟 Server event: Double XP weekend!'
        ];
        const event = events[Math.floor(Math.random() * events.length)];
        console.log(`[${currentTime}] ${event}`);
    }
    
    // Periodic detailed status
    if (counter % 60 === 0) {
        const streamingStatus = gameState.isStreaming ? 'Active' : 'Disconnected';
        console.log(`[${currentTime}] 📊 Server Status:`);
        console.log(`  Players: ${gameState.players}/100`);
        console.log(`  Load: ${(gameState.serverLoad * 100).toFixed(1)}%`);
        console.log(`  Memory: ${gameState.memoryUsage}MB`);
        console.log(`  Uptime: ${counter * 2}s`);
        console.log(`  Active Zones: 5`);
        console.log(`  NPCs: 247`);
        console.log(`  Active Quests: 23`);
        console.log(`  Streaming: ${streamingStatus}`);
    }
    
    // Heartbeat
    if (counter % 30 === 0) {
        const streamingIcon = gameState.isStreaming ? '📡' : '💔';
        console.log(`[${currentTime}] ${streamingIcon} Server heartbeat - All systems operational`);
    }
    
}, 2000);

// Handle graceful shutdown
process.on('SIGTERM', () => {
    console.log('🛑 Shutting down game server...');
    if (ws) {
        ws.close();
    }
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('🛑 Shutting down game server...');
    if (ws) {
        ws.close();
    }
    process.exit(0);
});

console.log('🎮 Enhanced ActionRPG Mock Streamer ready!');
console.log('🌐 Connecting to pixel streaming...');