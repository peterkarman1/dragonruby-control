# examples/state_logger.rb
# Generic template for continuous state logging
#
# USAGE:
# 1. Copy this file to your mygame/app/ directory
# 2. Require it in your main.rb: require 'app/state_logger.rb'
# 3. Customize the log_entry method for your game's state
# 4. Call $state_logger.update($args.state) in your game loop
# 5. Control via:
#    ./dr-control eval '$state_logger.start'
#    ./dr-control eval '$state_logger.stop'
#
# Logs are saved to mygame/logs/ as JSONL (one JSON object per line)

class StateLogger
  attr_reader :active, :log_file, :interval

  def initialize
    @active = false
    @log_file = nil
    @interval = 60  # Log every 60 frames (1 second at 60fps)
    @last_log = 0
  end

  # Start logging to a file
  # Example: ./dr-control eval '$state_logger.start("session1.jsonl")'
  def start(filename = nil)
    filename ||= "state_log_#{Time.now.to_i}.jsonl"
    @log_file = "logs/#{filename}"
    @active = true
    @last_log = 0
    ensure_log_directory
    log_header
    puts "[StateLogger] Started logging to #{@log_file}"
    { started: true, file: @log_file }
  end

  # Stop logging
  # Example: ./dr-control eval '$state_logger.stop'
  def stop
    was_active = @active
    @active = false
    puts "[StateLogger] Stopped logging" if was_active
    { stopped: true }
  end

  # Call this in your game loop (e.g., in tick method)
  # Example: $state_logger.update($args.state)
  def update(state)
    return unless @active
    return unless (Kernel.tick_count - @last_log) >= @interval

    log_entry(state)
    @last_log = Kernel.tick_count
  end

  # Change logging interval (in frames)
  def set_interval(frames)
    @interval = frames
    { interval: frames }
  end

  private

  def ensure_log_directory
    # DragonRuby creates directories automatically when writing files
  end

  def log_header
    $gtk.write_file(@log_file, "")  # Clear/create file
  end

  def log_entry(state)
    entry = build_entry(state)
    json = AITestHelpers.to_json(entry)
    $gtk.append_file(@log_file, json + "\n")
  rescue => e
    puts "[StateLogger] Error logging: #{e.message}"
  end

  # CUSTOMIZE: Build the log entry for your game
  def build_entry(state)
    {
      tick: Kernel.tick_count,
      timestamp: Time.now.to_i,
      # CUSTOMIZE: Add your game's state properties
      # scene: $game&.current_scene,
      # score: state.score,
      # player: player_snapshot(state.player),
      # enemies_count: (state.enemies || []).count,
      # level: state.level
    }
  end

  # CUSTOMIZE: Snapshot helper for complex objects
  def player_snapshot(player)
    return nil unless player
    {
      # hp: player.hp,
      # max_hp: player.max_hp,
      # x: player.x.to_i,
      # y: player.y.to_i,
      # alive: player.alive?
    }
  end
end

# Global instance for access via eval
# Start logging: ./dr-control eval '$state_logger.start'
# Stop logging:  ./dr-control eval '$state_logger.stop'
$state_logger = StateLogger.new
