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

## State Inspection (Eval API)

DragonRuby includes an HTTP eval API for executing Ruby code in the running game. This enables AI assistants to query and modify game state programmatically.

### Setup

1. Enable the webserver in your game's `mygame/metadata/cvars.txt`:
   ```
   webserver.enabled=true
   webserver.port=9001
   webserver.remote_clients=true
   ```

2. The container already exposes port 9001 - no additional configuration needed.

3. Rebuild if needed: `./dr-control build`

### Basic Usage

```bash
# Query any game state
./dr-control eval '$args.state'
./dr-control eval '$args.state.score'
./dr-control eval 'Kernel.tick_count'

# Modify state
./dr-control eval '$args.state.score = 1000'
./dr-control eval '$args.state.player.hp = 100'

# Call methods
./dr-control eval '$args.state.enemies.count'
./dr-control eval '$game.current_scene'
```

### Creating Test Helpers

For complex games, create a helper module. See `examples/ai_test_helpers.rb` for a complete template.

```ruby
# mygame/app/ai_test_helpers.rb
module AITestHelpers
  class << self
    # mRuby doesn't have to_json, so we provide one
    def to_json(obj)
      case obj
      when Hash
        pairs = obj.map { |k, v| "\"#{k}\":#{to_json(v)}" }
        "{#{pairs.join(',')}}"
      when Array then "[#{obj.map { |v| to_json(v) }.join(',')}]"
      when String then "\"#{obj.gsub('"', '\\"')}\""
      when Symbol then "\"#{obj}\""
      when Numeric then obj.to_s
      when TrueClass, FalseClass then obj.to_s
      when NilClass then 'null'
      else "\"#{obj}\""
      end
    end

    def summary
      {
        tick: Kernel.tick_count,
        score: $args.state.score,
        player_hp: $args.state.player&.hp
      }
    end
  end
end
```

Then query via:
```bash
./dr-control eval 'AITestHelpers.to_json(AITestHelpers.summary)'
```

### State Logging

For continuous state capture, see `examples/state_logger.rb`. Add to your game:

```ruby
# In your tick method:
$state_logger&.update($args.state)
```

Control via:
```bash
./dr-control eval '$state_logger.start("session1.jsonl")'
# ... play game ...
./dr-control eval '$state_logger.stop'
```

Logs are saved to `mygame/logs/` as JSONL (one JSON object per line).

### Extending dr-control

Add game-specific commands to `dr-control`. See `examples/custom_commands.sh` for templates:

```bash
# Add after the 'eval)' case in dr-control:

score)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh '$args.state.score.to_s'
    ;;

set-score)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh "\$args.state.score = ${2:-0}"
    ;;
```

Then use:
```bash
./dr-control score
./dr-control set-score 5000
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
├── docker/
│   ├── entrypoint.sh       # Container startup script
│   ├── screenshot.sh       # Screenshot utility
│   ├── send-input.sh       # Input utility
│   ├── game-control.sh     # High-level control utility
│   └── eval.sh             # Ruby eval API utility
├── examples/
│   ├── ai_test_helpers.rb  # Template for game state helpers
│   ├── state_logger.rb     # Template for continuous logging
│   └── custom_commands.sh  # Example dr-control extensions
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
