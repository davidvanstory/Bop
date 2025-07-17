"""
BaseSpike Hazard Script
Pure logic class for handling collision detection with the player and triggering death sequence.
Uses Area2D body_entered signal to detect when player touches the spike.
Provides reusable functionality for all spike variants through scene inheritance.
"""
class_name BaseSpike
extends Area2D

# Export variables for configuration
@export var damage_sound: AudioStream
@export var is_enabled: bool = true

func _ready() -> void:
	"""Initialize the spike hazard with collision detection."""
	print("BaseSpike: Initializing spike at position ", global_position)
	
	# Connect the body_entered signal to our collision handler
	body_entered.connect(_on_body_entered)
	
	# Make sure the Area2D is monitoring for bodies
	monitoring = true
	monitorable = true
	
	print("BaseSpike: Ready and monitoring for collisions")

func _on_body_entered(body: Node2D) -> void:
	"""Handle when a body enters the spike area."""
	print("BaseSpike: Body entered - ", body.name, " (type: ", body.get_class(), ")")
	
	# Check if it's the player and connect to its hit signal for immediate detection
	if body.is_in_group("player") and is_enabled:
		print("BaseSpike: Player detected! Connecting to hit signal and triggering collision")
		
		# Connect to the player's hit signal if not already connected
		if not body.hit.is_connected(_on_player_hit):
			body.hit.connect(_on_player_hit)
			print("BaseSpike: Connected to player hit signal")
		
		# Trigger the hazard collision immediately
		if body.has_method("_handle_hazard_collision"):
			print("BaseSpike: Calling player's hazard collision method")
			body._handle_hazard_collision()
		else:
			print("BaseSpike: Player missing _handle_hazard_collision method, triggering direct death")
			_trigger_player_death()

func _on_player_hit() -> void:
	"""Handle when the player emits a hit signal."""
	print("BaseSpike: Received player hit signal!")
	_trigger_player_death()

func _trigger_player_death() -> void:
	"""Trigger the player death sequence directly."""
	print("BaseSpike: Triggering player death sequence")
	
	# Play pop sound through SoundManager
	if has_node("/root/SoundManager"):
		get_node("/root/SoundManager").play_sfx("pop")
		print("BaseSpike: Pop sound triggered")
	
	# Emit signal to GameState for life management
	if has_node("/root/GameState"):
		get_node("/root/GameState").emit_signal("player_died")
		print("BaseSpike: Player death signal emitted")

func disable_spike() -> void:
	"""Temporarily disable the spike."""
	is_enabled = false
	modulate = Color(0.5, 0.5, 0.5, 0.5)  # Make it semi-transparent
	print("BaseSpike: Disabled")

func enable_spike() -> void:
	"""Re-enable the spike."""
	is_enabled = true
	modulate = Color.WHITE
	print("BaseSpike: Enabled") 
