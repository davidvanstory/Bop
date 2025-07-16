"""
Game Over Screen Script for Bop Game
Handles input detection on the game over screen and returns to main menu.
Resets game state for a fresh start when returning to menu.
"""

class_name GameOver
extends Control

# UI Component References
@onready var game_over_label: Label = $MenuContainer/GameOverLabel
@onready var instruction_label: Label = $MenuContainer/InstructionLabel
@onready var background: ColorRect = $Background
@onready var fullscreen_button: Button = $FullScreenButton

func _ready() -> void:
	"""Initialize the game over screen."""
	print("GameOver: Game over screen initialized")
	
	# Configure Control node to receive input
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Configure background to receive mouse input as well
	if background:
		background.mouse_filter = Control.MOUSE_FILTER_PASS
		# Connect background gui_input as a backup method
		background.gui_input.connect(_on_background_input)
	
	# Connect fullscreen button as reliable fallback
	if fullscreen_button:
		fullscreen_button.pressed.connect(_on_fullscreen_button_pressed)
		print("GameOver: Fullscreen button connected")
	
	# Grab focus to ensure we can receive input
	grab_focus()
	
	# Set focusable to ensure we can receive keyboard input
	focus_mode = Control.FOCUS_ALL
	
	# Play game over sound effect if available
	if has_node("/root/SoundManager"):
		# Note: Could add a game over sound effect here if desired
		pass
	
	# Log current game state before reset
	if has_node("/root/GameState"):
		var game_state = get_node("/root/GameState")
		var game_data = game_state.get_game_data()
		print("GameOver: Final game state - Score: ", game_data.score, " Level: ", game_data.level, " Hoops: ", game_data.hoops)
	
	print("GameOver: Ready to receive input - click anywhere or press any key to return to menu")

func _input(event: InputEvent) -> void:
	"""Handle any input to return to main menu."""
	print("GameOver: Input event received: ", event)
	
	# Check for any key press or mouse click
	if event is InputEventKey and event.pressed:
		print("GameOver: Key pressed (", event.keycode, ") - returning to main menu")
		_return_to_menu()
	elif event is InputEventMouseButton and event.pressed:
		print("GameOver: Mouse button pressed (", event.button_index, ") - returning to main menu")
		_return_to_menu()
	elif event.is_action_pressed("ui_accept"):
		print("GameOver: UI accept pressed - returning to main menu")
		_return_to_menu()
	elif event.is_action_pressed("ui_cancel"):
		print("GameOver: UI cancel pressed - returning to main menu")
		_return_to_menu()

func _on_background_input(event: InputEvent) -> void:
	"""Backup input handler for background ColorRect."""
	print("GameOver: Background input received: ", event)
	
	# Handle mouse clicks on the background
	if event is InputEventMouseButton and event.pressed:
		print("GameOver: Background mouse click detected - returning to menu")
		_return_to_menu()

func _on_fullscreen_button_pressed() -> void:
	"""Handle fullscreen button press - most reliable input method."""
	print("GameOver: Fullscreen button pressed - returning to menu")
	_return_to_menu()

func _return_to_menu() -> void:
	"""Return to main menu and reset game state."""
	print("GameOver: Returning to main menu...")
	
	# Reset game state for next playthrough
	if has_node("/root/GameState"):
		var game_state = get_node("/root/GameState")
		game_state.reset_game()
		print("GameOver: Game state reset for new session")
	
	# Play button click sound if available
	if has_node("/root/SoundManager"):
		var sound_manager = get_node("/root/SoundManager")
		sound_manager.play_sfx("success")  # Use success sound for menu return
	
	# Transition back to main menu
	print("GameOver: Transitioning to main_menu.tscn")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

# Optional: Handle focus for accessibility
func _notification(what: int) -> void:
	"""Handle window notifications."""
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		# Ensure the game over screen can receive input when window gains focus
		grab_focus()
		print("GameOver: Window focused - ready for input") 