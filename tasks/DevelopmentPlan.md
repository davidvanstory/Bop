"# Bop Game Development Plan

This document outlines a phased, incremental development plan for building the game 'Bop' in Godot 4.3. The plan focuses on starting with a Minimum Viable Product (MVP) as described in GameplayDesign.md, then adding features like menus, sounds, and full level elements. Each phase includes tasks, sub-tasks, and testing steps to ensure functionality is verifiable at every stage.

The plan adheres to the rules in physics.md, SFX.md, style.md, and multiplayer.md (noting that multiplayer is deferred until later phases, but with basic hooks added early for ease of integration). We prioritize single-player playability first, using autoloads like SoundManager and GameState, physics layers, and best practices like export variables and signals. Assets will be used from the assets/sprites/ folder as specified. Latency mitigation strategies (client-side prediction, server reconciliation, interpolation) from latency.md will be incorporated into multiplayer phases for smooth gameplay.

## [ ] Phase 1: Project Setup and MVP - Basic Bouncing Ball
**Goal:** Set up the Godot project with correct physics and get a ball bouncing automatically in a simple, non-scrolling scene with basic horizontal control. Include basic multiplayer hooks in player controls.


- [x] **Sub-task 1.1: Configure Project Settings**
  - [x] Set default gravity to 980 (or adjust to 1200 for tighter feel) in Project Settings > Physics > 2D.
  - [x] Set default linear damp to 0.
  - [x] Define physics layers: world, player, hazards, collectibles, phasewall.
  - [x] Add input actions for move_left and move_right if not already present (keyboard only).

- [x] **Sub-task 1.2: Create Player Scene (player.tscn in scenes/player/)**
  - [x] Root: RigidBody2D (Player node).
  - [x] Children: Sprite2D with ball.png texture from assets/sprites/player/ (use @export for texture).
  - [x] CollisionShape2D with CircleShape2D for hitbox.
  - [x] Assign PhysicsMaterial with bounce=0.99, friction=0.1.
  - [x] Set mass=1, gravity_scale=1.0, linear_damping=0.5 for smooth horizontal movement.
  - [x] Script: player.gd with _physics_process for horizontal input (Input.get_axis('move_left', 'move_right')) and apply force/velocity. Include basic multiplayer hook: Use is_multiplayer_authority() to process input only for the controlling player.

- [x] **Sub-task 1.3: Create MVP Test Scene (mvp_test.tscn in scenes/levels/)**
  - [x] Add TileMapLayer for simple floor and ceiling (use ground_stone.png from assets/sprites/environment/, modulate to red).
  - [x] Instance Player at starting position.
  - [x] Add StaticBody2D for walls/floor/ceiling with collision shapes.
  - [x] No camera following for non-scrolling MVP.

- [x] **Sub-task 1.4: Implement Metronome Gravity Zones**
  - [x] Create Upper Gravity Zone (Area2D) from y=0 to y=540 with upward gravity (-980).
  - [x] Create Lower Gravity Zone (Area2D) from y=540 to y=1080 with downward gravity (+980).
  - [x] Use space_override = SPACE_OVERRIDE_REPLACE in both zones.
  - [x] Modify player spawn position to midpoint (y=540) for immediate oscillation.
  - [x] Set player gravity_scale to 0 (let zones handle all gravity).
  - [x] Ensure perfect bounce (1.0) for perpetual motion.

- [ ] **Sub-task 1.5: Testing**
  - [ ] Run the scene: Ball should oscillate automatically between floor and ceiling like a metronome.
  - [ ] Test horizontal movement: Smooth acceleration/deceleration with left/right keys.
  - [ ] Verify: Gravity reverses at midpoint, consistent metronome rhythm. Multiplayer hook doesn't affect single-player.

## [ ] Phase 2: Add Sound Effects to MVP
**Goal:** Integrate sound for bouncing and basic events, using SoundManager.


- [ ] **Sub-task 2.1: Set Up SoundManager (if not already)**
  - [ ] Create SoundManager.tscn in scripts/singletons/ with AudioStreamPlayer nodes for MusicPlayer and SfxPlayer.
  - [ ] Script: SoundManager.gd with sfx_library (preload bounce.mp3, pop.mp3, etc.).
  - [ ] Add as autoload in Project Settings.

- [ ] **Sub-task 2.2: Add Bounce Sound to Player**
  - [ ] In player.gd, detect collisions (use _integrate_forces or body_entered signal).
  - [ ] Call SoundManager.play_sfx('bounce') on floor/ceiling collision.

- [ ] **Sub-task 2.3: Testing**
  - [ ] Run MVP scene: Hear 'bop' sound on each bounce.
  - [ ] Verify: Sound plays correctly without overlap or errors.

## [ ] Phase 3: Main Menu and Loading Screen
**Goal:** Create menu for player selection and a loading/title screen before levels.


