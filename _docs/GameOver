Build the Game Over Screen
Now that you have a menu to return to, building the Game Over screen makes perfect sense.

Step 1: Create the GameOver.tscn Scene
    Cursor Prompt:
    "Create a new scene named game_over.tscn and save it in the scenes/ui/ folder. The root node must be a Control node.
    Add a ColorRect as a child for a black background, anchored to 'Full Rect'.
    Add a VBoxContainer as a child and center it on the screen.
    Add a Label to the VBoxContainer with the text "GAME OVER". Use a large font size.
    Add a second, smaller Label below it with the text "Click to Return to Menu"."

Step 2: Add the Transition Logic to GameState.gd
    This adds the 5-second delay after the last life is lost.
    Cursor Prompt:
    "Modify the _on_player_died function in scripts/singletons/GameState.gd.
    When the game_over signal is emitted, add a 5-second delay before changing scenes.
    After game_over.emit(), create a Timer node in code.
    Add this timer to the scene tree using add_child(timer).
    Set its wait_time to 5.0 and one_shot to true.
    Connect its timeout signal to a new function named _on_game_over_timeout.
    Start the timer.
    Inside _on_game_over_timeout, call get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn")."

Step 3: Add Return Logic to game_over.tscn
    Cursor Prompt:
    "Attach a new script to the root Control node of game_over.tscn. In this script, use the _unhandled_input function to detect any key press or mouse click. When input is detected, call get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn") and also call GameState.reset_game() to reset the lives and score for the next playthrough."
