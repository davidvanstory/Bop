"""
NetworkManager Singleton
Handles multiplayer networking, player spawning, and synchronization.
Manages player connections and disconnections in multiplayer mode.
"""
extends Node

# Player data structure
var players: Dictionary = {}  # {peer_id: player_data}
var player_spawn_positions: Array[Vector2] = [
	Vector2(960, 540),   # Player 1 start position
	Vector2(1100, 540)   # Player 2 start position
]

# References
var player_spawner: MultiplayerSpawner = null
var current_level: Node2D = null

# Signals
signal player_spawned(peer_id: int, player_node: Node2D)
signal player_removed(peer_id: int)

func _ready() -> void:
	"""Initialize NetworkManager singleton."""
	print("NetworkManager: Singleton initialized")
	
	# Connect multiplayer signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func setup_level(level: Node2D) -> void:
	"""Called when a level is loaded to set up multiplayer spawning."""
	current_level = level
	print("NetworkManager: Setting up level for multiplayer")
	
	# Find the player spawner in the level
	player_spawner = level.get_node_or_null("PlayerSpawner")
	if not player_spawner:
		print("NetworkManager: WARNING - No PlayerSpawner found in level")
		return
	
	# Configure spawner
	player_spawner.spawn_function = _spawn_player
	print("NetworkManager: PlayerSpawner configured")
	
	# Spawn players based on game mode
	if GameState.game_mode == "multi":
		_handle_multiplayer_spawning()
	else:
		_spawn_single_player()

func _spawn_single_player() -> void:
	"""Spawn a single player for single-player mode."""
	print("NetworkManager: Spawning single player")
	
	# Find existing player or create new one
	var existing_player = current_level.get_node_or_null("Player")
	if existing_player:
		print("NetworkManager: Using existing player in scene")
		existing_player.name = "player_1"
		existing_player.position = player_spawn_positions[0]
	else:
		# Spawn new player
		var player_scene = load("res://scenes/player/player.tscn")
		var player = player_scene.instantiate()
		player.name = "player_1"
		player.position = player_spawn_positions[0]
		current_level.add_child(player)
		print("NetworkManager: Single player spawned at ", player_spawn_positions[0])

func _handle_multiplayer_spawning() -> void:
	"""Handle spawning for multiplayer mode."""
	print("NetworkManager: Handling multiplayer spawning")
	
	# Remove any existing single player
	var existing_player = current_level.get_node_or_null("Player")
	if existing_player:
		existing_player.queue_free()
		print("NetworkManager: Removed existing single player")
	
	if multiplayer.is_server():
		# Server spawns itself first
		_spawn_player_for_peer(1)  # Server always has ID 1
		
		# Then spawn any already connected clients
		for peer_id in multiplayer.get_peers():
			_spawn_player_for_peer(peer_id)
	else:
		# Client notifies server that level is ready
		print("NetworkManager: Client notifying server that level is ready")
		rpc_id(1, "_client_level_ready", multiplayer.get_unique_id())

func _spawn_player_for_peer(peer_id: int) -> void:
	"""Spawn a player for a specific peer ID."""
	if peer_id in players:
		print("NetworkManager: Player already spawned for peer ", peer_id)
		return
	
	print("NetworkManager: Spawning player for peer ", peer_id)
	
	# Determine spawn position (0 for host, 1 for client)
	var spawn_index = 0 if peer_id == 1 else 1
	var spawn_pos = player_spawn_positions[spawn_index]
	
	# Store player data
	players[peer_id] = {
		"peer_id": peer_id,
		"spawn_position": spawn_pos,
		"is_alive": true
	}
	
	# Use RPC to spawn on all clients
	if multiplayer.is_server():
		rpc("_spawn_player_on_clients", peer_id, spawn_pos)

