"""
Main Menu Script for Bop Game
Handles the main menu UI interactions and scene transitions.
Provides entry point to the game with Start Game functionality.
"""

class_name MainMenu
extends Control

# UI Component References
@onready var start_button: Button = $MenuContainer/StartButton
@onready var title_label: Label = $MenuContainer/TitleLabel  
@onready var background_texture: TextureRect = $FutureBackgroundTexture

# Export variables for customization (future flexibility)
@export var background_image: Texture2D
@export var button_hover_sound: AudioStream
@export var button_click_sound: AudioStream

func _ready() -> void:
	print("MainMenu: Initializing main menu scene")
	
	# Connect button signals
	_setup_button_connections()
	
	# Configure future background image if provided
	_setup_background_texture()
	
	# Log initialization completion
	print("MainMenu: Menu initialization completed successfully")

func _setup_button_connections() -> void:
	"""Set up all button signal connections"""
	print("MainMenu: Connecting button signals")
	
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)
		print("MainMenu: Start button signal connected")
	else:
		print("MainMenu: ERROR - Start button not found!")

func _setup_background_texture() -> void:
	"""Configure background texture if provided (future feature)"""
	if background_image and background_texture:
		background_texture.texture = background_image
		background_texture.visible = true
		print("MainMenu: Background texture configured")
	else:
		print("MainMenu: Using default black background")

func _on_start_button_pressed() -> void:
	"""Handle start button press - transition to game level"""
	print("MainMenu: Start Game button pressed")
	
	# Play button click sound if available
	if button_click_sound:
		# Use SoundManager if available
		if SoundManager:
			SoundManager.play_sfx("button_click")
	
	# Transition to the level select screen instead of directly to a level
	print("MainMenu: Transitioning to level_select.tscn")
	get_tree().change_scene_to_file("res://scenes/ui/level_select.tscn")

# Handle input for accessibility (Enter key support)
func _unhandled_input(event: InputEvent) -> void:
	"""Handle keyboard input for menu navigation"""
	if event.is_action_pressed("ui_accept"):
		print("MainMenu: Enter key pressed - starting game")
		_on_start_button_pressed() 
