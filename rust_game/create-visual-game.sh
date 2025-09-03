#!/bin/bash

# Create a visual mock game that actually renders something
echo "🎮 Creating Visual Mock Game"
echo "============================"

# Create a simple SDL2-based game that renders a basic scene
cat > /tmp/visual_game.cpp << 'EOF'
#include <SDL2/SDL.h>
#include <iostream>
#include <cmath>
#include <string>

class VisualGame {
private:
    SDL_Window* window;
    SDL_Renderer* renderer;
    bool running;
    int frame_count;
    
public:
    VisualGame() : window(nullptr), renderer(nullptr), running(true), frame_count(0) {}
    
    bool Initialize() {
        if (SDL_Init(SDL_INIT_VIDEO) < 0) {
            std::cerr << "SDL Init failed: " << SDL_GetError() << std::endl;
            return false;
        }
        
        window = SDL_CreateWindow("ActionRPG Multiplayer Start - Mock Game",
                                SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                                1280, 720, SDL_WINDOW_SHOWN);
        
        if (!window) {
            std::cerr << "Window creation failed: " << SDL_GetError() << std::endl;
            return false;
        }
        
        renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
        if (!renderer) {
            std::cerr << "Renderer creation failed: " << SDL_GetError() << std::endl;
            return false;
        }
        
        std::cout << "🎮 ActionRPG Mock Game Initialized" << std::endl;
        std::cout << "📺 Resolution: 1280x720" << std::endl;
        std::cout << "🎯 Pixel Streaming Ready" << std::endl;
        
        return true;
    }
    
    void HandleEvents() {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
                case SDL_QUIT:
                    running = false;
                    break;
                case SDL_KEYDOWN:
                    std::cout << "Key pressed: " << SDL_GetKeyName(event.key.keysym.sym) << std::endl;
                    break;
                case SDL_MOUSEBUTTONDOWN:
                    std::cout << "Mouse clicked at: " << event.button.x << ", " << event.button.y << std::endl;
                    break;
            }
        }
    }
    
    void Render() {
        // Clear screen with dark blue background
        SDL_SetRenderDrawColor(renderer, 20, 30, 60, 255);
        SDL_RenderClear(renderer);
        
        // Draw animated elements
        float time = frame_count * 0.02f;
        
        // Draw animated circles (representing players/NPCs)
        for (int i = 0; i < 5; i++) {
            int x = 640 + (int)(200 * cos(time + i * 1.2f));
            int y = 360 + (int)(100 * sin(time * 0.8f + i * 0.8f));
            
            // Player color based on index
            if (i == 0) {
                SDL_SetRenderDrawColor(renderer, 100, 255, 100, 255); // Green (player)
            } else {
                SDL_SetRenderDrawColor(renderer, 255, 100, 100, 255); // Red (NPCs)
            }
            
            // Draw circle (simplified as filled rect)
            SDL_Rect rect = {x - 15, y - 15, 30, 30};
            SDL_RenderFillRect(renderer, &rect);
        }
        
        // Draw UI elements
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        
        // Health bar
        SDL_Rect health_bg = {50, 50, 200, 20};
        SDL_SetRenderDrawColor(renderer, 100, 100, 100, 255);
        SDL_RenderFillRect(renderer, &health_bg);
        
        SDL_Rect health_bar = {50, 50, (int)(200 * (0.8f + 0.2f * sin(time))), 20};
        SDL_SetRenderDrawColor(renderer, 255, 100, 100, 255);
        SDL_RenderFillRect(renderer, &health_bar);
        
        // Mana bar
        SDL_Rect mana_bg = {50, 80, 200, 20};
        SDL_SetRenderDrawColor(renderer, 100, 100, 100, 255);
        SDL_RenderFillRect(renderer, &mana_bg);
        
        SDL_Rect mana_bar = {50, 80, (int)(200 * (0.6f + 0.4f * cos(time * 1.5f))), 20};
        SDL_SetRenderDrawColor(renderer, 100, 100, 255, 255);
        SDL_RenderFillRect(renderer, &mana_bar);
        
        // Draw grid (game world)
        SDL_SetRenderDrawColor(renderer, 80, 80, 80, 255);
        for (int x = 0; x < 1280; x += 64) {
            SDL_RenderDrawLine(renderer, x, 0, x, 720);
        }
        for (int y = 0; y < 720; y += 64) {
            SDL_RenderDrawLine(renderer, 0, y, 1280, y);
        }
        
        SDL_RenderPresent(renderer);
        frame_count++;
    }
    
    void Run() {
        while (running) {
            HandleEvents();
            Render();
            SDL_Delay(16); // ~60 FPS
        }
    }
    
    void Cleanup() {
        if (renderer) SDL_DestroyRenderer(renderer);
        if (window) SDL_DestroyWindow(window);
        SDL_Quit();
    }
};