- [ ] **Sub-task 3.1: Create Main Menu Scene (main_menu.tscn in scenes/main_menu/)**
  - [ ] Use Control nodes for UI.
  - [ ] Add buttons for '1 Player' and '2 Player'.
  - [ ] Script: Handle button presses to set game mode (use GameState autoload to store mode).
  - [ ] Set as main scene in project.godot.

- [ ] **Sub-task 3.2: Create Loading Screen (loading_screen.tscn in scenes/ui/)**
  - [ ] Simple scene with 'LEVEL 1' label and lives display (use GameState for lives).
  - [ ] Timer to auto-transition to level after a few seconds.
  - [ ] From menu, change_scene to loading_screen, then to level.

- [ ] **Sub-task 3.3: Integrate with MVP**
  - [ ] From menu, load mvp_test.tscn after loading screen.

- [ ] **Sub-task 3.4: Testing**
  - [ ] Run game: Menu appears, select mode, see loading screen, then MVP scene.
  - [ ] Verify: Correct lives shown (3 for single, 5 for multi).

## [ ] Phase 4: Flesh Out Full Level 1
**Goal:** Expand to full scrolling level with hazards, power-ups, phase wall, coins, and goal.


- [ ] **Sub-task 4.1: Create Full Level Scene (level_1.tscn in scenes/levels/)**
  - [ ] Use TileMapLayer for extended level layout (safe zone, obstacles).
  - [ ] Add Camera2D as child of Player for following (now enabling scrolling).
  - [ ] Place static spikes (StaticBody2D with spike_bottom.png from assets/sprites/hazards/, hazards layer).

- [ ] **Sub-task 4.2: Add Hazards and Pop Effect**
  - [ ] Create Spike.tscn in scenes/hazards/ with collision detection.
  - [ ] On collision with player (use groups 'hazards'), trigger pop: Play 'pop' sound, show 'Pop!' label, deduct life via GameState, restart level.

- [ ] **Sub-task 4.3: Add Power-Ups and Collectibles**
  - [ ] Create PowerUp.tscn (Area2D) with jetpack.png from assets/sprites/collectibles_and_powerups/, signal on body_entered to apply effect (change gravity_scale).
  - [ ] Create Coin.tscn with animated gold sprites from assets/sprites/collectibles_and_powerups/, collect on overlap, update score in GameState.

- [ ] **Sub-task 4.4: Implement Phase Wall and Secret Area**
  - [ ] Use special tile for phase wall (platformPack_tile034.png from assets/sprites/environment/, phasewall layer).
  - [ ] Script to detect prolonged right-key press against it, teleport player to secret area (offset position in same scene).
  - [ ] Place coin in secret, teleport back on exit.

- [ ] **Sub-task 4.5: Level Completion**
  - [ ] Add goal Area2D (net, using appropriate asset), on enter emit signal to GameState, transition to 'Level Clear' screen showing hoops collected.
  - [ ] Create level_clear.tscn in scenes/ui/ for the clear screen.

- [ ] **Sub-task 4.6: Testing**
  - [ ] Run full level: Navigate sections, collect items, enter secret, avoid hazards, reach goal, see Level Clear screen.
  - [ ] Verify all physics, sounds, and transitions work.

## [ ] Phase 5: Polish and Multiplayer Hooks
**Goal:** Add HUD, power-up timer, and basic multiplayer setup with latency mitigation.

### [ ] Tasks:
- [ ] **Sub-task 5.1: Add HUD**
  - [ ] CanvasLayer in level with lives, hoops, power-up timer.

- [ ] **Sub-task 5.2: Full Power-Ups**
  - [ ] Implement Slow Down (adjust bounce freq), Speed Up, Sink/Float.

- [ ] **Sub-task 5.3: Multiplayer Basics**
  - [ ] If selected in menu, use MultiplayerSpawner for second player.
  - [ ] Sync positions with MultiplayerSynchronizer, handle shared lives.
  - [ ] Implement client-side prediction: In player.gd _physics_process, apply immediate movement for authority player and submit input via RPC.
  - [ ] Add server reconciliation: Compare predicted vs. authoritative position and correct if needed.
  - [ ] Use interpolation via MultiplayerSynchronizer for non-authority players.

- [ ] **Sub-task 5.4: Testing**
  - [ ] Test single and multi-player modes, ensure sync, no desyncs, and smooth movement despite simulated latency.

## Next Phases
- Phase 6: Additional Levels and Power-Ups
- Phase 7: Full Multiplayer Implementation (following multiplayer.mdc, and latency.md expanding on latency mitigation)
- Phase 8: Optimization, Bug Fixes, and Release

This plan ensures incremental builds with testing at each phase. We'll implement step-by-step using Godot tools." 