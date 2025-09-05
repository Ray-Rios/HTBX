#!/usr/bin/env node

/**
 * EQEmu Pixel Streaming Server
 * Handles WebRTC signaling and game streaming for browser-based EverQuest
 */

const WebSocket = require('ws');
const http = require('http');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

// Configuration
const config = {
    // Pixel streaming ports
    signalingPort: process.env.PIXEL_STREAMING_PORT || 8888,
    webPort: process.env.WEB_PORT || 9070,
    
    // Game server configuration
    gameServerUrl: process.env.GAME_SERVER_URL || 'http://localhost:7000',
    
    // UE5 game executable path
    gameExecutable: process.env.GAME_EXECUTABLE || '/app/game/eqemuue5.sh',
    
    // Display configuration
    displayWidth: parseInt(process.env.DISPLAY_WIDTH) || 1920,
    displayHeight: parseInt(process.env.DISPLAY_HEIGHT) || 1080,
    displayNumber: process.env.DISPLAY_NUMBER || ':99',
    
    // Streaming quality
    maxBitrate: parseInt(process.env.MAX_BITRATE) || 20000000, // 20 Mbps
    minBitrate: parseInt(process.env.MIN_BITRATE) || 1000000,  // 1 Mbps
    
    // Session management
    maxSessions: parseInt(process.env.MAX_SESSIONS) || 10,
    sessionTimeout: parseInt(process.env.SESSION_TIMEOUT) || 300000, // 5 minutes
};

console.log('🎮 EQEmu Pixel Streaming Server Starting...');
console.log('📊 Configuration:', JSON.stringify(config, null, 2));

// Session management
const sessions = new Map();
let sessionCounter = 0;

// WebRTC signaling server
const signalingServer = new WebSocket.Server({ 
    port: config.signalingPort,
    perMessageDeflate: false 
});

console.log(`🔗 WebRTC Signaling Server listening on port ${config.signalingPort}`);

// HTTP server for web interface
const webServer = http.createServer((req, res) => {
    const url = req.url === '/' ? '/index.html' : req.url;
    const filePath = path.join(__dirname, 'web', url);
    
    // Security check - prevent directory traversal
    if (!filePath.startsWith(path.join(__dirname, 'web'))) {
        res.writeHead(403);
        res.end('Forbidden');
        return;
    }
    
    fs.readFile(filePath, (err, data) => {
        if (err) {
            if (err.code === 'ENOENT') {
                res.writeHead(404);
                res.end('Not Found');
            } else {
                res.writeHead(500);
                res.end('Internal Server Error');
            }
            return;
        }
        
        // Set content type based on file extension
        const ext = path.extname(filePath).toLowerCase();
        const contentTypes = {
            '.html': 'text/html',
            '.js': 'application/javascript',
            '.css': 'text/css',
            '.json': 'application/json',
            '.png': 'image/png',
            '.jpg': 'image/jpeg',
            '.gif': 'image/gif',
            '.ico': 'image/x-icon'
        };
        
        const contentType = contentTypes[ext] || 'application/octet-stream';
        res.writeHead(200, { 'Content-Type': contentType });
        res.end(data);
    });
});

webServer.listen(config.webPort, () => {
    console.log(`🌐 Web Server listening on port ${config.webPort}`);
    console.log(`🎯 Access EQEmu at: http://localhost:${config.webPort}`);
});

// WebRTC signaling logic
signalingServer.on('connection', (ws, req) => {
    const sessionId = `session_${++sessionCounter}`;
    const clientIP = req.socket.remoteAddress;
    
    console.log(`🔌 New client connected: ${sessionId} from ${clientIP}`);
    
    // Check session limits
    if (sessions.size >= config.maxSessions) {
        console.log(`❌ Session limit reached (${config.maxSessions}), rejecting ${sessionId}`);
        ws.send(JSON.stringify({
            type: 'error',
            message: 'Server is at capacity. Please try again later.'
        }));
        ws.close();
        return;
    }
    
    // Create session
    const session = {
        id: sessionId,
        ws: ws,
        clientIP: clientIP,
        gameProcess: null,
        startTime: Date.now(),
        lastActivity: Date.now()
    };
    
    sessions.set(sessionId, session);
    
    // Send welcome message
    ws.send(JSON.stringify({
        type: 'welcome',
        sessionId: sessionId,
        config: {
            maxBitrate: config.maxBitrate,
            minBitrate: config.minBitrate
        }
    }));
    
    // Handle messages from client
    ws.on('message', async (message) => {
        try {
            const data = JSON.parse(message);
            session.lastActivity = Date.now();
            
            console.log(`📨 Message from ${sessionId}:`, data.type);
            
            switch (data.type) {
                case 'start_game':
                    await startGameSession(session, data);
                    break;
                    
                case 'stop_game':
                    await stopGameSession(session);
                    break;
                    
                case 'input':
                    handleGameInput(session, data);
                    break;
                    
                case 'offer':
                case 'answer':
                case 'ice-candidate':
                    // Forward WebRTC signaling to game process
                    forwardToGame(session, data);
                    break;
                    
                default:
                    console.log(`❓ Unknown message type: ${data.type}`);
            }
        } catch (error) {
            console.error(`❌ Error processing message from ${sessionId}:`, error);
        }
    });
    
    // Handle client disconnect
    ws.on('close', () => {
        console.log(`🔌 Client disconnected: ${sessionId}`);
        cleanupSession(sessionId);
    });
    
    // Handle errors
    ws.on('error', (error) => {
        console.error(`❌ WebSocket error for ${sessionId}:`, error);
        cleanupSession(sessionId);
    });
});

