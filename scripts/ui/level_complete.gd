extends Control

@onready var level_complete_label: Label = $MenuContainer/LevelCompleteLabel

func _ready():
	if level_complete_label and GameState:
		level_complete_label.text = "LEVEL %d COMPLETE!" % GameState.current_level
	
	visible = true
	await get_tree().create_timer(3.0).timeout
	_return_to_menu()

func _input(event):
	if event is InputEventKey and event.pressed:
		_return_to_menu()
	elif event is InputEventMouseButton and event.pressed:
		_return_to_menu()

func _return_to_menu():
	GameState.reset_game_state()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")