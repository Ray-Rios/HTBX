/**
 * EQEmu Pixel Streaming Client
 * Handles WebRTC connection and game streaming
 */

class EQEmuPixelStreamingClient {
    constructor() {
        this.ws = null;
        this.peerConnection = null;
        this.sessionId = null;
        this.isConnected = false;
        this.isGameRunning = false;
        
        // Configuration
        this.config = {
            signalingUrl: `ws://${window.location.hostname}:8888`,
            iceServers: [
                { urls: 'stun:stun.l.google.com:19302' },
                { urls: 'stun:stun1.l.google.com:19302' }
            ]
        };
        
        // DOM elements
        this.elements = {
            loadingScreen: document.getElementById('loading-screen'),
            gameContainer: document.getElementById('game-container'),
            gameVideo: document.getElementById('game-video'),
            inputOverlay: document.getElementById('input-overlay'),
            connectionStatus: document.getElementById('connection-status'),
            statusIndicator: document.getElementById('status-indicator'),
            statusText: document.getElementById('status-text'),
            loadingStatus: document.getElementById('loading-status'),
            errorContainer: document.getElementById('error-container'),
            errorMessage: document.getElementById('error-message')
        };
        
        // Input handling
        this.inputHandler = new InputHandler(this);
        
        // Initialize
        this.init();
    }
    
    async init() {
        console.log('🎮 Initializing EQEmu Pixel Streaming Client...');
        
        try {
            await this.connect();
        } catch (error) {
            console.error('❌ Failed to initialize:', error);
            this.showError('Failed to connect to game server');
        }
    }
    
    async connect() {
        this.updateStatus('connecting', 'Connecting to server...');
        
        return new Promise((resolve, reject) => {
            try {
                this.ws = new WebSocket(this.config.signalingUrl);
                
                this.ws.onopen = () => {
                    console.log('🔗 WebSocket connected');
                    this.isConnected = true;
                    this.updateStatus('connected', 'Connected to server');
                    resolve();
                };
                
                this.ws.onmessage = (event) => {
                    this.handleMessage(JSON.parse(event.data));
                };
                
                this.ws.onclose = (event) => {
                    console.log('🔌 WebSocket disconnected:', event.code, event.reason);
                    this.isConnected = false;
                    this.updateStatus('disconnected', 'Disconnected from server');
                    
                    if (!event.wasClean) {
                        this.showError('Connection lost. Please refresh the page.');
                    }
                };
                
                this.ws.onerror = (error) => {
                    console.error('❌ WebSocket error:', error);
                    this.isConnected = false;
                    reject(error);
                };
                
                // Connection timeout
                setTimeout(() => {
                    if (!this.isConnected) {
                        reject(new Error('Connection timeout'));
                    }
                }, 10000);
                
            } catch (error) {
                reject(error);
            }
        });
    }
    
    handleMessage(message) {
        console.log('📨 Received message:', message.type);
        
        switch (message.type) {
            case 'welcome':
                this.sessionId = message.sessionId;
                console.log('👋 Welcome! Session ID:', this.sessionId);
                this.hideLoading();
                break;
                
            case 'game_starting':
                this.updateStatus('connecting', message.message);
                break;
                
            case 'game_started':
                this.isGameRunning = true;
                this.updateStatus('connected', 'Game running');
                console.log('🎮 Game started:', message.message);
                break;
                
            case 'game_stopped':
                this.isGameRunning = false;
                this.updateStatus('connected', 'Game stopped');
                console.log('🛑 Game stopped:', message.reason);
                break;
                
            case 'game_update':
                this.handleGameUpdate(message.data);
                break;
                
            case 'offer':
                this.handleOffer(message);
                break;
                
            case 'answer':
                this.handleAnswer(message);
                break;
                
            case 'ice-candidate':
                this.handleIceCandidate(message);
                break;
                
            case 'error':
                console.error('❌ Server error:', message.message);
                this.showError(message.message);
                break;
                
            default:
                console.log('❓ Unknown message type:', message.type);
        }
    }
    
