#!/bin/bash
# examples/custom_commands.sh
# Example game-specific commands to add to dr-control
#
# USAGE:
# Add these case statements to your dr-control script after the 'eval)' case.
# Customize them for your game's state structure.
#
# These examples assume you have AITestHelpers set up in your game.

# ==========================================
# Example: State Query Commands
# ==========================================

# Query player status
# Usage: ./dr-control player
player)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh 'AITestHelpers.to_json(AITestHelpers.player_dump)'
    ;;

# Query current score
# Usage: ./dr-control score
score)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh '$args.state.score.to_s'
    ;;

# Get quick game summary
# Usage: ./dr-control summary
summary)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh 'AITestHelpers.to_json(AITestHelpers.summary)'
    ;;

# Get full state dump
# Usage: ./dr-control full-state
full-state)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh 'AITestHelpers.to_json(AITestHelpers.full_state_dump)'
    ;;

# Query enemy count
# Usage: ./dr-control enemies
enemies)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh '($args.state.enemies || []).count.to_s'
    ;;

# ==========================================
# Example: State Modification Commands
# ==========================================

# Set score
# Usage: ./dr-control set-score 1000
set-score)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh "\$args.state.score = ${2:-0}"
    ;;

# Add health to player
# Usage: ./dr-control heal 50
heal)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh "AITestHelpers.to_json(AITestHelpers.heal_player(${2:-nil}))"
    ;;

# Damage player
# Usage: ./dr-control damage 25
damage)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh "AITestHelpers.to_json(AITestHelpers.damage_player(${2:-10}))"
    ;;

# Set level
# Usage: ./dr-control set-level 5
set-level)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh "\$args.state.level = ${2:-1}"
    ;;

# ==========================================
# Example: Scene Control Commands
# ==========================================

# Go to a scene
# Usage: ./dr-control goto menu
# Usage: ./dr-control goto game
goto)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh "AITestHelpers.to_json(AITestHelpers.goto_scene(:${2:-title}))"
    ;;

# Pause the game
# Usage: ./dr-control pause
pause)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh "AITestHelpers.to_json(AITestHelpers.pause)"
    ;;

# Unpause the game
# Usage: ./dr-control unpause
unpause)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh "AITestHelpers.to_json(AITestHelpers.unpause)"
    ;;

# ==========================================
# Example: Test Scene Commands
# ==========================================

# Setup a clean test scene
# Usage: ./dr-control test-setup
test-setup)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh "AITestHelpers.to_json(AITestHelpers.setup_test_scene)"
    ;;

# Spawn a test entity
# Usage: ./dr-control spawn enemy 100 200
spawn)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh "AITestHelpers.to_json(AITestHelpers.spawn_test_entity(:${2:-enemy}, ${3:-640}, ${4:-360}))"
    ;;

# Clear all enemies
# Usage: ./dr-control clear-enemies
clear-enemies)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh "AITestHelpers.to_json(AITestHelpers.clear_enemies)"
    ;;

# ==========================================
# Example: Logging Commands
# ==========================================

# Start state logging
# Usage: ./dr-control log-start
# Usage: ./dr-control log-start mysession.jsonl
log-start)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh "\$state_logger.start('${2:-}')"
    ;;

# Stop state logging
# Usage: ./dr-control log-stop
log-stop)
    check_container
    docker exec "$CONTAINER_NAME" eval.sh '$state_logger.stop'
    ;;

# ==========================================
# Example: Help Text Addition
# ==========================================

# Add this to the help section of dr-control:
#
# echo "State Queries:"
# echo "  player             Player status"
# echo "  score              Current score"
# echo "  summary            Quick game summary"
# echo "  full-state         Complete state dump"
# echo "  enemies            Enemy count"
# echo ""
# echo "State Modification:"
# echo "  set-score <n>      Set score"
# echo "  heal [n]           Heal player"
# echo "  damage <n>         Damage player"
# echo "  set-level <n>      Set level"
# echo ""
# echo "Scene Control:"
# echo "  goto <scene>       Go to scene"
# echo "  pause              Pause game"
# echo "  unpause            Unpause game"
# echo ""
# echo "Test Scene:"
# echo "  test-setup         Setup test scene"
# echo "  spawn <type> [x y] Spawn entity"
# echo "  clear-enemies      Clear all enemies"
# echo ""
# echo "Logging:"
# echo "  log-start [file]   Start state logging"
# echo "  log-stop           Stop logging"
