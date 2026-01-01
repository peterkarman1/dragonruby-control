---
name: dragonruby-control
description: Control and test DragonRuby games in Docker. Use when testing the game, taking screenshots, sending input (clicks, keypresses), debugging crashes, or playing the game. Triggers on: test game, screenshot, click, play game, debug, run game.
allowed-tools: Bash, Read
---

# DragonRuby Game Control

Control the DragonRuby game running in Docker for testing, debugging, and development.

## Container Management

```bash
./dr-control start              # Start game container
./dr-control stop               # Stop container
./dr-control restart            # Restart container
./dr-control logs               # View container logs
./dr-control build              # Rebuild Docker image
```

## Screenshots

Screenshots are saved to `./screenshots/` and can be read with the Read tool.

```bash
./dr-control screenshot                 # Auto-named screenshot
./dr-control screenshot myshot.png      # Named screenshot
```

After taking a screenshot, use the Read tool to view it:
```
Read ./screenshots/myshot.png
```

## Keyboard Input

```bash
# Navigation
./dr-control up
./dr-control down
./dr-control left
./dr-control right

# Actions
./dr-control space          # Confirm/select
./dr-control enter          # Confirm/start
./dr-control escape         # Back/menu

# Any key by name
./dr-control key F1
./dr-control key BackSpace
./dr-control key Tab
```

## Mouse Input

The screen resolution is 1280x720.

```bash
# Click at coordinates
./dr-control click 640 360      # Center of screen
./dr-control click 100 50       # Top left area
./dr-control click 1200 600     # Bottom right area

# Move mouse without clicking
./dr-control move 640 360
```

## Typing Text

```bash
./dr-control type "hello world"
./dr-control type "player1"
```

## Timing

```bash
./dr-control wait 1000          # Wait 1 second
./dr-control wait 500           # Wait 0.5 seconds
```

## State Inspection (Eval API)

Execute Ruby code in the running game via DragonRuby's HTTP eval API.

**Prerequisites:** Enable in `mygame/metadata/cvars.txt`:
```
webserver.enabled=true
webserver.port=9001
webserver.remote_clients=true
```

```bash
# Query state
./dr-control eval '$args.state'
./dr-control eval '$args.state.score'
./dr-control eval 'Kernel.tick_count'

# Modify state
./dr-control eval '$args.state.score = 1000'
./dr-control eval '$args.state.player.hp = 100'

# With test helpers (if implemented)
./dr-control eval 'AITestHelpers.to_json(AITestHelpers.summary)'
```

## Screen Coordinates Reference

- Resolution: 1280x720
- Center: (640, 360)
- Top-left: (0, 0)
- Top-right: (1280, 0)
- Bottom-left: (0, 720)
- Bottom-right: (1280, 720)

## Development Workflow

The `./mygame/` directory is live-mounted. Code changes auto-reload in DragonRuby.

1. Start the game: `./dr-control start`
2. Take screenshot to see current state: `./dr-control screenshot`
3. Read screenshot to identify issues: `Read ./screenshots/screenshot.png`
4. Fix code in `./mygame/*.rb`
5. Take another screenshot to verify: `./dr-control screenshot after_fix.png`

No rebuild needed for code changes.

## Example: Navigate and Test

```bash
# Start game and take initial screenshot
./dr-control start
./dr-control wait 3000
./dr-control screenshot 01_initial.png

# Navigate menu with keyboard
./dr-control enter
./dr-control wait 1000
./dr-control screenshot 02_after_enter.png

# Click a button on screen
./dr-control click 640 360
./dr-control wait 1000
./dr-control screenshot 03_after_click.png

# Continue navigating
./dr-control down
./dr-control wait 500
./dr-control space
./dr-control wait 2000
./dr-control screenshot 04_result.png
```

## Example: Debug a Crash

```bash
# Check logs for error messages
./dr-control logs

# Take screenshot to see error state
./dr-control screenshot error_state.png

# After fixing code, DragonRuby auto-reloads
# Take screenshot to verify fix
./dr-control screenshot after_fix.png
```