// Start a game session for a client
async function startGameSession(session, data) {
    console.log(`🎮 Starting game session for ${session.id}`);
    
    try {
        // Check if game executable exists
        if (!fs.existsSync(config.gameExecutable)) {
            console.log(`⚠️  Game executable not found: ${config.gameExecutable}`);
            console.log(`🔧 Starting mock game server instead...`);
            startMockGameServer(session);
            return;
        }
        
        // Start virtual display
        const xvfbProcess = spawn('Xvfb', [
            config.displayNumber,
            '-screen', '0',
            `${config.displayWidth}x${config.displayHeight}x24`,
            '-ac',
            '+extension', 'GLX',
            '+render',
            '-noreset'
        ], {
            stdio: 'pipe',
            env: { ...process.env, DISPLAY: config.displayNumber }
        });
        
        // Wait for display to start
        await new Promise(resolve => setTimeout(resolve, 2000));
        
        // Start game process
        const gameProcess = spawn(config.gameExecutable, [
            '-PixelStreamingURL=ws://localhost:' + config.signalingPort,
            '-RenderOffScreen',
            '-Unattended',
            '-PixelStreamingWebRTCMaxFps=60'
        ], {
            stdio: 'pipe',
            env: { 
                ...process.env, 
                DISPLAY: config.displayNumber,
                SESSION_ID: session.id
            }
        });
        
        session.gameProcess = gameProcess;
        session.xvfbProcess = xvfbProcess;
        
        gameProcess.stdout.on('data', (data) => {
            console.log(`🎮 Game output (${session.id}):`, data.toString().trim());
        });
        
        gameProcess.stderr.on('data', (data) => {
            console.error(`🎮 Game error (${session.id}):`, data.toString().trim());
        });
        
        gameProcess.on('close', (code) => {
            console.log(`🎮 Game process closed (${session.id}) with code ${code}`);
            session.ws.send(JSON.stringify({
                type: 'game_stopped',
                reason: `Game process exited with code ${code}`
            }));
        });
        
        // Notify client that game is starting
        session.ws.send(JSON.stringify({
            type: 'game_starting',
            message: 'EQEmu server is initializing...'
        }));
        
    } catch (error) {
        console.error(`❌ Error starting game session for ${session.id}:`, error);
        session.ws.send(JSON.stringify({
            type: 'error',
            message: 'Failed to start game session'
        }));
    }
}

// Start a mock game server for development/testing
function startMockGameServer(session) {
    console.log(`🎭 Starting mock game server for ${session.id}`);
    
    // Send mock game data
    session.ws.send(JSON.stringify({
        type: 'game_started',
        message: 'Mock EQEmu server started - Development Mode'
    }));
    
    // Simulate game updates
    const mockInterval = setInterval(() => {
        if (session.ws.readyState === WebSocket.OPEN) {
            session.ws.send(JSON.stringify({
                type: 'game_update',
                data: {
                    timestamp: Date.now(),
                    players_online: Math.floor(Math.random() * 100),
                    zones_loaded: 50,
                    server_status: 'running'
                }
            }));
        } else {
            clearInterval(mockInterval);
        }
    }, 5000);
    
    session.mockInterval = mockInterval;
}

// Stop a game session
async function stopGameSession(session) {
    console.log(`🛑 Stopping game session for ${session.id}`);
    
    if (session.gameProcess) {
        session.gameProcess.kill('SIGTERM');
        session.gameProcess = null;
    }
    
    if (session.xvfbProcess) {
        session.xvfbProcess.kill('SIGTERM');
        session.xvfbProcess = null;
    }
    
    if (session.mockInterval) {
        clearInterval(session.mockInterval);
        session.mockInterval = null;
    }
    
    session.ws.send(JSON.stringify({
        type: 'game_stopped',
        message: 'Game session ended'
    }));
}

// Handle game input from client
function handleGameInput(session, data) {
    // Forward input to game process if running
    if (session.gameProcess) {
        // In a real implementation, this would send input to the UE5 game
        console.log(`🎮 Input from ${session.id}:`, data.inputType);
    }
}

// Forward WebRTC signaling to game process
function forwardToGame(session, data) {
    // In a real implementation, this would forward WebRTC signaling
    // to the UE5 pixel streaming plugin
    console.log(`🔄 Forwarding ${data.type} to game process for ${session.id}`);
}

// Clean up a session
function cleanupSession(sessionId) {
    const session = sessions.get(sessionId);
    if (session) {
        stopGameSession(session);
        sessions.delete(sessionId);
        console.log(`🧹 Cleaned up session: ${sessionId}`);
    }
}

// Session timeout cleanup
setInterval(() => {
    const now = Date.now();
    for (const [sessionId, session] of sessions) {
        if (now - session.lastActivity > config.sessionTimeout) {
            console.log(`⏰ Session timeout: ${sessionId}`);
            cleanupSession(sessionId);
        }
    }
}, 60000); // Check every minute

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('🛑 Shutting down pixel streaming server...');
    
    // Close all sessions
    for (const sessionId of sessions.keys()) {
        cleanupSession(sessionId);
    }
    
    // Close servers
    signalingServer.close();
    webServer.close();
    
    process.exit(0);
});

console.log('✅ EQEmu Pixel Streaming Server is ready!');
console.log(`🎮 Waiting for game sessions on port ${config.signalingPort}`);
console.log(`🌐 Web interface available on port ${config.webPort}`);