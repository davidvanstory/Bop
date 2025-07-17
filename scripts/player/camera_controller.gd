"""
Camera Controller for Bop Game
In multiplayer: Follows the leading player and pushes trailing players forward.
In single player: Follows the player horizontally while maintaining fixed vertical position.
Uses GameState level configuration for dynamic bounds.
"""
class_name CameraController
extends Camera2D

# Camera configuration
@export var target_player: Node2D
@export var fixed_y_position: float = 540.0  # Center of the level vertically
@export var follow_smoothing: float = 5.0  # How smoothly to follow horizontally
@export var horizontal_offset: float = 0.0  # Optional horizontal offset from player

# Camera bounds (dynamically set from GameState)
@export var min_x_position: float = -INF
@export var max_x_position: float = INF
@export var use_auto_bounds: bool = true  # Automatically calculate bounds from GameState

# Multiplayer camera settings
@export var push_margin: float = 100.0  # Distance from left edge where players get pushed
@export var lead_margin: float = 300.0  # Distance ahead of leading player

# Will be set from GameState level configuration
var bounds_margin: float = 480.0  # Default, overridden by GameState

# For multiplayer tracking
var all_players: Array[Node2D] = []
var is_multiplayer_camera: bool = false

func _ready() -> void:
	"""Initialize the camera controller."""
	print("CameraController: Initializing...")
	
	# Check if we're in multiplayer mode
	if GameState.game_mode == "multi":
		is_multiplayer_camera = true
		print("CameraController: Multiplayer mode detected")
		
		# For multiplayer, we need a shared camera not attached to any player
		if get_parent().name.begins_with("player_"):
			# This is a player-attached camera, disable it
			print("CameraController: Disabling player-attached camera in multiplayer")
			queue_free()
			return
	else:
		# Single player mode
		if not target_player:
			target_player = get_parent()
			print("CameraController: Using parent as target player")
		
		# Set initial position
		if target_player:
			global_position.x = target_player.global_position.x + horizontal_offset
			global_position.y = fixed_y_position
			print("CameraController: Initial position set to (", global_position.x, ", ", global_position.y, ")")
	
	# Make this camera current
	make_current()
	print("CameraController: Camera set as current")
	
	# Auto-calculate bounds if enabled
	if use_auto_bounds:
		_calculate_level_bounds()
		print("CameraController: Auto-bounds calculated")

func _process(delta: float) -> void:
	"""Update camera position each frame."""
	if is_multiplayer_camera:
		_update_multiplayer_camera(delta)
	else:
		_update_single_player_camera(delta)
	
	# Keep camera at fixed vertical position
	global_position.y = fixed_y_position

func _update_single_player_camera(delta: float) -> void:
	"""Update camera for single player mode."""
	if not target_player:
		return
	
	# Stop following if the player is dead
	if target_player.has_method("is_alive") and not target_player.is_alive:
		return
	
	# Calculate target horizontal position
	var target_x = target_player.global_position.x + horizontal_offset
	
	# Apply horizontal bounds if set
	if min_x_position != -INF and max_x_position != INF:
		target_x = clamp(target_x, min_x_position, max_x_position)
	
	# Smoothly move camera horizontally towards target
	if follow_smoothing > 0:
		global_position.x = lerp(global_position.x, target_x, follow_smoothing * delta)
	else:
		global_position.x = target_x

func _update_multiplayer_camera(delta: float) -> void:
	"""Update camera for multiplayer mode - follow leader, push followers."""
	# Find all alive players
	_update_player_list()
	
	if all_players.is_empty():
		return
	
	# Find the leading player (rightmost)
	var leading_player: Node2D = null
	var max_x: float = -INF
	
	for player in all_players:
		if player.has_method("is_alive") and not player.is_alive:
			continue
		if player.global_position.x > max_x:
			max_x = player.global_position.x
			leading_player = player
	
	if not leading_player:
		return
	
	# Camera follows the leader with some margin ahead
	var target_x = leading_player.global_position.x + lead_margin
	
	# Apply horizontal bounds
	if min_x_position != -INF and max_x_position != INF:
		target_x = clamp(target_x, min_x_position, max_x_position)
	
	# Smoothly move camera
	if follow_smoothing > 0:
		global_position.x = lerp(global_position.x, target_x, follow_smoothing * delta)
	else:
		global_position.x = target_x
	
	# Push trailing players if they fall too far behind
	var camera_left_edge = global_position.x - get_viewport_rect().size.x / 2 + push_margin
	
	for player in all_players:
		if player.has_method("is_alive") and not player.is_alive:
			continue
		if player.global_position.x < camera_left_edge:
			# Push the player forward
			player.global_position.x = camera_left_edge
			if player.has_method("linear_velocity"):
				player.linear_velocity.x = max(player.linear_velocity.x, 0)
			print("CameraController: Pushing player ", player.name, " forward")

func _update_player_list() -> void:
	"""Update the list of all players in the scene."""
	all_players.clear()
	var level = get_tree().current_scene
	if level:
		for child in level.get_children():
			if child.name.begins_with("player_") and child.has_method("is_alive"):
				all_players.append(child)

func _calculate_level_bounds() -> void:
	"""Calculate camera bounds from GameState level configuration."""
	print("CameraController: Calculating level bounds from GameState...")
	
	# Get level configuration from GameState
	var left_wall_x = GameState.get_left_wall_position()
	var right_wall_x = GameState.get_right_wall_position()
	bounds_margin = GameState.get_camera_margin()
	
	print("CameraController: Level walls - Left: ", left_wall_x, ", Right: ", right_wall_x)
	print("CameraController: Using camera margin: ", bounds_margin)
	
	# Set bounds with margin
	min_x_position = left_wall_x + bounds_margin
	max_x_position = right_wall_x - bounds_margin
	
	print("CameraController: Camera bounds set to (", min_x_position, ", ", max_x_position, ")")

func update_level_bounds() -> void:
	"""Public method to recalculate bounds when level changes."""
	if use_auto_bounds:
		_calculate_level_bounds()
		print("CameraController: Level bounds updated")

func set_bounds_margin(margin: float) -> void:
	"""Set the margin for camera bounds."""
	bounds_margin = margin
	if use_auto_bounds:
		_calculate_level_bounds()

func set_bounds(min_x: float, max_x: float) -> void:
	"""Manually set camera bounds."""
	min_x_position = min_x
	max_x_position = max_x
	print("CameraController: Manual bounds set to (", min_x_position, ", ", max_x_position, ")")

func get_bounds() -> Vector2:
	"""Get current camera bounds as Vector2(min_x, max_x)."""
	return Vector2(min_x_position, max_x_position)

func halt_camera() -> void:
	"""Halt camera movement - used when level is completed."""
	print("CameraController: Halting camera movement")
	set_physics_process(false)
	set_process(false) 