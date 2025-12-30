#!/bin/bash
set -e

SCREENSHOT_DIR="/home/druser/screenshots"
CONTROL_FIFO="/home/druser/control/input.fifo"

# Start Xvfb (virtual framebuffer) with a reasonable resolution
echo "Starting Xvfb..."
Xvfb :99 -screen 0 1280x720x24 -ac +extension GLX +render -noreset &
XVFB_PID=$!

# Wait for Xvfb to be ready
sleep 2

# Verify display is working
if ! xdpyinfo -display :99 >/dev/null 2>&1; then
    echo "ERROR: Xvfb failed to start"
    exit 1
fi
echo "Xvfb started successfully"

# Create control FIFO for sending commands
rm -f "$CONTROL_FIFO"
mkfifo "$CONTROL_FIFO"

# Start VNC server if requested
if [ "$ENABLE_VNC" = "true" ]; then
    echo "Starting VNC server on port 5900..."
    x11vnc -display :99 -forever -shared -rfbport 5900 -bg -o /tmp/x11vnc.log
    echo "VNC server started - connect to localhost:5900"
fi

# Function to handle cleanup
cleanup() {
    echo "Cleaning up..."
    if [ -n "$DR_PID" ]; then
        kill $DR_PID 2>/dev/null || true
    fi
    kill $XVFB_PID 2>/dev/null || true
    rm -f "$CONTROL_FIFO"
    exit 0
}
trap cleanup SIGTERM SIGINT

# Check if DragonRuby exists
if [ ! -f "./dragonruby" ]; then
    echo "ERROR: dragonruby binary not found in /home/druser/game"
    echo "Make sure you mount the game directory with the Linux DragonRuby binary"
    exit 1
fi

# Make sure dragonruby is executable
chmod +x ./dragonruby 2>/dev/null || true

# Start DragonRuby
echo "Starting DragonRuby..."
./dragonruby &
DR_PID=$!

echo "DragonRuby started with PID $DR_PID"
echo ""
echo "=========================================="
echo "Game is running!"
echo "=========================================="
echo ""
echo "Available commands (use game-control.sh):"
echo "  screenshot              - Take a screenshot"
echo "  key <keyname>          - Press a key (e.g., 'key space', 'key Return')"
echo "  type <text>            - Type text"
echo "  click <x> <y>          - Click at coordinates"
echo "  mousemove <x> <y>      - Move mouse to coordinates"
echo ""
echo "Screenshots saved to: $SCREENSHOT_DIR"
echo ""

# Background process to handle input commands from FIFO
(
    while true; do
        if read -r cmd < "$CONTROL_FIFO"; then
            echo "Received command: $cmd"
            eval "$cmd" 2>&1 || echo "Command failed: $cmd"
        fi
    done
) &

# Wait for DragonRuby to exit
wait $DR_PID
echo "DragonRuby exited"
cleanup
