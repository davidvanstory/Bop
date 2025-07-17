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
@export var bounce_value: float = 0.99  # Slightly less than 1.0 to prevent energy accumulation bugs
@export var friction_value: float = 0.0
@export var linear_damping_value: float = 0.01  # Small damping to counteract energy accumulation

# Signals
signal hit

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
	print("Player: Starting position: ", global_position)
	print("Player: Gravity scale set to: ", gravity_scale)

	# Create and assign physics material
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = bounce_value
	physics_material.friction = friction_value
	physics_material_override = physics_material
	print("Player: Physics material - Bounce: ", bounce_value, ", Friction: ", friction_value)
	
	# Apply linear damping to the RigidBody2D 
	linear_damp = linear_damping_value
	
	# Set up sprite texture if provided
	if player_texture and sprite:
		sprite.texture = player_texture
		print("Player: Texture assigned to sprite")
	
	# Connect collision signals
	# Note: body_entered is for Area2D, RigidBody2D uses contact monitoring instead
	print("Player: Ready to detect collisions via _integrate_forces")
	
	print("Player: Initialization complete")
	
	# Give the ball a small initial push to start metronome oscillation
	# Start with a downward velocity to enter the lower gravity zone
	linear_velocity = Vector2(0, 400)
	print("Player: Applied initial downward velocity to start metronome motion")

func _physics_process(delta: float) -> void:
	"""Handle physics processing including movement input."""
	# Only process input if this is the authority in multiplayer (or single-player)
	if not is_multiplayer_authority():
		return
	
	# CRITICAL: Stop all input processing if player is dead
	if not is_alive:
		return
	
	# Get horizontal input using Input.get_axis for smooth movement
	var input_dir: float = Input.get_axis("move_left", "move_right")
	
	# Apply movement directly - each player controls their own character
	_apply_movement(input_dir, delta)

func _apply_movement(input_dir: float, delta: float) -> void:
	"""Apply movement based on input direction."""
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
	var time_stamp = Time.get_ticks_msec() / 1000.0
	
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
	
	# Store current position for death sprite
	var death_position = global_position
	
	# Hide the ball immediately
	hide_ball()
	
	# Show death sprite at the ball's last position
	show_death_sprite(death_position)
	
	# Emit hit signal for hazards to connect to
	hit.emit()
	
	# Play pop sound
	if has_node("/root/SoundManager"):
		get_node("/root/SoundManager").play_sfx("pop")
	
	# Emit signal to GameState for life management
	if has_node("/root/GameState"):
		get_node("/root/GameState").emit_signal("player_died")

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

func hide_ball() -> void:
	"""Hide the player ball when dead."""
	print("Player: Hiding ball")
	if sprite:
		sprite.visible = false
	
	# Immediately stop all movement and input processing
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	
	# Stop physics processing
	set_physics_process(false)
	
	# Defer the freeze operation to avoid "flushing queries" error
	# This must be deferred because we're in a collision callback
	call_deferred("_freeze_player_body")
	
	print("Player: Ball hidden, physics stopped, freeze deferred")

func _freeze_player_body() -> void:
	"""Freeze the player body after physics frame completes."""
	freeze = true
	print("Player: Body frozen successfully")

func halt_movement() -> void:
	"""Halt all player movement - used when level is completed."""
	print("Player: Halting all movement")
	is_alive = false
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	set_physics_process(false)
	set_process_input(false)
	call_deferred("_freeze_player_body")
	
func show_death_sprite(position: Vector2) -> void:
	"""Show death sprite at the specified position for 2 seconds."""
	print("Player: Showing death sprite at position: ", position)
	
	# Create a new Sprite2D node for the death animation
	var death_sprite = Sprite2D.new()
	death_sprite.texture = load("res://assets/sprites/player/death.png")
	death_sprite.global_position = position
	
	# Add it to the scene tree (parent it to the main scene)
	get_tree().current_scene.add_child(death_sprite)
	
	# Create a timer to remove the death sprite after 2 seconds
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	get_tree().current_scene.add_child(timer)
	
	# Connect timer timeout to remove death sprite
	timer.timeout.connect(func(): 
		print("Player: Removing death sprite")
		if death_sprite and is_instance_valid(death_sprite):
			death_sprite.queue_free()
		if timer and is_instance_valid(timer):
			timer.queue_free()
	)
	
	timer.start()
	print("Player: Death sprite timer started for 2 seconds")

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

 
