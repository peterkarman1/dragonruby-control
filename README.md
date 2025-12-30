# DragonRuby Control

Run DragonRuby games in a Docker container with virtual display, input simulation, and screenshot capabilities. Designed for automated testing and AI-assisted debugging.

Allows your AI assistant to control input and see the game via screenshots. Works best with RTS, rougelite etc. You may need to slow your game speed down to account for LLM slowness.

## Prerequisites

- **Docker & Docker Compose**: Make sure Docker Desktop is installed and running.
- **Linux DragonRuby**: The `dragonruby-linux-amd64/` directory should contain your Linux DragonRuby distribution.

## Quick Start

These files are designed to live next to your DragonRuby game. The scripts expect the usual `mygame` folder to exist. You will need to modify if you are not using the default DragonRuby setup.

Simply point your AI Assistant at this readme and watch it do its thing. You can read the rest of this, but ultimately, this is for the LLM.

```bash
# Build the container (first time only, or after Dockerfile changes)
./dr-control build

# Start the game
./dr-control start

# Take a screenshot
./dr-control screenshot

# Send input
./dr-control enter
./dr-control click 640 360

# Stop the game
./dr-control stop
```

## Development Workflow

The container mounts `./mygame/` for live editing. DragonRuby hot-reloads code changes automatically.

```bash
./dr-control start              # Start game
./dr-control screenshot         # See current state
# Edit mygame/*.rb files...     # DragonRuby auto-reloads
./dr-control screenshot         # See changes immediately
./dr-control stop               # When done
```

No rebuild needed for code changes.

## dr-control Commands

The `dr-control` script in the project root provides easy access to all functionality:

### Container Management
```bash
./dr-control build              # Build/rebuild Docker image
./dr-control start              # Start container in background
./dr-control stop               # Stop container
./dr-control restart            # Restart container
./dr-control logs               # View container logs (follow mode)
./dr-control shell              # Open bash shell in container
```

### Screenshots
```bash
./dr-control screenshot         # Auto-named screenshot
./dr-control screenshot foo.png # Named screenshot
./dr-control ss                 # Alias for screenshot
```

Screenshots are saved to `./screenshots/` on your host.

### Keyboard Input
```bash
./dr-control enter              # Enter key
./dr-control space              # Space bar
./dr-control escape             # Escape key
./dr-control tab                # Tab key
./dr-control up                 # Arrow up
./dr-control down               # Arrow down
./dr-control left               # Arrow left
./dr-control right              # Arrow right
./dr-control w/a/s/d            # WASD (aliases for arrows)
./dr-control key F1             # Any key by name
./dr-control type "hello"       # Type text
```

### Mouse Input
```bash
./dr-control click 640 360      # Click at coordinates
./dr-control move 640 360       # Move mouse to coordinates
```

### Timing
```bash
./dr-control wait 1000          # Wait 1000ms
```

### Sequences
```bash
./dr-control run sequence.txt   # Run commands from file
./dr-control do space wait 500  # Run commands and auto-screenshot
```

## VNC Mode (Real-time Viewing)

To watch the game in real-time via VNC:

```bash
./dr-control start-vnc

# Connect with a VNC client to localhost:5900
# On macOS:
open vnc://localhost:5900
```

## Low-Level Docker Commands

You can also use docker exec directly:

```bash
# Screenshots
docker exec dragonruby-game screenshot.sh
docker exec dragonruby-game screenshot.sh my_screenshot.png

# Input
docker exec dragonruby-game send-input.sh key space
docker exec dragonruby-game send-input.sh key Return
docker exec dragonruby-game send-input.sh click 640 360
docker exec dragonruby-game send-input.sh mousemove 100 200
docker exec dragonruby-game send-input.sh delay 1000

# High-level control
docker exec dragonruby-game game-control.sh screenshot
docker exec dragonruby-game game-control.sh space
docker exec dragonruby-game game-control.sh click 640 360
```

## Screen Coordinates

The game runs at 1280x720 resolution. Common UI positions:

- Center of screen: (640, 360)
- Top-left: (0, 0)
- Top-right: (1280, 0)
- Bottom-left: (0, 720)
- Bottom-right: (1280, 720)

## Architecture

```
┌─────────────────────────────────────────────────┐
│              Docker Container                   │
│  ┌───────────────────────────────────────────┐  │
│  │       Xvfb (Virtual Display :99)          │  │
│  │  ┌─────────────────────────────────────┐  │  │
│  │  │         DragonRuby Game             │  │  │
│  │  │        (renders to display)         │  │  │
│  │  └─────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────┘  │
│                       │                         │
│          ┌────────────┼────────────┐            │
│          │            │            │            │
│          ▼            ▼            ▼            │
│      xdotool      scrot       x11vnc           │
│      (input)   (screenshot)  (viewer)          │
└─────────────────────────────────────────────────┘
          │            │            │
          ▼            ▼            ▼
     send-input.sh  screenshot.sh  VNC:5900
          │            │
          └─────┬──────┘
                ▼
           dr-control (host wrapper)
```

## Files

```
├── Dockerfile              # Container image definition
├── docker-compose.yml      # Container orchestration
├── dr-control              # Host-side control script
├── .dockerignore           # Build optimization
├── docker/
│   ├── README.md           # This file
│   ├── entrypoint.sh       # Container startup script
│   ├── screenshot.sh       # Screenshot utility
│   ├── send-input.sh       # Input utility
│   └── game-control.sh     # High-level control utility
├── screenshots/            # Screenshot output directory
└── mygame/                 # Game code (live-mounted)
```

## For AI/Automation Integration

The container is designed for programmatic control:

1. **Live Code Editing**: `./mygame/` is mounted read-write, changes hot-reload
2. **Screenshots**: Always available at `./screenshots/`
3. **Input**: Full keyboard and mouse support via xdotool
4. **Deterministic**: No audio, consistent 1280x720 display
5. **Scriptable**: All commands return exit codes

Example Python integration:

```python
import subprocess
import time

def screenshot(name="screenshot.png"):
    result = subprocess.run(
        ["./dr-control", "screenshot", name],
        capture_output=True, text=True
    )
    return f"./screenshots/{name}"

def send_key(key):
    subprocess.run(["./dr-control", key])

def click(x, y):
    subprocess.run(["./dr-control", "click", str(x), str(y)])

def wait(ms):
    subprocess.run(["./dr-control", "wait", str(ms)])

# Example: Navigate menu and screenshot
send_key("enter")
wait(1000)
click(640, 360)
wait(500)
screenshot("result.png")
```

## Troubleshooting

### Container won't start
```bash
# Check if Docker is running
docker info

# Check logs
./dr-control logs
```

### Game crashes on startup
```bash
# Check DragonRuby logs
./dr-control logs

# The game code in mygame/ may have errors
# DragonRuby will show Ruby exceptions in the logs
```

### Screenshots are black
- Wait longer for game to initialize (use `sleep 5` after start)
- Check if Xvfb is running: `docker exec dragonruby-game xdpyinfo`

### Input not working
- Verify display is set: `docker exec dragonruby-game echo $DISPLAY`
- Test xdotool: `docker exec dragonruby-game xdotool getactivewindow`

### Apple Silicon (M1/M2/M3) Notes
The container uses the ARM64 Linux DragonRuby binary from `.dragonruby/stubs/linux-arm64` for native performance on Apple Silicon Macs.
