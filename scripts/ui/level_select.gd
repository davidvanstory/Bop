"""
Level Select Screen Script
Handles UI interactions for selecting a game level.
"""
extends Control

@onready var level_1_button: Button = $MenuContainer/Level1Button
@onready var level_2_button: Button = $MenuContainer/Level2Button
@onready var back_button: Button = $MenuContainer/BackButton

func _ready() -> void:
	"""Initialize the level select screen."""
	print("LevelSelect: Initializing level select screen")
	
	# Connect button signals
	if level_1_button:
		level_1_button.pressed.connect(_on_level_1_button_pressed)
	if level_2_button:
		level_2_button.pressed.connect(_on_level_2_button_pressed)
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)

func _on_level_1_button_pressed() -> void:
	"""Handle Level 1 button press."""
	print("LevelSelect: Level 1 selected")
	_start_level(1)

func _on_level_2_button_pressed() -> void:
	"""Handle Level 2 button press."""
	print("LevelSelect: Level 2 selected")
	_start_level(2)

func _on_back_button_pressed() -> void:
	"""Handle Back button press."""
	print("LevelSelect: Returning to main menu")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _start_level(level_number: int) -> void:
	"""Set the current level in GameState and transition to the level scene."""
	if GameState:
		GameState.current_level = level_number
		print("LevelSelect: Set GameState.current_level to ", level_number)
	
	var level_path = "res://scenes/levels/level_%d.tscn" % level_number
	print("LevelSelect: Transitioning to ", level_path)
	get_tree().change_scene_to_file(level_path)
