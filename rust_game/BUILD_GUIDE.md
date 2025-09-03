# UE5 Build System Guide

## 🎯 Quick Start (TL;DR)

```bash
# Navigate to rust_game directory
cd rust_game

# Option 1: Interactive menu (easiest)
bash quick-build.sh

# Option 2: Direct build (fastest)
bash build.sh

# Option 3: Test environment first
bash test-build.sh
```

## 📁 Build Scripts Overview

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `quick-build.sh` | Interactive menu with build options | **Start here** - easiest for beginners |
| `build.sh` | Main build pipeline | Direct builds with custom options |
| `test-build.sh` | Environment validation | When builds aren't working |
| `package-ue5-game.sh` | Docker packaging script | Called automatically by build.sh |
| `build-and-deploy.sh` | Full build + deploy pipeline | Complete end-to-end deployment |

## 🚀 Build Options Explained

### 1. Quick Build Menu (`quick-build.sh`)
```bash
bash quick-build.sh
```
**Best for**: First-time users, testing different configurations

**Options**:
- `[1]` Desktop Game Only - Fastest build, no streaming
- `[2]` Desktop + Pixel Streaming - **Recommended** for web deployment
- `[3]` Development Build - For testing and debugging
- `[4]` Linux Build - For server deployment
- `[5]` Custom Build - Advanced options
- `[6]` Show Build Status - Check what's already built

### 2. Direct Build (`build.sh`)
```bash
# Default build (Windows, Shipping, with Pixel Streaming)
bash build.sh

# Custom options
bash build.sh --platform Linux --config Development
bash build.sh --no-pixel-streaming --skip-docker-build
```

**Parameters**:
- `--platform`: Win64, Linux, Mac
- `--config`: Development, Shipping
- `--no-pixel-streaming`: Disable web streaming
- `--skip-docker-build`: Use existing Docker image

## 🐳 Docker Structure

### Current Docker Setup
```
├── Dockerfile.ue5-builder     # UE5 build environment
├── Dockerfile.pixelstreaming  # Web streaming service
├── docker-compose.yml         # Main services
└── docker-compose.ue5.yml     # UE5-specific services
```

### Docker Commands
```bash
# Build UE5 game in Docker
docker-compose -f docker-compose.ue5.yml run --rm ue5_builder

# Start pixel streaming with your game
docker-compose up -d pixel_streaming

# Full development environment
docker-compose -f docker-compose.yml -f docker-compose.ue5.yml up -d
```

## 📦 Build Outputs

After a successful build, you'll find:

```
rust_game/
├── Packaged/                  # Your built game
│   └── ActionRPGMultiplayerStart/
│       ├── Binaries/
│       │   └── Win64/
│       │       └── ActionRPGMultiplayerStart.exe
│       └── Content/
├── BuildLogs/                 # Build logs for debugging
│   ├── docker-build.log
│   └── ue5-build.log
```

## 🔧 Troubleshooting

### Common Issues

1. **"Docker not running"**
   ```bash
   # Start Docker Desktop on Windows
   # Or start Docker service on Linux
   sudo systemctl start docker
   ```

2. **"Project file not found"**
   ```bash
   # Make sure you're in the rust_game directory
   cd rust_game
   ls -la *.uproject  # Should show ActionRPGMultiplayerStart.uproject
   ```

3. **"Build failed"**
   ```bash
   # Check the build logs
   cat BuildLogs/ue5-build.log
   
   # Test your environment
   bash test-build.sh
   ```

4. **"No packaged output"**
   - The build completed but no game files were created
   - Usually means UE5 isn't properly installed in Docker
   - Currently using mock UE5 tools (see next section)

## ⚠️ Current Limitations

**Important**: The current setup uses **mock UE5 tools** because:
- Real UE5 requires Epic Games authentication
- UE5 Docker images are very large (20GB+)
- Licensing restrictions for automated builds

### What Works Now:
- ✅ Build pipeline and scripts
- ✅ Docker infrastructure
- ✅ Pixel streaming server
- ✅ Mock game simulation

### What Needs Real UE5:
- ❌ Actual game compilation
- ❌ Real game assets
- ❌ Playable game output

## 🎮 Getting a Real Game

To build an actual playable game:

1. **Install UE5 locally** (Epic Games Launcher)
2. **Open the project** in UE5 Editor
3. **Package manually** through UE5 Editor:
   - File → Package Project → Windows (64-bit)
   - Choose output directory: `rust_game/Packaged/`
4. **Deploy to Docker**:
   ```bash
   docker-compose up -d pixel_streaming
   ```

## 🌐 Web Deployment

Once you have a packaged game:

1. **Copy to pixel streaming**:
   ```bash
   # Game files go here:
   rust_game/Packaged/ActionRPGMultiplayerStart/
   ```

2. **Start services**:
   ```bash
   docker-compose up -d pixel_streaming
   ```

3. **Access your game**:
   - Web interface: http://localhost:9070
   - Game API: http://localhost:9069
   - Phoenix CMS: http://localhost:4000

## 🎯 Recommended Workflow

1. **First time setup**:
   ```bash
   cd rust_game
   bash test-build.sh        # Verify environment
   bash quick-build.sh       # Choose option [6] to check status
   ```

2. **Development cycle**:
   ```bash
   bash quick-build.sh       # Choose option [3] for dev builds
   # Test your changes
   bash quick-build.sh       # Choose option [2] for production
   ```

3. **Deployment**:
   ```bash
   bash build-and-deploy.sh  # Full pipeline
   ```

## 📚 Next Steps

- **For real UE5 development**: Install UE5 Editor and package manually
- **For web deployment**: Focus on pixel streaming setup
- **For game logic**: Work with the Rust game service
- **For CMS**: Use the Phoenix web interface

The build system is solid - it just needs real UE5 to create actual games!