/**
 * EQEmu Game UI Controller
 * Handles UI interactions and game controls
 */

class GameUIController {
    constructor() {
        this.client = null;
        this.isControlsVisible = false;
        this.isStatsVisible = false;
        
        this.init();
    }
    
    init() {
        // Wait for client to be available
        const checkClient = () => {
            if (window.eqemuClient) {
                this.client = window.eqemuClient;
                this.setupEventListeners();
            } else {
                setTimeout(checkClient, 100);
            }
        };
        checkClient();
    }
    
    setupEventListeners() {
        // Control buttons
        const startGameBtn = document.getElementById('start-game-btn');
        const stopGameBtn = document.getElementById('stop-game-btn');
        const fullscreenBtn = document.getElementById('fullscreen-btn');
        const helpBtn = document.getElementById('help-btn');
        const statsBtn = document.getElementById('stats-btn');
        const retryBtn = document.getElementById('retry-btn');
        
        // Game controls
        if (startGameBtn) {
            startGameBtn.addEventListener('click', () => this.startGame());
        }
        
        if (stopGameBtn) {
            stopGameBtn.addEventListener('click', () => this.stopGame());
        }
        
        if (fullscreenBtn) {
            fullscreenBtn.addEventListener('click', () => this.toggleFullscreen());
        }
        
        if (helpBtn) {
            helpBtn.addEventListener('click', () => this.toggleControls());
        }
        
        if (statsBtn) {
            statsBtn.addEventListener('click', () => this.toggleStats());
        }
        
        if (retryBtn) {
            retryBtn.addEventListener('click', () => this.retry());
        }
        
        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => this.handleKeyboardShortcuts(e));
        
        // Fullscreen change events
        document.addEventListener('fullscreenchange', () => this.updateFullscreenButton());
        document.addEventListener('webkitfullscreenchange', () => this.updateFullscreenButton());
        document.addEventListener('mozfullscreenchange', () => this.updateFullscreenButton());
        
