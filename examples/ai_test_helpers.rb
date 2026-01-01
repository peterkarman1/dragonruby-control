# examples/ai_test_helpers.rb
# Generic template for AI-driven testing and debugging helpers
#
# USAGE:
# 1. Copy this file to your mygame/app/ directory
# 2. Require it in your main.rb: require 'app/ai_test_helpers.rb'
# 3. Customize the methods for your game's state structure
# 4. Query via: ./dr-control eval 'AITestHelpers.summary'
#
# NOTE: DragonRuby's mRuby doesn't have built-in JSON support,
# so we provide a to_json helper method.

module AITestHelpers
  class << self
    # ==========================================
    # JSON Serialization (mRuby doesn't have to_json)
    # ==========================================

    def to_json(obj)
      case obj
      when Hash
        pairs = obj.map { |k, v| "\"#{k}\":#{to_json(v)}" }
        "{#{pairs.join(',')}}"
      when Array
        items = obj.map { |v| to_json(v) }
        "[#{items.join(',')}]"
      when String
        "\"#{obj.gsub('"', '\\"').gsub("\n", '\\n')}\""
      when Symbol
        "\"#{obj}\""
      when Numeric
        obj.to_s
      when TrueClass, FalseClass
        obj.to_s
      when NilClass
        'null'
      else
        "\"#{obj.to_s.gsub('"', '\\"')}\""
      end
    end

    # ==========================================
    # State Queries - Customize for your game
    # ==========================================

    # Quick status summary
    # Example: ./dr-control eval 'AITestHelpers.to_json(AITestHelpers.summary)'
    def summary
      {
        tick: Kernel.tick_count,
        # CUSTOMIZE: Add your game's key state properties
        # scene: $game&.current_scene,
        # score: $args.state.score,
        # player_hp: $args.state.player&.hp,
        # enemies_count: ($args.state.enemies || []).count
      }
    end

    # Full state dump for debugging
    # Example: ./dr-control eval 'AITestHelpers.to_json(AITestHelpers.full_state_dump)'
    def full_state_dump
      {
        tick: Kernel.tick_count,
        # CUSTOMIZE: Add all state you want to inspect
        # scene: $game&.current_scene,
        # player: player_dump,
        # enemies: enemies_dump,
        # items: items_dump,
        # score: $args.state.score,
        # level: $args.state.level
      }
    end

    # ==========================================
    # State Modification - Customize for your game
    # ==========================================

    # Set a state value
    # Example: ./dr-control eval 'AITestHelpers.set_state(:score, 1000)'
    def set_state(key, value)
      $args.state.send("#{key}=", value)
      { key => value }
    end

    # Reset game state to defaults
    # Example: ./dr-control eval 'AITestHelpers.to_json(AITestHelpers.reset_state)'
    def reset_state
      # CUSTOMIZE: Reset your game's state
      # $args.state.score = 0
      # $args.state.level = 1
      # $args.state.player = nil
      # $args.state.enemies = []
      { reset: true }
    end

    # ==========================================
    # Scene Control - Customize for your game
    # ==========================================

    # Go to a specific scene
    # Example: ./dr-control eval 'AITestHelpers.to_json(AITestHelpers.goto_scene(:game))'
    def goto_scene(scene)
      # CUSTOMIZE: Implement scene transition for your game
      # $game.change_scene(scene)
      # OR
      # $args.state.next_scene = scene
      { scene: scene }
    end

    # Pause the game
    def pause
      # CUSTOMIZE: Implement pause for your game
      # $args.state.paused = true
      { paused: true }
    end

    # Unpause the game
    def unpause
      # CUSTOMIZE: Implement unpause for your game
      # $args.state.paused = false
      { paused: false }
    end

    # ==========================================
    # Test Scene Setup - Customize for your game
    # ==========================================

    # Create a minimal test scenario
    # Example: ./dr-control eval 'AITestHelpers.to_json(AITestHelpers.setup_test_scene)'
    def setup_test_scene
      reset_state
      # CUSTOMIZE: Set up a controlled test environment
      # spawn_player(640, 360)
      # $args.state.enemies = []
      # $args.state.score = 0
      { success: true }
    end

    # Spawn a test entity
    # Example: ./dr-control eval 'AITestHelpers.to_json(AITestHelpers.spawn_test_entity(:enemy, 100, 100))'
    def spawn_test_entity(type, x, y)
      # CUSTOMIZE: Spawn entities for testing
      # case type
      # when :enemy
      #   enemy = Enemy.new(x, y)
      #   $args.state.enemies ||= []
      #   $args.state.enemies << enemy
      #   { type: type, x: x, y: y }
      # when :item
      #   item = Item.new(x, y)
      #   $args.state.items ||= []
      #   $args.state.items << item
      #   { type: type, x: x, y: y }
      # end
      { type: type, x: x, y: y }
    end

    # ==========================================
    # Entity Helpers - Customize for your game
    # ==========================================

    # Damage the player
    # Example: ./dr-control eval 'AITestHelpers.to_json(AITestHelpers.damage_player(10))'
    def damage_player(amount)
      player = $args.state.player
      return { error: "No player" } unless player

      old_hp = player.hp
      # CUSTOMIZE: Apply damage to your player
      # player.take_damage(amount)
      # OR
      # player.hp = [player.hp - amount, 0].max
      { old_hp: old_hp, new_hp: player.hp, damage: amount }
    end

    # Heal the player
    def heal_player(amount = nil)
      player = $args.state.player
      return { error: "No player" } unless player

      # CUSTOMIZE: Heal your player
      # amount ||= player.max_hp - player.hp
      # player.hp = [player.hp + amount, player.max_hp].min
      { healed: amount }
    end

    # Clear all enemies
    def clear_enemies
      count = ($args.state.enemies || []).count
      $args.state.enemies = []
      { cleared: count }
    end

    private

    # ==========================================
    # Entity Dump Helpers - Customize for your game
    # ==========================================

    def player_dump
      p = $args.state.player
      return nil unless p
      {
        # CUSTOMIZE: Add your player's properties
        # hp: p.hp,
        # max_hp: p.max_hp,
        # x: p.x.to_i,
        # y: p.y.to_i,
        # level: p.level,
        # alive: p.alive?
      }
    end

    def enemies_dump
      ($args.state.enemies || []).map do |e|
        {
          # CUSTOMIZE: Add your enemy's properties
          # type: e.type,
          # hp: e.hp,
          # x: e.x.to_i,
          # y: e.y.to_i,
          # alive: e.alive?
        }
      end
    end
  end
end
