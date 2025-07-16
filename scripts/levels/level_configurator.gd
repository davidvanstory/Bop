"""
Level Configurator Script
Dynamically configures level components (walls, gravity zones) based on GameState level configuration.
Attaches to the root Level node and adjusts positions and sizes at runtime.
"""
extends Node2D

# Node references that will be configured
@onready var left_wall: StaticBody2D = $Environment/LeftWall
@onready var right_wall: StaticBody2D = $Environment/RightWall
@onready var upper_gravity_zone: Area2D = $GravityZones/UpperGravityZone
@onready var lower_gravity_zone: Area2D = $GravityZones/LowerGravityZone
@onready var upper_gravity_collision: CollisionShape2D = $GravityZones/UpperGravityZone/CollisionShape2D
@onready var lower_gravity_collision: CollisionShape2D = $GravityZones/LowerGravityZone/CollisionShape2D

func _ready() -> void:
	"""Configure level components based on GameState level configuration."""
	print("LevelConfigurator: Starting level configuration...")
	
	# Get level configuration from GameState
	var config = GameState.get_current_level_config()
	print("LevelConfigurator: Using configuration for level ", GameState.current_level)
	
	# Configure walls
	_configure_walls(config)
	
	# Configure gravity zones  
	_configure_gravity_zones(config)
	
	print("LevelConfigurator: Level configuration complete")

func _configure_walls(config: Dictionary) -> void:
	"""Configure wall positions based on level configuration."""
	var left_x = config.left_wall_x
	var right_x = config.right_wall_x
	
	print("LevelConfigurator: Configuring walls - Left: ", left_x, ", Right: ", right_x)
	
	# Update wall positions
	left_wall.position.x = left_x
	right_wall.position.x = right_x
	
	print("LevelConfigurator: Wall positions updated")

func _configure_gravity_zones(config: Dictionary) -> void:
	"""Configure gravity zone positions and sizes based on level configuration."""
	var center_x = config.gravity_zone_center_x
	var zone_width = config.gravity_zone_width
	
	print("LevelConfigurator: Configuring gravity zones - Center: ", center_x, ", Width: ", zone_width)
	
	# Update gravity zone positions (they should be centered)
	upper_gravity_zone.position.x = center_x
	lower_gravity_zone.position.x = center_x
	
	# Update gravity zone collision shape sizes
	if upper_gravity_collision.shape is RectangleShape2D:
		var upper_shape = upper_gravity_collision.shape as RectangleShape2D
		upper_shape.size.x = zone_width
		print("LevelConfigurator: Upper gravity zone width set to ", zone_width)
	
	if lower_gravity_collision.shape is RectangleShape2D:
		var lower_shape = lower_gravity_collision.shape as RectangleShape2D
		lower_shape.size.x = zone_width
		print("LevelConfigurator: Lower gravity zone width set to ", zone_width)
	
	print("LevelConfigurator: Gravity zones configured") 