#!/usr/bin/env node

// Mock UE5 Game Streamer - Connects to Pixel Streaming Server
const WebSocket = require('ws');

console.log('🎮 Mock UE5 Game Streamer Starting...');
console.log('Engine Version: 5.4.4 (Mock)');
console.log('Build Configuration: Development');
console.log('Platform: Linux');
console.log('');

// Parse command line arguments
let pixelStreamingURL = 'ws://localhost:9070';
let renderOffScreen = false;

process.argv.forEach(arg => {
    if (arg.startsWith('-PixelStreamingURL=')) {
        pixelStreamingURL = arg.split('=')[1];
    }
    if (arg.includes('-RenderOffScreen')) {
        renderOffScreen = true;
        console.log('Render offscreen mode enabled');
    }
});

console.log('Initializing game systems...');
console.log('- Loading ActionRPG world...');
console.log('- Starting multiplayer subsystem...');
console.log('- Initializing character systems...');
console.log('- Loading inventory system...');
console.log(`- Starting Pixel Streaming connection to ${pixelStreamingURL}`);
console.log('- WebRTC enabled');
console.log('');

// Connect to pixel streaming signaling server
let ws;
let connected = false;
let players = 0;

function connectToSignalingServer() {
    console.log(`🔌 Connecting to signaling server: ${pixelStreamingURL}`);
    
    ws = new WebSocket(pixelStreamingURL);
    
    ws.on('open', () => {
        console.log('✅ Connected to pixel streaming signaling server');
        
        // Register as streamer
        ws.send(JSON.stringify({
            type: 'streamer',
            gameTitle: 'ActionRPG Multiplayer Start',
            version: '1.0.0'
        }));
        
        connected = true;
        console.log('🎮 ActionRPG Server ready!');
        console.log('🌐 Listening for connections...');
        console.log('📊 Max players: 100');
        console.log('🎥 Mock video stream active');
    });
    
    ws.on('message', (data) => {
        try {
            const message = JSON.parse(data);
            
            switch (message.type) {
                case 'streamerConnected':
                    console.log('📡 Streamer registration confirmed');
                    break;
                    
                case 'offer':
                    console.log('📞 Received WebRTC offer from viewer');
                    // Send mock answer
                    setTimeout(() => {
                        ws.send(JSON.stringify({
                            type: 'answer',
                            target: 'viewer',
                            sdp: 'mock-sdp-answer-data',
                            timestamp: Date.now()
                        }));
                        console.log('📞 Sent WebRTC answer to viewer');
                    }, 100);
                    break;
                    
                case 'iceCandidate':
                    console.log('🧊 Received ICE candidate from viewer');
                    // Send mock ICE candidate back
                    setTimeout(() => {
                        ws.send(JSON.stringify({
                            type: 'iceCandidate',
                            target: 'viewer',
                            candidate: 'mock-ice-candidate',
                            timestamp: Date.now()
                        }));
                    }, 50);
                    break;
                    
                case 'gameInput':
                    console.log('🎮 Received game input:', message.input);
                    break;
            }
        } catch (error) {
            console.error('❌ Error parsing message:', error);
        }
    });
    
    ws.on('close', () => {
        console.log('❌ Disconnected from signaling server');
        connected = false;
        
        // Attempt to reconnect after 5 seconds
        setTimeout(() => {
            console.log('🔄 Attempting to reconnect...');
            connectToSignalingServer();
        }, 5000);
    });
    
    ws.on('error', (error) => {
        console.error('❌ WebSocket error:', error.message);
    });
}

// Start connection
connectToSignalingServer();

// Simulate game server activity
let counter = 0;
setInterval(() => {
    counter++;
    
    // Simulate player connections/disconnections
    if (counter % 10 === 0) {
        if (Math.random() > 0.5 && players < 10) {
            players++;
            console.log(`[${new Date().toLocaleTimeString()}] Player connected (Total: ${players})`);
        } else if (players > 0) {
            players--;
            console.log(`[${new Date().toLocaleTimeString()}] Player disconnected (Total: ${players})`);
        }
    }
    
    // Periodic status updates
    if (counter % 15 === 0) {
        const memory = Math.floor(Math.random() * 500 + 1000);
        console.log(`[${new Date().toLocaleTimeString()}] Server Status - Tick: ${counter}, Players: ${players}, Memory: ${memory}MB, Streaming: ${connected ? 'Active' : 'Disconnected'}`);
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