    async startGame() {
        if (!this.isConnected) {
            this.showError('Not connected to server');
            return;
        }
        
        console.log('🎮 Starting game...');
        this.updateStatus('connecting', 'Starting game...');
        
        // Initialize WebRTC peer connection
        await this.initializePeerConnection();
        
        // Send start game message
        this.sendMessage({
            type: 'start_game',
            sessionId: this.sessionId
        });
    }
    
    stopGame() {
        if (!this.isConnected) return;
        
        console.log('🛑 Stopping game...');
        
        this.sendMessage({
            type: 'stop_game',
            sessionId: this.sessionId
        });
        
        if (this.peerConnection) {
            this.peerConnection.close();
            this.peerConnection = null;
        }
        
        this.isGameRunning = false;
        this.updateStatus('connected', 'Game stopped');
    }
    
    async initializePeerConnection() {
        console.log('🔗 Initializing WebRTC peer connection...');
        
        this.peerConnection = new RTCPeerConnection({
            iceServers: this.config.iceServers
        });
        
        // Handle incoming streams
        this.peerConnection.ontrack = (event) => {
            console.log('📺 Received media stream');
            const stream = event.streams[0];
            this.elements.gameVideo.srcObject = stream;
        };
        
        // Handle ICE candidates
        this.peerConnection.onicecandidate = (event) => {
            if (event.candidate) {
                this.sendMessage({
                    type: 'ice-candidate',
                    candidate: event.candidate
                });
            }
        };
        
        // Handle connection state changes
        this.peerConnection.onconnectionstatechange = () => {
            console.log('🔗 Connection state:', this.peerConnection.connectionState);
            
            switch (this.peerConnection.connectionState) {
                case 'connected':
                    this.updateStatus('connected', 'Streaming active');
                    break;
                case 'disconnected':
                case 'failed':
                    this.updateStatus('disconnected', 'Stream disconnected');
                    break;
            }
        };
        
        // Create offer
        const offer = await this.peerConnection.createOffer();
        await this.peerConnection.setLocalDescription(offer);
        
        this.sendMessage({
            type: 'offer',
            offer: offer
        });
    }
    
    async handleOffer(message) {
        if (!this.peerConnection) {
            await this.initializePeerConnection();
        }
        
        await this.peerConnection.setRemoteDescription(message.offer);
        const answer = await this.peerConnection.createAnswer();
        await this.peerConnection.setLocalDescription(answer);
        
        this.sendMessage({
            type: 'answer',
            answer: answer
        });
    }
    
    async handleAnswer(message) {
        if (this.peerConnection) {
            await this.peerConnection.setRemoteDescription(message.answer);
        }
    }
    
    async handleIceCandidate(message) {
        if (this.peerConnection) {
            await this.peerConnection.addIceCandidate(message.candidate);
        }
    }
    
    handleGameUpdate(data) {
        // Update game statistics
        const playersOnline = document.getElementById('players-online');
        const zonesLoaded = document.getElementById('zones-loaded');
        const serverStatus = document.getElementById('server-status');
        
        if (playersOnline) playersOnline.textContent = data.players_online || 0;
        if (zonesLoaded) zonesLoaded.textContent = data.zones_loaded || 0;
        if (serverStatus) serverStatus.textContent = data.server_status || 'Unknown';
    }
    
