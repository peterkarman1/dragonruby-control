#!/bin/bash
# Send input to the game using xdotool
# Usage: send-input.sh <command> [args...]
#
# Commands:
#   key <keyname>       - Press a key (e.g., space, Return, Up, Down, Left, Right, a, b, etc.)
#   keydown <keyname>   - Hold down a key
#   keyup <keyname>     - Release a key
#   type <text>         - Type text
#   click <x> <y>       - Click at screen coordinates
#   rightclick <x> <y>  - Right-click at screen coordinates
#   mousemove <x> <y>   - Move mouse to coordinates
#   mousedown <button>  - Press mouse button (1=left, 2=middle, 3=right)
#   mouseup <button>    - Release mouse button
#   delay <ms>          - Wait for milliseconds

export DISPLAY=:99

case "$1" in
    key)
        xdotool key "$2"
        ;;
    keydown)
        xdotool keydown "$2"
        ;;
    keyup)
        xdotool keyup "$2"
        ;;
    type)
        shift
        xdotool type "$*"
        ;;
    click)
        xdotool mousemove "$2" "$3" click 1
        ;;
    rightclick)
        xdotool mousemove "$2" "$3" click 3
        ;;
    mousemove)
        xdotool mousemove "$2" "$3"
        ;;
    mousedown)
        xdotool mousedown "${2:-1}"
        ;;
    mouseup)
        xdotool mouseup "${2:-1}"
        ;;
    delay)
        sleep "$(echo "scale=3; $2/1000" | bc)"
        ;;
    combo)
        # For key combinations like ctrl+c, alt+tab, etc.
        shift
        xdotool key "$@"
        ;;
    *)
        echo "Usage: send-input.sh <command> [args...]"
        echo ""
        echo "Commands:"
        echo "  key <keyname>       - Press a key"
        echo "  keydown <keyname>   - Hold down a key"
        echo "  keyup <keyname>     - Release a key"
        echo "  type <text>         - Type text"
        echo "  click <x> <y>       - Click at coordinates"
        echo "  rightclick <x> <y>  - Right-click at coordinates"
        echo "  mousemove <x> <y>   - Move mouse"
        echo "  mousedown <btn>     - Press mouse button"
        echo "  mouseup <btn>       - Release mouse button"
        echo "  delay <ms>          - Wait milliseconds"
        echo "  combo <keys>        - Key combination (e.g., ctrl+c)"
        echo ""
        echo "Key names: space, Return, Escape, Up, Down, Left, Right,"
        echo "           Tab, BackSpace, Delete, Home, End, Page_Up, Page_Down,"
        echo "           F1-F12, a-z, 0-9, etc."
        exit 1
        ;;
esac
