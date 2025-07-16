"""
Camera Controller for Bop Game
Follows the player horizontally while maintaining a fixed vertical position
to keep both ceiling and floor visible at all times.
"""
class_name CameraController
extends Camera2D

# Camera configuration
@export var target_player: Node2D
@export var fixed_y_position: float = 540.0  # Center of the level vertically
@export var follow_smoothing: float = 5.0  # How smoothly to follow horizontally
@export var horizontal_offset: float = 0.0  # Optional horizontal offset from player

# Camera bounds (optional - to prevent camera from going too far)
@export var min_x_position: float = -INF
@export var max_x_position: float = INF
@export var use_auto_bounds: bool = true  # Automatically calculate bounds from level
@export var bounds_margin: float = 480.0  # Margin from level edges (half screen width)

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
	if "is_alive" in target_player and not target_player.is_alive:
		print("CameraController: Player is dead, stopping camera movement")
		return
	
	# Calculate target horizontal position
	var target_x = target_player.global_position.x + horizontal_offset
	
	# Apply bounds if set
	if min_x_position != -INF:
		target_x = max(target_x, min_x_position)
	if max_x_position != INF:
		target_x = min(target_x, max_x_position)
	
	# Smoothly follow horizontally, keep fixed vertical position
	var current_pos = global_position
	current_pos.x = lerp(current_pos.x, target_x, follow_smoothing * delta)
	current_pos.y = fixed_y_position  # Always maintain fixed Y position
	
	global_position = current_pos
	
	# Debug logging (can be commented out in production)
	# print("CameraController: Position (", global_position.x, ", ", global_position.y, ") following player at (", target_player.global_position.x, ", ", target_player.global_position.y, ")")

func set_target_player(player: Node2D) -> void:
	"""Set the player to follow."""
	target_player = player
	print("CameraController: Target player set to ", player.name)

func set_fixed_y_position(y_pos: float) -> void:
	"""Set the fixed vertical position for the camera."""
	fixed_y_position = y_pos
	global_position.y = fixed_y_position
	print("CameraController: Fixed Y position set to ", y_pos)

func set_horizontal_bounds(min_x: float, max_x: float) -> void:
	"""Set horizontal movement bounds for the camera."""
	min_x_position = min_x
	max_x_position = max_x
	use_auto_bounds = false  # Disable auto bounds when manually set
	print("CameraController: Horizontal bounds manually set to (", min_x, ", ", max_x, ")")

func _calculate_level_bounds() -> void:
	"""Automatically calculate camera bounds based on level geometry."""
	print("CameraController: Calculating level bounds...")
	
	# Find the main scene (level)
	var level_scene = get_tree().current_scene
	if not level_scene:
		print("CameraController: No current scene found for bounds calculation")
		return
	
	# Look for walls or level boundaries
	var left_bound: float = INF
	var right_bound: float = -INF
	
	# Search for StaticBody2D nodes that could be walls
	var static_bodies = _find_static_bodies(level_scene)
	
	for body in static_bodies:
		# Check if this looks like a wall (has "Wall" in name)
		var body_name = body.name.to_lower()
		var body_pos = body.global_position
		
		print("CameraController: Checking StaticBody2D '", body.name, "' at position (", body_pos.x, ", ", body_pos.y, ")")
		
		if "wall" in body_name or "boundary" in body_name:
			# Determine if it's a left or right wall based on position and name
			if "left" in body_name:
				left_bound = min(left_bound, body_pos.x)
				print("CameraController: Found left wall '", body.name, "' at x = ", body_pos.x)
			elif "right" in body_name:
				right_bound = max(right_bound, body_pos.x)
				print("CameraController: Found right wall '", body.name, "' at x = ", body_pos.x)
			else:
				# Try to determine by position (assume level is around 1920 wide)
				if body_pos.x < 500:  # Likely left wall
					left_bound = min(left_bound, body_pos.x)
					print("CameraController: Detected left wall '", body.name, "' at x = ", body_pos.x)
				elif body_pos.x > 1400:  # Likely right wall
					right_bound = max(right_bound, body_pos.x)
					print("CameraController: Detected right wall '", body.name, "' at x = ", body_pos.x)
		else:
			# Skip non-wall StaticBody2D nodes (like floors, ceilings, platforms)
			print("CameraController: Skipping non-wall StaticBody2D '", body.name, "'")
	
	# Apply bounds with margin if we found walls
	if left_bound != INF and right_bound != -INF:
		min_x_position = left_bound + bounds_margin
		max_x_position = right_bound - bounds_margin
		print("CameraController: Auto-bounds set to (", min_x_position, ", ", max_x_position, ") with margin ", bounds_margin)
	else:
		# Fallback to default reasonable bounds for a 1920-wide level
		min_x_position = bounds_margin
		max_x_position = 1920.0 - bounds_margin
		print("CameraController: Using fallback bounds (", min_x_position, ", ", max_x_position, ")")

func _find_static_bodies(node: Node) -> Array:
	"""Recursively find all StaticBody2D nodes."""
	var found_nodes: Array = []
	
	if node is StaticBody2D:
		found_nodes.append(node)
	
	for child in node.get_children():
		found_nodes.append_array(_find_static_bodies(child))
	
	return found_nodes

func update_level_bounds() -> void:
	"""Public method to recalculate bounds when level changes."""
	if use_auto_bounds:
		_calculate_level_bounds()
		print("CameraController: Level bounds updated")

func set_bounds_margin(margin: float) -> void:
	"""Set the margin from level edges and recalculate bounds."""
	bounds_margin = margin
	if use_auto_bounds:
		_calculate_level_bounds()
	print("CameraController: Bounds margin set to ", margin) 