@rpc("authority", "call_local", "reliable")
func _spawn_player_on_clients(peer_id: int, spawn_position: Vector2) -> void:
	"""RPC called on all clients to spawn a player."""
	print("NetworkManager: Spawning player ", peer_id, " at ", spawn_position)
	
	# Wait for level to be ready if needed
	if not current_level:
		print("NetworkManager: Waiting for level to be set...")
		await get_tree().process_frame
		if not current_level:
			print("NetworkManager: ERROR - No current level set!")
			return
	
	var player_scene = load("res://scenes/player/player.tscn")
	var player = player_scene.instantiate()
	
	# Set unique name based on peer ID
	player.name = "player_" + str(peer_id)
	player.position = spawn_position
	
	# Set the multiplayer authority
	player.set_multiplayer_authority(peer_id)
	
	# Add to scene
	current_level.add_child(player)
	
	# Store reference
	players[peer_id] = {
		"peer_id": peer_id,
		"spawn_position": spawn_position,
		"is_alive": true,
		"node": player
	}
	
	# Emit signal
	player_spawned.emit(peer_id, player)
	print("NetworkManager: Player ", peer_id, " spawned successfully")

func _spawn_player(data: Dictionary) -> Node:
	"""Spawn function called by MultiplayerSpawner (if using spawner)."""
	print("NetworkManager: Spawn function called with data: ", data)
	
	var player_scene = load("res://scenes/player/player.tscn")
	var player = player_scene.instantiate()
	
	if data.has("peer_id"):
		player.name = "player_" + str(data.peer_id)
		player.set_multiplayer_authority(data.peer_id)
	
	if data.has("position"):
		player.position = data.position
	
	return player

func _on_peer_connected(id: int) -> void:
	"""Handle peer connection - spawn player for new peer."""
	print("NetworkManager: Peer connected: ", id)
	
	# Only server handles spawning
	if multiplayer.is_server() and current_level:
		_spawn_player_for_peer(id)

func _on_peer_disconnected(id: int) -> void:
	"""Handle peer disconnection - remove their player."""
	print("NetworkManager: Peer disconnected: ", id)
	
	# Remove player node
	if id in players and players[id].has("node"):
		var player_node = players[id].node
		if is_instance_valid(player_node):
			player_node.queue_free()
	
	# Remove from players dictionary
	players.erase(id)
	player_removed.emit(id)

func _on_connected_to_server() -> void:
	"""Client successfully connected to server."""
	print("NetworkManager: Connected to server as peer ", multiplayer.get_unique_id())
	
	# Client will wait for server to spawn players after scene loads

func _on_server_disconnected() -> void:
	"""Server disconnected - return to menu."""
	print("NetworkManager: Server disconnected")
	players.clear()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func get_alive_players_count() -> int:
	"""Get the number of players still alive."""
	var count = 0
	for player_data in players.values():
		if player_data.is_alive:
			count += 1
	return count

func mark_player_dead(peer_id: int) -> void:
	"""Mark a player as dead."""
	if peer_id in players:
		players[peer_id].is_alive = false
		print("NetworkManager: Player ", peer_id, " marked as dead")

func are_all_players_dead() -> bool:
	"""Check if all players are dead."""
	if players.is_empty():
		return false
	
	for player_data in players.values():
		if player_data.is_alive:
			return false
	
	return true

func reset_players() -> void:
	"""Reset all player states."""
	for peer_id in players:
		players[peer_id].is_alive = true
	print("NetworkManager: All players reset")

@rpc("any_peer", "call_remote", "reliable")
func _client_level_ready(client_id: int) -> void:
	"""Called when a client has loaded the level and is ready for spawning."""
	if multiplayer.is_server():
		print("NetworkManager: Client ", client_id, " reports level is ready")
		
		# Spawn all existing players on the new client
		for peer_id in players.keys():
			rpc_id(client_id, "_spawn_player_on_clients", peer_id, players[peer_id].spawn_position)
		
		# Then spawn the new client for everyone
		_spawn_player_for_peer(client_id)

@rpc("any_peer", "call_remote", "reliable")
func request_game_start() -> void:
	"""Called by client to request game start from server."""
	if multiplayer.is_server():
		print("NetworkManager: Client requested game start")
		# Don't reload the scene - the host is already in the game!
		# Just tell the client to load the level
		var sender_id = multiplayer.get_remote_sender_id()
		rpc_id(sender_id, "start_multiplayer_game")

@rpc("authority", "call_local", "reliable")
func start_multiplayer_game() -> void:
	"""Start the multiplayer game - called on all peers."""
	print("NetworkManager: Starting multiplayer game")
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
