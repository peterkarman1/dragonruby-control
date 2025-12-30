#!/bin/bash
# High-level game control script
# This provides convenient shortcuts for common game actions
#
# Usage: game-control.sh <command> [args...]

SCRIPT_DIR="$(dirname "$0")"

case "$1" in
    screenshot|ss)
        # Take a screenshot
        "$SCRIPT_DIR/screenshot.sh" "$2"
        ;;

    # Arrow keys
    up|w)
        "$SCRIPT_DIR/send-input.sh" key Up
        ;;
    down|s)
        "$SCRIPT_DIR/send-input.sh" key Down
        ;;
    left|a)
        "$SCRIPT_DIR/send-input.sh" key Left
        ;;
    right|d)
        "$SCRIPT_DIR/send-input.sh" key Right
        ;;

    # Common game keys
    space|select|confirm)
        "$SCRIPT_DIR/send-input.sh" key space
        ;;
    enter|start)
        "$SCRIPT_DIR/send-input.sh" key Return
        ;;
    escape|esc|back|menu)
        "$SCRIPT_DIR/send-input.sh" key Escape
        ;;
    tab)
        "$SCRIPT_DIR/send-input.sh" key Tab
        ;;

    # Letter keys
    [a-z])
        "$SCRIPT_DIR/send-input.sh" key "$1"
        ;;

    # Number keys
    [0-9])
        "$SCRIPT_DIR/send-input.sh" key "$1"
        ;;

    # Mouse actions
    click)
        "$SCRIPT_DIR/send-input.sh" click "$2" "$3"
        ;;
    move)
        "$SCRIPT_DIR/send-input.sh" mousemove "$2" "$3"
        ;;

    # Raw key
    key)
        shift
        "$SCRIPT_DIR/send-input.sh" key "$@"
        ;;

    # Type text
    type)
        shift
        "$SCRIPT_DIR/send-input.sh" type "$@"
        ;;

    # Delay
    wait|delay)
        "$SCRIPT_DIR/send-input.sh" delay "$2"
        ;;

    # Execute a sequence of commands from a file or stdin
    sequence|seq)
        if [ -f "$2" ]; then
            while IFS= read -r line || [ -n "$line" ]; do
                # Skip comments and empty lines
                [[ "$line" =~ ^#.*$ ]] && continue
                [[ -z "$line" ]] && continue
                echo "Executing: $line"
                "$0" $line
            done < "$2"
        else
            echo "Sequence file not found: $2"
            exit 1
        fi
        ;;

    # Help
    help|--help|-h|"")
        echo "Game Control Script"
        echo "==================="
        echo ""
        echo "Usage: game-control.sh <command> [args...]"
        echo ""
        echo "Screenshot:"
        echo "  screenshot [filename]  - Take a screenshot"
        echo "  ss [filename]          - Alias for screenshot"
        echo ""
        echo "Movement:"
        echo "  up, down, left, right  - Arrow keys"
        echo "  w, a, s, d             - WASD aliases"
        echo ""
        echo "Actions:"
        echo "  space, select, confirm - Space bar"
        echo "  enter, start           - Enter key"
        echo "  escape, esc, back      - Escape key"
        echo "  tab                    - Tab key"
        echo "  [a-z]                  - Single letter keys"
        echo "  [0-9]                  - Number keys"
        echo ""
        echo "Mouse:"
        echo "  click <x> <y>          - Click at coordinates"
        echo "  move <x> <y>           - Move mouse"
        echo ""
        echo "Advanced:"
        echo "  key <keyname>          - Press any key by name"
        echo "  type <text>            - Type text"
        echo "  wait <ms>              - Wait milliseconds"
        echo "  sequence <file>        - Run commands from file"
        echo ""
        echo "Examples:"
        echo "  game-control.sh screenshot"
        echo "  game-control.sh space"
        echo "  game-control.sh click 640 360"
        echo "  game-control.sh key F1"
        ;;

    *)
        echo "Unknown command: $1"
        echo "Use 'game-control.sh help' for usage"
        exit 1
        ;;
esac