    sendMessage(message) {
        if (this.ws && this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify(message));
        } else {
            console.error('❌ Cannot send message: WebSocket not connected');
        }
    }
    
    sendInput(inputType, data) {
        this.sendMessage({
            type: 'input',
            inputType: inputType,
            data: data
        });
    }
    
    updateStatus(status, text) {
        this.elements.statusIndicator.className = `status-indicator ${status}`;
        this.elements.statusText.textContent = text;
        
        if (this.elements.loadingStatus) {
            this.elements.loadingStatus.textContent = text;
        }
    }
    
    hideLoading() {
        this.elements.loadingScreen.classList.add('hidden');
        this.elements.gameContainer.classList.remove('hidden');
    }
    
    showError(message) {
        this.elements.errorMessage.textContent = message;
        this.elements.errorContainer.classList.remove('hidden');
    }
    
    hideError() {
        this.elements.errorContainer.classList.add('hidden');
    }
    
    toggleFullscreen() {
        if (!document.fullscreenElement) {
            this.elements.gameContainer.requestFullscreen().catch(err => {
                console.error('❌ Error attempting to enable fullscreen:', err);
            });
        } else {
            document.exitFullscreen();
        }
    }
}

/**
 * Input Handler for game controls
 */
class InputHandler {
    constructor(client) {
        this.client = client;
        this.keys = new Set();
        this.mouseButtons = new Set();
        this.isPointerLocked = false;
        
        this.init();
    }
    
    init() {
        const overlay = this.client.elements.inputOverlay;
        const video = this.client.elements.gameVideo;
        
        // Keyboard events
        document.addEventListener('keydown', (e) => this.handleKeyDown(e));
        document.addEventListener('keyup', (e) => this.handleKeyUp(e));
        
        // Mouse events
        video.addEventListener('click', () => this.requestPointerLock());
        video.addEventListener('mousedown', (e) => this.handleMouseDown(e));
        video.addEventListener('mouseup', (e) => this.handleMouseUp(e));
        video.addEventListener('mousemove', (e) => this.handleMouseMove(e));
        video.addEventListener('wheel', (e) => this.handleWheel(e));
        
        // Pointer lock events
        document.addEventListener('pointerlockchange', () => {
            this.isPointerLocked = document.pointerLockElement === video;
        });
        
        // Context menu
        video.addEventListener('contextmenu', (e) => e.preventDefault());
    }
    
    handleKeyDown(event) {
        if (this.keys.has(event.code)) return;
        
        this.keys.add(event.code);
        
        // Prevent default for game keys
        const gameKeys = ['KeyW', 'KeyA', 'KeyS', 'KeyD', 'Space', 'Tab', 'Enter', 'KeyI', 'KeyC'];
        if (gameKeys.includes(event.code)) {
            event.preventDefault();
        }
        
        // Handle special keys
        if (event.code === 'F11') {
            event.preventDefault();
            this.client.toggleFullscreen();
            return;
        }
        
        this.client.sendInput('keydown', {
            key: event.key,
            code: event.code,
            ctrlKey: event.ctrlKey,
            shiftKey: event.shiftKey,
            altKey: event.altKey
        });
    }
    
    handleKeyUp(event) {
        this.keys.delete(event.code);
        
        this.client.sendInput('keyup', {
            key: event.key,
            code: event.code
        });
    }
    
    handleMouseDown(event) {
        this.mouseButtons.add(event.button);
        
        this.client.sendInput('mousedown', {
            button: event.button,
            x: event.offsetX,
            y: event.offsetY
        });
    }
    
    handleMouseUp(event) {
        this.mouseButtons.delete(event.button);
        
        this.client.sendInput('mouseup', {
            button: event.button,
            x: event.offsetX,
            y: event.offsetY
        });
    }
    
    handleMouseMove(event) {
        if (!this.isPointerLocked) return;
        
        this.client.sendInput('mousemove', {
            movementX: event.movementX,
            movementY: event.movementY
        });
    }
    
    handleWheel(event) {
        event.preventDefault();
        
        this.client.sendInput('wheel', {
            deltaX: event.deltaX,
            deltaY: event.deltaY,
            deltaZ: event.deltaZ
        });
    }
    
    requestPointerLock() {
        const video = this.client.elements.gameVideo;
        video.requestPointerLock();
    }
}

// Initialize client when page loads
window.addEventListener('DOMContentLoaded', () => {
    window.eqemuClient = new EQEmuPixelStreamingClient();
});