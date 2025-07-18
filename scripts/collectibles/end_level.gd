extends Area2D

signal level_completed

func _ready():
	add_to_group("collectibles")
	add_to_group("end_level")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Halt the ball movement
		if body.has_method("halt_movement"):
			body.halt_movement()
		else:
			# Direct approach if method doesn't exist
			body.linear_velocity = Vector2.ZERO
			body.set_physics_process(false)
			body.set_process_input(false)
		
		# Halt the camera
		var camera = body.get_node_or_null("Camera2D")
		if camera and camera.has_method("halt_camera"):
			camera.halt_camera()
		elif camera:
			camera.set_physics_process(false)
		
		SoundManager.play_sfx("success")
		GameState.complete_level()
		visible = false
		set_deferred("monitoring", false)
