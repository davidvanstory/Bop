"""
GameState Singleton
Manages global game state including lives, score, level progression, and player events.
Acts as an Event Bus for game-wide communication.
Handles level configuration including dimensions and layout parameters.
"""
extends Node

# Game state variables
var player_lives: int = 1
var current_score: int = 0
var current_level: int = 1
var game_mode: String = "single"  # "single" or "multi"
var hoops_collected: int = 0

# Player state
var players_alive: Array[bool] = [true, true]  # For multiplayer support
var is_game_over: bool = false
var is_level_complete: bool = false

# Level configuration data structure
# Each level can have different dimensions and layout parameters
var level_configs: Dictionary = {
	1: {
		"width_pixels": 11520,  # Total level width in pixels
		"width_tiles": 180,     # Width in tiles (11520 / 64 = 180)
		"left_wall_x": 50,      # Left wall position
		"right_wall_x": 11370,  # Right wall position  
		"gravity_zone_center_x": 5760,  # Center of gravity zones (width/2)
		"gravity_zone_width": 11520,    # Gravity zone width
		"camera_margin": 480    # Camera boundary margin
	},
	2: {
		"width_pixels": 7680,   # Future level 2 dimensions
		"width_tiles": 120,
		"left_wall_x": 50,
		"right_wall_x": 7630,
		"gravity_zone_center_x": 3840,
		"gravity_zone_width": 7680,
		"camera_margin": 480
	}
	# Add more levels as needed
}

# Signals for event bus communication
signal player_died
signal life_lost(remaining_lives: int)
signal game_over
signal level_complete
signal score_changed(new_score: int)
signal hoop_collected(value: int)
signal powerup_activated(type: String)

func _ready() -> void:
	"""Initialize GameState singleton."""
	print("GameState: Singleton initialized")
	print("GameState: Level configurations loaded for ", level_configs.size(), " levels")
	
	# Connect internal signals
	player_died.connect(_on_player_died)
	hoop_collected.connect(_on_hoop_collected)
	
	# Set initial lives based on game mode
	_set_initial_lives()

# Level Configuration Methods
func get_current_level_config() -> Dictionary:
	"""Get the configuration for the current level."""
	var config = level_configs.get(current_level, level_configs[1])  # Default to level 1 if not found
	print("GameState: Retrieved config for level ", current_level, " - Width: ", config.width_pixels, "px")
	return config

func get_level_width_pixels() -> int:
	"""Get the current level's width in pixels."""
	return get_current_level_config().width_pixels

func get_level_width_tiles() -> int:
	"""Get the current level's width in tiles."""
	return get_current_level_config().width_tiles

func get_left_wall_position() -> float:
	"""Get the current level's left wall X position."""
	return get_current_level_config().left_wall_x

func get_right_wall_position() -> float:
	"""Get the current level's right wall X position."""
	return get_current_level_config().right_wall_x

func get_gravity_zone_center() -> float:
	"""Get the current level's gravity zone center X position."""
	return get_current_level_config().gravity_zone_center_x

func get_gravity_zone_width() -> float:
	"""Get the current level's gravity zone width."""
	return get_current_level_config().gravity_zone_width

func get_camera_margin() -> int:
	"""Get the current level's camera boundary margin."""
	return get_current_level_config().camera_margin

func update_level_config(level: int, config: Dictionary) -> void:
	"""Update or add a level configuration."""
	level_configs[level] = config
	print("GameState: Updated config for level ", level)

func _set_initial_lives() -> void:
	"""Set initial lives based on game mode."""
	match game_mode:
		"single":
			player_lives = 1
		"multi":
			player_lives = 1  # Also using single life for multiplayer for now
		_:
			player_lives = 1
	
	print("GameState: Lives set to ", player_lives, " for ", game_mode, " player mode")

func set_game_mode(mode: String) -> void:
	"""Set the game mode (single or multi player)."""
	game_mode = mode
	_set_initial_lives()
	print("GameState: Game mode set to ", mode)

func _on_player_died() -> void:
	"""Handle player death."""
	print("GameState: Player died, processing life loss")
	
	if player_lives > 1:
		player_lives -= 1
		life_lost.emit(player_lives)
		print("GameState: Life lost, remaining lives: ", player_lives)
		
		# Restart level or reset player position
		_restart_level()
	else:
		player_lives = 0
		is_game_over = true
		game_over.emit()
		print("GameState: Game Over!")
		
		# Add 5-second delay before showing game over screen
		_start_game_over_timer()

func _on_hoop_collected(value: int) -> void:
	"""Handle hoop/collectible collection."""
	hoops_collected += 1
	current_score += value
	score_changed.emit(current_score)
	print("GameState: Hoop collected! Total: ", hoops_collected, " Score: ", current_score)

func add_score(points: int) -> void:
	"""Add points to the current score."""
	current_score += points
	score_changed.emit(current_score)
	print("GameState: Score increased by ", points, " Total: ", current_score)

func complete_level() -> void:
	"""Mark the current level as complete."""
	is_level_complete = true
	level_complete.emit()
	print("GameState: Level ", current_level, " complete!")
	
	# Start a 3-second timer before transitioning to level complete screen
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(_on_level_complete_timeout)
	timer.start()
	print("GameState: Starting 3-second level complete timer")

func _on_level_complete_timeout() -> void:
	"""Handle level complete timer timeout - transition to level complete screen."""
	print("GameState: Level complete timer expired - transitioning to level complete screen")
	get_tree().change_scene_to_file("res://scenes/ui/level_complete.tscn")

func next_level() -> void:
	"""Progress to the next level."""
	current_level += 1
	hoops_collected = 0
	is_level_complete = false
	print("GameState: Advanced to level ", current_level)

func reset_game() -> void:
	"""Reset game state for new game."""
	current_score = 0
	current_level = 1
	hoops_collected = 0
	is_game_over = false
	is_level_complete = false
	players_alive = [true, true]
	_set_initial_lives()
	print("GameState: Game reset")

func reset_game_state() -> void:
	"""Alias for reset_game to match existing UI code."""
	reset_game()

func _restart_level() -> void:
	"""Restart the current level."""
	print("GameState: Restarting level...")
	# This will be implemented to reload the current scene
	# For now, just reset player state
	is_level_complete = false

func _start_game_over_timer() -> void:
	"""Start a 5-second timer before transitioning to game over screen."""
	print("GameState: Starting 5-second game over timer")
	
	# Create timer node
	var timer = Timer.new()
	add_child(timer)
	
	# Configure timer
	timer.wait_time = 5.0
	timer.one_shot = true
	
	# Connect timeout signal
	timer.timeout.connect(_on_game_over_timeout)
	
	# Start the timer
	timer.start()
	print("GameState: Game over timer started - 5 seconds until transition")

func _on_game_over_timeout() -> void:
	"""Handle game over timer timeout - transition to game over screen."""
	print("GameState: Game over timer expired - transitioning to game over screen")
	get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")

func get_game_data() -> Dictionary:
	"""Get current game state data."""
	return {
		"lives": player_lives,
		"score": current_score,
		"level": current_level,
		"hoops": hoops_collected,
		"mode": game_mode,
		"game_over": is_game_over,
		"level_complete": is_level_complete
	} 
