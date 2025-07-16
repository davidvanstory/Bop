Build the Main Menu
Goal: Create a functional main menu that launches the game and sets the game mode.

Step 1: Create the MainMenu.tscn Scene
    This is the new entry point for your entire game.
    Cursor Prompt:
    "Create a new scene named main_menu.tscn and save it in a new scenes/ui/ folder. The root node must be a Control node.
    Add a ColorRect as a child. Set its color to solid black and use the 'Layout' menu to set its anchors to 'Full Rect'.
    Add a VBoxContainer as a child of the ColorRect. Use the 'Layout' menu to center it on the screen ('Layout' -> 'Center').
    Inside the VBoxContainer, add a Label with the text 'Bop'. Use a custom font from the assets folder and set the font size to be very large, like 150.
    Below the title Label, add a Button node. Set its text to 'Start Game'."
    (Note: I've simplified this to just a "Start" button for now. We can easily add the 1-Player/2-Player selection later, but this gets the core flow working.)

Step 2: Create the main_menu.gd Script
    This script will handle the button press to start the game.
    Cursor Prompt:
    "Attach a new script named main_menu.gd to the root Control node of main_menu.tscn.
    In the script, get a reference to the 'Start Game' Button node using an @onready variable.
    Connect the button's pressed signal to a new function, for example _on_start_button_pressed.
    Inside the _on_start_button_pressed function, call get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn") to start the game."

Step 3: Set the Main Scene for the Project
    This tells Godot to launch your Main Menu when you run the project.
    Manual Instruction (This is best done by hand in the editor):
    Go to Project -> Project Settings....
    Navigate to the Application -> Run section.
    Find the Main Scene property.
    Click the folder icon and select your newly created res://scenes/ui/main_menu.tscn.
    Close the settings.

Testing: After this step, when you run your project, you should see your "Bop" title screen. Clicking the "Start Game" button should load and start level_1.tscn exactly as it did before.