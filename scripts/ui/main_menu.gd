"""
Main Menu Script for Bop Game
Handles the main menu UI interactions, scene transitions, and multiplayer setup.
Provides entry points for single-player and multiplayer modes.
"""

class_name MainMenu
extends Control

# UI Component References
@onready var single_player_button: Button = $MenuContainer/SinglePlayerButton
@onready var host_button: Button = $MenuContainer/HostButton
@onready var join_button: Button = $MenuContainer/JoinButton
@onready var ip_address_edit: LineEdit = $MenuContainer/IPContainer/IPAddressEdit
@onready var title_label: Label = $MenuContainer/TitleLabel  
@onready var background_texture: TextureRect = $FutureBackgroundTexture

# Networking constants
const PORT = 7777

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
	
	# Connect multiplayer signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	
	# Log initialization completion
	print("MainMenu: Menu initialization completed successfully")

func _setup_button_connections() -> void:
	"""Set up all button signal connections"""
	print("MainMenu: Connecting button signals")
	
	if single_player_button:
		single_player_button.pressed.connect(_on_single_player_pressed)
		print("MainMenu: Single player button signal connected")
	
	if host_button:
		host_button.pressed.connect(_on_host_pressed)
		print("MainMenu: Host button signal connected")
	
	if join_button:
		join_button.pressed.connect(_on_join_pressed)
		print("MainMenu: Join button signal connected")

func _setup_background_texture() -> void:
	"""Configure background texture if provided (future feature)"""
	if background_image and background_texture:
		background_texture.texture = background_image
		background_texture.visible = true
		print("MainMenu: Background texture configured")
	else:
		print("MainMenu: Using default black background")

func _on_single_player_pressed() -> void:
	"""Handle single player button press - start single player game"""
	print("MainMenu: Single Player button pressed")
	
	# Play button click sound if available
	if button_click_sound and SoundManager:
		SoundManager.play_sfx("button_click")
	
	# Reset game state for new game session
	if GameState:
		GameState.set_game_mode("single")
		GameState.reset_game()
		print("MainMenu: Game state reset for single player session")
	
	# Transition to level 1
	print("MainMenu: Transitioning to level_1.tscn (single player)")
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func _on_host_pressed() -> void:
	"""Handle host button press - create multiplayer server"""
	print("MainMenu: Host button pressed")
	
	# Play button click sound if available
	if button_click_sound and SoundManager:
		SoundManager.play_sfx("button_click")
	
	# Create server
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT)
	
	if error == OK:
		multiplayer.set_multiplayer_peer(peer)
		print("MainMenu: Server created on port ", PORT)
		print("MainMenu: Server ID: ", multiplayer.get_unique_id())
		
		# Set game mode and reset state
		if GameState:
			GameState.set_game_mode("multi")
			GameState.reset_game()
		
		# Host starts the game immediately
		_start_multiplayer_game()
	else:
		print("MainMenu: ERROR - Failed to create server: ", error)

func _on_join_pressed() -> void:
	"""Handle join button press - connect to multiplayer server"""
	print("MainMenu: Join button pressed")
	
	# Play button click sound if available
	if button_click_sound and SoundManager:
		SoundManager.play_sfx("button_click")
	
	# Get IP address from input
	var ip_address = ip_address_edit.text
	print("MainMenu: Attempting to join host at ", ip_address, ":", PORT)
	
	# Create client
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip_address, PORT)
	
	if error == OK:
		multiplayer.set_multiplayer_peer(peer)
		print("MainMenu: Client created, connecting to ", ip_address)
	else:
		print("MainMenu: ERROR - Failed to create client: ", error)

func _on_peer_connected(id: int) -> void:
	"""Handle peer connection (called on server when client connects)"""
	print("MainMenu: Peer connected with ID: ", id)
	
	# Server should notify all clients to start the game
	if multiplayer.is_server():
		rpc("_start_multiplayer_game")

func _on_peer_disconnected(id: int) -> void:
	"""Handle peer disconnection"""
	print("MainMenu: Peer disconnected with ID: ", id)

func _on_connected_to_server() -> void:
	"""Handle successful connection to server (called on client)"""
	print("MainMenu: Successfully connected to server")
	print("MainMenu: Client ID: ", multiplayer.get_unique_id())
	
	# Set game mode for client
	if GameState:
		GameState.set_game_mode("multi")
		GameState.reset_game()

func _on_connection_failed() -> void:
	"""Handle failed connection to server"""
	print("MainMenu: ERROR - Connection to server failed")
	# Could add UI feedback here

@rpc("authority", "call_local")
func _start_multiplayer_game() -> void:
	"""Start the multiplayer game - called on all peers"""
	print("MainMenu: Starting multiplayer game")
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

# Handle input for accessibility (Enter key support)
func _unhandled_input(event: InputEvent) -> void:
	"""Handle keyboard input for menu navigation"""
	if event.is_action_pressed("ui_accept"):
		print("MainMenu: Enter key pressed - starting single player game")
		_on_single_player_pressed()