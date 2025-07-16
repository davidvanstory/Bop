"""
Spike Hazard Script
Handles collision detection with the player and triggers death sequence.
Uses Area2D body_entered signal to detect when player touches the spike.
"""
class_name Spike
extends Area2D

# Export variables for configuration
@export var damage_sound: AudioStream
@export var is_enabled: bool = true

func _ready() -> void:
	"""Initialize the spike hazard."""
	print("Spike: Initializing at position ", global_position)
	
	# Connect the body_entered signal to our collision handler
	body_entered.connect(_on_body_entered)
	
	# Make sure the Area2D is monitoring for bodies
	monitoring = true
	monitorable = true
	
	print("Spike: Ready and monitoring for collisions")

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