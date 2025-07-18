class_name SpikeMan
extends AnimatableBody2D

@export var speed: float = 75.0
@export var move_distance: float = 400.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# This property is crucial for AnimatableBody2D to have its movement
	# correctly registered by the physics engine when moved by script or tweens.
	sync_to_physics = true

	print("SpikeMan ready at position: ", global_position)
	print("SpikeMan patrol config - Speed: ", speed, ", Distance: ", move_distance)
	_start_tween()

func _start_tween() -> void:
	if speed <= 0 or move_distance <= 0:
		print("SpikeMan movement disabled: speed or move_distance is zero or less.")
		return

	var duration = move_distance / speed
	print("SpikeMan tween starting. Duration for one way: ", duration)
	
	var tween = create_tween().set_loops()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)

	var start_pos = position
	var end_pos = start_pos + Vector2(move_distance, 0)
	
	print("SpikeMan tween path: from ", start_pos, " to ", end_pos)

	# Move to target and flip
	tween.tween_property(self, "position", end_pos, duration)
	tween.tween_callback(_on_reached_end)

	# Move back to start and flip
	tween.tween_property(self, "position", start_pos, duration)
	tween.tween_callback(_on_reached_start)

func _on_reached_end() -> void:
	animated_sprite.flip_h = true
	print("SpikeMan reached end position: ", position)

func _on_reached_start() -> void:
	animated_sprite.flip_h = false
	print("SpikeMan returned to start position: ", position)