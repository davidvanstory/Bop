"""
Spike Hazard Script
Handles collision detection with the player and triggers death sequence.
Uses Area2D body_entered signal to detect when player touches the spike.
Modular design supports multiple spike types through enum configuration.
"""
class_name Spike
extends Area2D

# Enum for different spike types
enum SpikeType {
	BOTTOM,
	TOP,
	BOTTOM_LARGE,
	TOP_LARGE
}

# Export variables for configuration
@export var type: SpikeType = SpikeType.BOTTOM
@export var damage_sound: AudioStream
@export var is_enabled: bool = true

# Node references
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	"""Initialize the spike hazard with appropriate texture and collision size."""
	print("Spike: Initializing ", SpikeType.keys()[type], " spike at position ", global_position)
	
	# Configure spike based on type
	_configure_spike_type()
	
	# Connect the body_entered signal to our collision handler
	body_entered.connect(_on_body_entered)
	
	# Make sure the Area2D is monitoring for bodies
	monitoring = true
	monitorable = true
	
	print("Spike: Ready and monitoring for collisions")

func _configure_spike_type() -> void:
	"""Configure the spike's texture and collision size based on its type."""
	var texture_path: String
	var collision_size: Vector2
	
	match type:
		SpikeType.BOTTOM:
			texture_path = "res://assets/sprites/hazards/bottom_spike.png"
			collision_size = Vector2(64, 64)
			print("Spike: Configuring as BOTTOM spike")
		SpikeType.TOP:
			texture_path = "res://assets/sprites/hazards/top_spike.png"
			collision_size = Vector2(64, 64)
			print("Spike: Configuring as TOP spike")
		SpikeType.BOTTOM_LARGE:
			texture_path = "res://assets/sprites/hazards/spikes_large_bottom.png"
			collision_size = Vector2(128, 64)
			print("Spike: Configuring as BOTTOM_LARGE spike")
		SpikeType.TOP_LARGE:
			texture_path = "res://assets/sprites/hazards/spikes_large_top.png"
			collision_size = Vector2(128, 64)
			print("Spike: Configuring as TOP_LARGE spike")
	
	# Load and set the texture
	var texture = load(texture_path)
	if texture:
		sprite.texture = texture
		print("Spike: Texture loaded successfully: ", texture_path)
	else:
		print("Spike: ERROR - Failed to load texture: ", texture_path)
	
	# Update collision shape size
	if collision_shape.shape is RectangleShape2D:
		var rect_shape = collision_shape.shape as RectangleShape2D
		rect_shape.size = collision_size
		print("Spike: Collision size set to ", collision_size)

func _on_body_entered(body: Node2D) -> void:
	"""Handle when a body enters the spike area."""
	print("Spike: Body entered - ", body.name, " (type: ", body.get_class(), ")")
	
	# Check if it's the player and connect to its hit signal for immediate detection
	if body.is_in_group("player") and is_enabled:
		print("Spike: Player detected! Connecting to hit signal and triggering collision")
		
		# Connect to the player's hit signal if not already connected
		if not body.hit.is_connected(_on_player_hit):
			body.hit.connect(_on_player_hit)
			print("Spike: Connected to player hit signal")
		
		# Trigger the hazard collision immediately
		if body.has_method("_handle_hazard_collision"):
			print("Spike: Calling player's hazard collision method")
			body._handle_hazard_collision()
		else:
			print("Spike: Player missing _handle_hazard_collision method, triggering direct death")
			_trigger_player_death()

func _on_player_hit() -> void:
	"""Handle when the player emits a hit signal."""
	print("Spike: Received player hit signal!")
	_trigger_player_death()

func _trigger_player_death() -> void:
	"""Trigger the player death sequence directly."""
	print("Spike: Triggering player death sequence")
	
	# Play pop sound through SoundManager
	if has_node("/root/SoundManager"):
		get_node("/root/SoundManager").play_sfx("pop")
		print("Spike: Pop sound triggered")
	
	# Emit signal to GameState for life management
	if has_node("/root/GameState"):
		get_node("/root/GameState").emit_signal("player_died")
		print("Spike: Player death signal emitted")

func disable_spike() -> void:
	"""Temporarily disable the spike."""
	is_enabled = false
	modulate = Color(0.5, 0.5, 0.5, 0.5)  # Make it semi-transparent
	print("Spike: Disabled")

func enable_spike() -> void:
	"""Re-enable the spike."""
	is_enabled = true
	modulate = Color.WHITE
	print("Spike: Enabled") 
