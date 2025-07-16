"""
Player Controller for Bop Game
Manages a bouncing ball with horizontal movement control.
Includes basic multiplayer hooks for future expansion.
"""
class_name Player
extends RigidBody2D

# Export variables for visual assets (following best practices)
@export var player_texture: Texture2D
@export var bounce_sound: AudioStream
@export var pop_sound: AudioStream

# Movement parameters
@export var horizontal_force: float = 60000.0
@export var max_horizontal_speed: float = 500.0

# Physics material properties (set via script for better control)
@export var bounce_value: float = 1
@export var friction_value: float = 0.0

# References to child nodes
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

# Multiplayer and state variables
var is_alive: bool = true
var last_collision_time: float = 0.0
var collision_cooldown: float = 0.1  # Prevent sound spam

func _ready() -> void:
	"""Initialize the player with proper settings."""
	
	print("Player: Initializing...")

	# Create and assign physics material
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = bounce_value
	physics_material.friction = friction_value
	physics_material_override = physics_material
	
	# Set up sprite texture if provided
	if player_texture and sprite:
		sprite.texture = player_texture
		print("Player: Texture assigned to sprite")
	
	# Connect collision signals
	# Note: body_entered is for Area2D, RigidBody2D uses contact monitoring instead
	print("Player: Ready to detect collisions via _integrate_forces")
	
	print("Player: Initialization complete")

func _physics_process(delta: float) -> void:
	"""Handle physics processing including movement input."""
	# Only process input if this is the authority in multiplayer (or single-player)
	if not is_multiplayer_authority():
		return
	
	# Get horizontal input using Input.get_axis for smooth movement
	var input_dir: float = Input.get_axis("move_left", "move_right")
	
	# Apply horizontal force if input detected
	if input_dir != 0.0:
		# Check if we're below max speed before applying more force
		if abs(linear_velocity.x) < max_horizontal_speed:
			var force_vector = Vector2(input_dir * horizontal_force * delta, 0.0)
			apply_central_force(force_vector)
			
		# Clamp velocity to prevent exceeding max speed
		if abs(linear_velocity.x) > max_horizontal_speed:
			linear_velocity.x = sign(linear_velocity.x) * max_horizontal_speed
	else:
		# EXPERIMENT: Stop horizontal movement immediately when no input
		linear_velocity.x = 0.0

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	"""Handle collision detection and sound effects."""
	# Check for collisions
	for i in range(state.get_contact_count()):
		var contact = state.get_contact_local_normal(i)
		var collider = state.get_contact_collider_object(i)
		
		# Detect floor/ceiling bounces (vertical collisions)
		if abs(contact.y) > 0.7:  # Mostly vertical collision
			_handle_bounce_collision()
		
		# Handle hazard collisions
		if collider and collider.is_in_group("hazards"):
			_handle_hazard_collision()

func _handle_bounce_collision() -> void:
	"""Handle normal bouncing collisions with sound effects."""
	var current_time = Time.get_time_dict_from_system()
	var time_stamp = current_time.hour * 3600 + current_time.minute * 60 + current_time.second + current_time.millisecond / 1000.0
	
	# Prevent sound spam with cooldown
	if time_stamp - last_collision_time > collision_cooldown:
		last_collision_time = time_stamp
		
		# Play bounce sound through SoundManager
		if has_node("/root/SoundManager"):
			get_node("/root/SoundManager").play_sfx("bounce")
			print("Player: Bounce collision detected, playing sound")

func _handle_hazard_collision() -> void:
	"""Handle collision with hazards (spikes, etc.)."""
	if not is_alive:
		return
		
	print("Player: Hit hazard! Triggering death sequence")
	is_alive = false
	
	# Play pop sound
	if has_node("/root/SoundManager"):
		get_node("/root/SoundManager").play_sfx("pop")
	
	# Emit signal to GameState for life management
	if has_node("/root/GameState"):
		get_node("/root/GameState").emit_signal("player_died")
	
	# Could add visual effects here (death animation, particle effects)

func _on_body_entered(body: Node) -> void:
	"""Handle Area2D body entered signals (for collectibles, power-ups)."""
	print("Player: Body entered detection: ", body.name)
	
	# Handle collectibles
	if body.is_in_group("collectibles"):
		print("Player: Collected item: ", body.name)
		# Let the collectible handle itself and notify GameState
	
	# Handle power-ups
	if body.is_in_group("powerups"):
		print("Player: Power-up collected: ", body.name)
		# Let the power-up handle itself and apply effects

# Multiplayer support methods
func set_player_id(id: int) -> void:
	"""Set the multiplayer player ID."""
	set_multiplayer_authority(id)
	print("Player: Set multiplayer authority to player ", id)

func get_position_data() -> Dictionary:
	"""Get position data for multiplayer synchronization."""
	return {
		"position": global_position,
		"velocity": linear_velocity,
		"angular_velocity": angular_velocity
	}

func apply_position_data(data: Dictionary) -> void:
	"""Apply position data from multiplayer synchronization."""
	global_position = data.position
	linear_velocity = data.velocity
	angular_velocity = data.angular_velocity 
