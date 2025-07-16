"""
Camera Controller for Bop Game
Follows the player horizontally while maintaining a fixed vertical position
to keep both ceiling and floor visible at all times.
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

# Will be set from GameState level configuration
var bounds_margin: float = 480.0  # Default, overridden by GameState

func _ready() -> void:
	"""Initialize the camera controller."""
	print("CameraController: Initializing...")
	
	# If no target is set, try to find the player automatically
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
	if not target_player:
		return
	
	# Stop following if the player is dead
	if target_player.has_method("is_alive") and not target_player.is_alive():
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
	
	# Keep camera at fixed vertical position
	global_position.y = fixed_y_position

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