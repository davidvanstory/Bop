"""
GameState Singleton
Manages global game state including lives, score, level progression, and player events.
Acts as an Event Bus for game-wide communication.
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
	
	# Connect internal signals
	player_died.connect(_on_player_died)
	hoop_collected.connect(_on_hoop_collected)
	
	# Set initial lives based on game mode
	_set_initial_lives()

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

func _restart_level() -> void:
	"""Restart the current level."""
	print("GameState: Restarting level...")
	# This will be implemented to reload the current scene
	# For now, just reset player state
	is_level_complete = false

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