int main(int argc, char* argv[]) {
    std::cout << "🚀 ActionRPG Multiplayer Start - Visual Mock" << std::endl;
    std::cout << "=============================================" << std::endl;
    std::cout << "Engine: Mock SDL2 Renderer" << std::endl;
    std::cout << "Platform: Linux" << std::endl;
    std::cout << "Build: Development" << std::endl;
    std::cout << "" << std::endl;
    
    // Parse pixel streaming arguments
    bool pixel_streaming = false;
    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];
        if (arg.find("-PixelStreaming") != std::string::npos) {
            pixel_streaming = true;
            std::cout << "🌐 Pixel Streaming Mode Enabled" << std::endl;
        }
    }
    
    VisualGame game;
    if (!game.Initialize()) {
        std::cerr << "❌ Failed to initialize game" << std::endl;
        return 1;
    }
    
    std::cout << "✅ Game initialized successfully" << std::endl;
    std::cout << "🎮 Starting game loop..." << std::endl;
    
    game.Run();
    game.Cleanup();
    
    std::cout << "🏁 Game shutdown complete" << std::endl;
    return 0;
}
EOF

echo "📝 Created visual game source code"

# Create a Dockerfile for building the visual game
cat > /tmp/Dockerfile.visual-game << 'EOF'
FROM ubuntu:22.04

# Install SDL2 and build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    libsdl2-dev \
    libsdl2-2.0-0 \
    xvfb \
    x11vnc \
    fluxbox \
    && rm -rf /var/lib/apt/lists/*

# Copy and build the game
COPY visual_game.cpp /app/
WORKDIR /app
RUN g++ -o ActionRPGMultiplayerStart visual_game.cpp -lSDL2 -lm

# Create startup script
RUN echo '#!/bin/bash\n\
export DISPLAY=:99\n\
Xvfb :99 -screen 0 1280x720x24 &\n\
sleep 2\n\
fluxbox &\n\
exec ./ActionRPGMultiplayerStart "$@"' > /app/start-visual-game.sh && \
    chmod +x /app/start-visual-game.sh

CMD ["/app/start-visual-game.sh"]
EOF

echo "🐳 Created Dockerfile for visual game"

# Build the visual game
echo "🔨 Building visual game..."
docker build -f /tmp/Dockerfile.visual-game -t visual-game /tmp/

if [ $? -eq 0 ]; then
    echo "✅ Visual game built successfully!"
    
    # Extract the binary
    echo "📦 Extracting game binary..."
    docker run --rm -v $(pwd):/output visual-game cp /app/ActionRPGMultiplayerStart /output/
    
    if [ -f "ActionRPGMultiplayerStart" ]; then
        echo "✅ Visual game binary extracted!"
        echo "📁 Location: $(pwd)/ActionRPGMultiplayerStart"
        echo "📊 Size: $(ls -lh ActionRPGMultiplayerStart | awk '{print $5}')"
        
        # Make it executable
        chmod +x ActionRPGMultiplayerStart
        
        echo "🎮 Visual mock game ready for deployment!"
    else
        echo "❌ Failed to extract game binary"
        exit 1
    fi
else
    echo "❌ Failed to build visual game"
    exit 1
fi