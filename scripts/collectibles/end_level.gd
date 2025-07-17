extends Area2D

signal level_completed

func _ready():
	add_to_group("collectibles")
	add_to_group("end_level")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		# In multiplayer, either player can complete the level
		if GameState.game_mode == "multi":
			# Halt all players
			var level = get_tree().current_scene
			if level:
				for child in level.get_children():
					if child.name.begins_with("player_") and child.has_method("halt_movement"):
						child.halt_movement()
			
			# Halt shared camera
			var shared_camera = level.get_node_or_null("SharedCamera")
			if shared_camera and shared_camera.has_method("halt_camera"):
				shared_camera.halt_camera()
		else:
			# Single player mode - original behavior
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
