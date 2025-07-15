# Project Name
Bop

## Project Description
Bop is a 2D, rhythm-based platformer where the player controls the horizontal movement of a constantly bouncing ball. The objective is to navigate through a series of levels filled with obstacles and challenges without getting "popped." The game is designed for both single-player and a cooperative two-player mode, with a focus on skill, timing, and momentum.

## Target Audience
- Casual gamers looking for a simple "pick up and play" experience.
- Fans of skill-based, high-difficulty platformers (e.g., Geometry Dash, Super Meat Boy, Flappy Bird).
- Players who enjoy cooperative multiplayer challenges.

## Desired Features

### Core Gameplay Mechanics
- [X] **Player Control:** The player controls the ball's horizontal movement using left and right keys, with slight acceleration and deceleration.
- [X] **Automatic Bouncing:** The ball bounces automatically between the floor and ceiling at a steady, metronomic pace.
- [X] **Level Progression:** Players progress horizontally from a start point to an end point.
- [X] **Player Objective:** Collect optional golden hoops (3 per level) for a perfect score. The level can be completed without them.
- [X] **Lives System:**
    - [X] Single Player: 3 lives. Restart level on game over.
    - [X] Multiplayer: 5 shared lives. Restart level on game over.
- [X] **Secret Area Entry:** The player can hold the 'Right' key against specific, visually marked walls to phase into a hidden room.

### Player Character (The Ball)
- [X] **State:** Can be burst/destroyed by hazards.
- [X] **Physics & Interaction:**
    - [X] Hitbox is a perfect circle.
    - [X] Bounces off regular (non-hazardous) vertical walls.
    - [X] A squash-and-stretch animation occurs when hitting a surface.
    - [X] The ball disappears and the word "Pop!" appears when the ball touches a hazard.
    - [X] The ball changes color for the duration of an active power-up.

### Obstacles & Hazards
- [X] **Static Spikes:** Placed on the floor or ceiling.
- [X] **Moving Hazards:**
    - [X] Vertically moving knife/crusher.
    - [X] Rotating blade.

### Power-ups
- [X] **Slow Down:** The ball's vertical bounce frequency decreases for a limited time.
- [X] **Speed Up:** The ball's vertical bounce frequency increases for a limited time.
- [X] **Sink/Float:** Alters the ball's gravity/bounce height to access different paths.

### Level 1 Design: "The Basics"
- [ ] **Beat 1: Game Start & Level Intro**
    - [ ] A main menu screen appears with "1 Player" and "2 Player" options.
    - [ ] After selection, a "LEVEL 1" title card appears, showing the player's 3 lives.
- [ ] **Beat 2: Player Onboarding (Safe Zone)**
    - [ ] The level begins in a short, enclosed area with no hazards.
    - [ ] This space allows the player to safely get used to the automatic bouncing and the feel of the left/right controls.
- [ ] **Beat 3: First Obstacle**
    - [ ] The player encounters a short, simple stretch of floor spikes.
    - [ ] This section is designed to be passable with basic timing and teaches the player that hazards exist.
- [ ] **Beat 4: Power-Up Introduction**
    - [ ] The player encounters the "Slow Down" power-up (represented by a lock icon asset).
    - [ ] Upon collection, the ball changes color, the bounce speed visibly slows, and a timer appears on the HUD.
- [ ] **Beat 5: Power-Up Application**
    - [ ] The player faces a long corridor with spikes on both the ceiling and floor.
    - [ ] This section is intentionally very difficult or impossible at normal bounce speed, requiring the use of the "Slow Down" power-up to navigate safely.
- [ ] **Beat 6: Secret Area & Optional Challenge**
    - [ ] The player passes a section of the right-hand wall that has a subtle visual difference (e.g., a slightly different color or texture).
    - [ ] If the player holds the 'Right' key against this wall, they will pass through it into a hidden room. The screen goes black and they are transported to another room. 
    - [ ] Inside the secret room is one of the three "Golden Hoops" for the level.
    - [ ] The user exits the room by seeing that the rightmost wall of the room has the same subtle color change as before. When they press against it they are transported back to the regular path. 