        // Close overlays when clicking outside
        document.addEventListener('click', (e) => this.handleOutsideClick(e));
    }
    
    async startGame() {
        if (!this.client) return;
        
        const startBtn = document.getElementById('start-game-btn');
        const stopBtn = document.getElementById('stop-game-btn');
        
        // Update button states
        if (startBtn) {
            startBtn.classList.add('hidden');
            startBtn.disabled = true;
        }
        
        if (stopBtn) {
            stopBtn.classList.remove('hidden');
            stopBtn.disabled = false;
        }
        
        try {
            await this.client.startGame();
            this.showNotification('🎮 Starting EQEmu server...', 'info');
        } catch (error) {
            console.error('❌ Failed to start game:', error);
            this.showNotification('❌ Failed to start game', 'error');
            this.resetGameButtons();
        }
    }
    
    stopGame() {
        if (!this.client) return;
        
        this.client.stopGame();
        this.resetGameButtons();
        this.showNotification('🛑 Game stopped', 'info');
    }
    
    resetGameButtons() {
        const startBtn = document.getElementById('start-game-btn');
        const stopBtn = document.getElementById('stop-game-btn');
        
        if (startBtn) {
            startBtn.classList.remove('hidden');
            startBtn.disabled = false;
        }
        
        if (stopBtn) {
            stopBtn.classList.add('hidden');
            stopBtn.disabled = true;
        }
    }
    
    toggleFullscreen() {
        if (this.client) {
            this.client.toggleFullscreen();
        }
    }
    
    updateFullscreenButton() {
        const fullscreenBtn = document.getElementById('fullscreen-btn');
        if (fullscreenBtn) {
            const isFullscreen = document.fullscreenElement || 
                               document.webkitFullscreenElement || 
                               document.mozFullScreenElement;
            
            fullscreenBtn.innerHTML = isFullscreen ? '🔍 Exit Fullscreen' : '🔍 Fullscreen';
        }
    }
    
    toggleControls() {
        const controlsHelp = document.getElementById('controls-help');
        if (controlsHelp) {
            this.isControlsVisible = !this.isControlsVisible;
            controlsHelp.classList.toggle('hidden', !this.isControlsVisible);
            
            // Hide stats if controls are shown
            if (this.isControlsVisible && this.isStatsVisible) {
                this.toggleStats();
            }
        }
    }
    
    toggleStats() {
        const gameStats = document.getElementById('game-stats');
        if (gameStats) {
            this.isStatsVisible = !this.isStatsVisible;
            gameStats.classList.toggle('hidden', !this.isStatsVisible);
            
            // Hide controls if stats are shown
            if (this.isStatsVisible && this.isControlsVisible) {
                this.toggleControls();
            }
        }
    }
    
    retry() {
        // Hide error and reload page
        const errorContainer = document.getElementById('error-container');
        if (errorContainer) {
            errorContainer.classList.add('hidden');
        }
        
        // Reload the page to restart connection
        window.location.reload();
    }
    
    handleKeyboardShortcuts(event) {
        // Don't handle shortcuts if typing in an input
        if (event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA') {
            return;
        }
        
        switch (event.code) {
            case 'F1':
                event.preventDefault();
                this.toggleControls();
                break;
                
            case 'F2':
                event.preventDefault();
                this.toggleStats();
                break;
                
            case 'F11':
                // Handled by input handler
                break;
                
            case 'Escape':
                // Close any open overlays
                if (this.isControlsVisible) {
                    this.toggleControls();
                } else if (this.isStatsVisible) {
                    this.toggleStats();
                }
                break;
        }
    }
    
    handleOutsideClick(event) {
        const controlsHelp = document.getElementById('controls-help');
        const gameStats = document.getElementById('game-stats');
        const helpBtn = document.getElementById('help-btn');
        const statsBtn = document.getElementById('stats-btn');
        
        // Close controls if clicking outside
        if (this.isControlsVisible && 
            controlsHelp && 
            !controlsHelp.contains(event.target) && 
            !helpBtn.contains(event.target)) {
            this.toggleControls();
        }
        
        // Close stats if clicking outside
        if (this.isStatsVisible && 
            gameStats && 
            !gameStats.contains(event.target) && 
            !statsBtn.contains(event.target)) {
            this.toggleStats();
        }
    }
    
    showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.textContent = message;
        
        // Style the notification
        Object.assign(notification.style, {
            position: 'fixed',
            top: '80px',
            right: '20px',
            background: type === 'error' ? 'rgba(255, 68, 68, 0.9)' : 'rgba(78, 205, 196, 0.9)',
            color: 'white',
            padding: '12px 20px',
            borderRadius: '8px',
            fontSize: '0.9rem',
            fontWeight: 'bold',
            zIndex: '1000',
            animation: 'slideInRight 0.3s ease-out',
            backdropFilter: 'blur(10px)',
            border: `2px solid ${type === 'error' ? '#ff4444' : '#4ecdc4'}`
        });
        
        // Add to page
        document.body.appendChild(notification);
        
        // Remove after 3 seconds
        setTimeout(() => {
            notification.style.animation = 'slideOutRight 0.3s ease-in';
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 300);
        }, 3000);
    }
    
    updateConnectionStatus(status, message) {
        const statusIndicator = document.getElementById('status-indicator');
        const statusText = document.getElementById('status-text');
        
        if (statusIndicator) {
            statusIndicator.className = `status-indicator ${status}`;
        }
        
        if (statusText) {
            statusText.textContent = message;
        }
    }
    
    updateGameStats(stats) {
        const playersOnline = document.getElementById('players-online');
        const zonesLoaded = document.getElementById('zones-loaded');
        const serverStatus = document.getElementById('server-status');
        
        if (playersOnline && stats.players_online !== undefined) {
            playersOnline.textContent = stats.players_online;
        }
        
        if (zonesLoaded && stats.zones_loaded !== undefined) {
            zonesLoaded.textContent = stats.zones_loaded;
        }
        
        if (serverStatus && stats.server_status) {
            serverStatus.textContent = stats.server_status;
            serverStatus.className = `stat-value status-${stats.server_status.toLowerCase()}`;
        }
    }
}

// Add CSS animations for notifications
const style = document.createElement('style');
style.textContent = `
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
    
    .status-running {
        color: #44ff44 !important;
    }
    
    .status-stopped {
        color: #ff4444 !important;
    }
    
    .status-starting {
        color: #ffaa44 !important;
    }
`;
document.head.appendChild(style);

// Initialize UI controller when page loads
window.addEventListener('DOMContentLoaded', () => {
    window.gameUI = new GameUIController();
});