

Architectural Flow
    Start Game: project.godot loads MainMenu.tscn.
    Player Clicks "Start": MainMenu.tscn tells GameState the game mode and then calls get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn").
    Player Dies (Last Life): In level_1.tscn, the player's death triggers a player_died signal on the GameState singleton.
    Game Over Logic: GameState detects this is the last life. It starts a 5-second timer.
    Transition to Game Over: After the timer finishes, GameState calls get_tree().change_scene_to_file("res://scenes/ui/game_over.tscn").
    Return to Menu: From the GameOver.tscn, the player will click a button to go back to the MainMenu.tscn, completing the loop.