- [ ] **Beat 7: Level Completion**
    - [ ] The main path ends with the level goal object: a net.
    - [ ] When the ball enters the net's hitbox, the level is marked as complete, and a "Level Clear" screen appears, showing the number of golden hoops collected.

## Design Requests
- [X] **Art Style:**
    - [X] TBD, but with a specific constraint: the floor and ceiling "lanes" the ball bounces between should be a calming red color.
- [X] **Sound Design & Music:**
    - [X] Satisfying "bop" sound on impact.
    - [X] Music with a strong, clear beat to complement the gameplay rhythm.
- [X] **UI/HUD (Heads-Up Display):**
    - [X] Clean and non-intrusive.
    - [X] Displays: number of lives, golden hoops collected, and a timer for active power-ups.

## Other Notes
- **Development Strategy & Stack:**
    - **Engine:** Godot Engine.
    - **Physics:** Utilize Godot's built-in 2D physics engine.
    - **State Management:** Global state (lives, score) will be managed using a Godot Autoload script (Singleton pattern).
    - **Focus:** Build the single-player version first.
- **Minimum Viable Product (MVP) Plan:**
    1. A single, non-scrolling screen.
    2. A ball that bounces automatically.
    3. Player can control horizontal movement.
    4. One hazard type (spikes).
    5. A "popped" state and a level restart mechanism.
- **Future Ideas / Suggestions:**
    - **Power-ups:** Invincibility/Shield, Shrink/Grow.
    - **Hazards:** Timed (retracting) spikes, simple tracking enemies, "sticky" surfaces.
    - **Multiplayer-Specific Challenges:** Co-op pressure plates, gated paths requiring teamwork.
    - **Networking:** When multiplayer is implemented, Godot's high-level networking API will be used.


    - Technical Architecture
    - Gameplay Design
    - Development Phases
    - Visual Style Guide


# Suggested Architecture for Level 1
    Initial Setup:
    - You have a MainMenu.tscn. When the player clicks "1 Player," you call get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn"). This unloads the menu and loads your Level 1 scene.

    Inside level_1.tscn:
    - This scene is much larger than the screen. It might be 10,000 pixels wide, but your game window is only 1920.
    - Your Player.tscn instance is placed at the starting coordinates.
    - You add a Camera2D node as a child of the Player node. This is the simplest way to ensure the camera always follows the player as it moves through the large level.

    Here’s how the beats play out in this single, continuous level scene:
    - Beat 2: Onboarding (Safe Zone): This is just a section of your TileMap near the start of the level with no hazards "painted" on it. The Camera2D follows the player through this area.
    - Beat 3: First Obstacle: Further to the right in the TileMap, you have placed instances of Spike.tscn. The player moves into this area, and the physics engine handles the collision.
    - Beat 4 & 5: Power-Up: You place a PowerUp.tscn (an Area2D) in the level. When the player's RigidBody2D overlaps with it, a signal is emitted. The Player script catches this signal, enters its "Slow-Mo" state, and the UI updates. The long corridor of spikes is simply the next part of the TileMap design.
    - Beat 6: Secret Area: This is the most interesting architectural choice.
    The Bad Way: Changing to a new "secret room scene." This is complex because you need to save the exact state of the main level (positions of all moving objects, etc.) and restore it when you come back.
    The Industry Best Practice: The "secret room" is just another section of your TileMap built far away from the main path in the same level_1.tscn file (e.g., at coordinates far above or below the main level). When the player phases through the secret wall:
    The wall's script detects the player.
    It calls a function that instantly changes the player's global_position to the entrance of the secret room.
    The Camera2D, being a child, instantly moves with it.
    When they exit the secret room, their global_position is set back to where they were on the main path. This is simple, fast, and requires no complex state saving.
    - Beat 7: Level Completion: At the very end of the level, you place an Area2D for the net. When the player enters, it emits a level_complete signal. A global script listens for this, saves progress, and then calls get_tree().change_scene_to_file() to load either a "Level Clear" screen or the next level file (level_2.tscn).