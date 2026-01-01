#!/bin/bash
# eval.sh - Execute Ruby code in the running DragonRuby game
# Usage: eval.sh "ruby_code_here"
#
# Examples:
#   eval.sh '$args.state.score'
#   eval.sh '$args.state.player.hp = 100'
#   eval.sh 'Kernel.tick_count'

set -e

if [ -z "$1" ]; then
    echo "Usage: eval.sh \"ruby_code\""
    echo "Example: eval.sh '\$args.state.score'"
    exit 1
fi

CODE="$1"

# Escape the code for JSON (handle quotes and backslashes)
ESCAPED_CODE=$(printf '%s' "$CODE" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

# Send to DragonRuby eval endpoint
curl -s -H "Content-Type: application/json" \
     --data "{\"code\": \"$ESCAPED_CODE\"}" \
     -X POST http://localhost:9001/dragon/eval/ 2>/dev/null || echo "Error: Could not connect to DragonRuby (is the game running?)"
