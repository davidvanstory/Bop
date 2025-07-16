"""
SoundManager Singleton
Handles all audio playback including sound effects and background music.
Provides a centralized system for managing game audio.
"""
extends Node

# Audio player references
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SfxPlayer

# Preloaded sound effects library
var sfx_library: Dictionary = {}

# Volume settings
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.8

func _ready() -> void:
	"""Initialize the SoundManager singleton."""
	print("SoundManager: Initializing...")
	
	# Set up audio players
	if music_player:
		music_player.volume_db = linear_to_db(music_volume * master_volume)
		print("SoundManager: Music player configured")
	
	if sfx_player:
		sfx_player.volume_db = linear_to_db(sfx_volume * master_volume)
		print("SoundManager: SFX player configured")
	
	# Load sound effects into library
	_load_sfx_library()
	
	print("SoundManager: Initialization complete")

func _load_sfx_library() -> void:
	"""Preload all sound effects into the library."""
	print("SoundManager: Loading SFX library...")
	
	# Load sound effects from the assets/audio/ directory
	var sfx_paths = {
		"bounce": "res://assets/audio/bounce.mp3",
		"pop": "res://assets/audio/pop.mp3",
		"coins": "res://assets/audio/coins.mp3",
		"success": "res://assets/audio/success.mp3"
	}
	
	for sfx_name in sfx_paths:
		var path = sfx_paths[sfx_name]
		if ResourceLoader.exists(path):
			var audio_stream = load(path) as AudioStream
			if audio_stream:
				sfx_library[sfx_name] = audio_stream
				print("SoundManager: Loaded SFX - ", sfx_name)
			else:
				print("SoundManager: Failed to load SFX - ", sfx_name)
		else:
			print("SoundManager: SFX file not found - ", path)
	
	print("SoundManager: SFX library loaded with ", sfx_library.size(), " sounds")

func play_sfx(sfx_name: String) -> void:
	"""Play a sound effect by name."""
	if not sfx_library.has(sfx_name):
		print("SoundManager: SFX not found - ", sfx_name)
		return
	
	if not sfx_player:
		print("SoundManager: SFX player not available")
		return
	
	print("SoundManager: Playing SFX - ", sfx_name)
	sfx_player.stream = sfx_library[sfx_name]
	sfx_player.play()

func play_music(music_stream: AudioStream, loop: bool = true) -> void:
	"""Play background music."""
	if not music_player:
		print("SoundManager: Music player not available")
		return
	
	print("SoundManager: Playing music")
	music_player.stream = music_stream
	music_player.stream.loop = loop
	music_player.play()

func stop_music() -> void:
	"""Stop background music."""
	if music_player:
		music_player.stop()
		print("SoundManager: Music stopped")

func set_master_volume(volume: float) -> void:
	"""Set the master volume (0.0 to 1.0)."""
	master_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()
	print("SoundManager: Master volume set to ", master_volume)

func set_music_volume(volume: float) -> void:
	"""Set the music volume (0.0 to 1.0)."""
	music_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()
	print("SoundManager: Music volume set to ", music_volume)

func set_sfx_volume(volume: float) -> void:
	"""Set the SFX volume (0.0 to 1.0)."""
	sfx_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()
	print("SoundManager: SFX volume set to ", sfx_volume)

func _update_volumes() -> void:
	"""Update audio player volumes based on current settings."""
	if music_player:
		music_player.volume_db = linear_to_db(music_volume * master_volume)
	
	if sfx_player:
		sfx_player.volume_db = linear_to_db(sfx_volume * master_volume)

func get_audio_data() -> Dictionary:
	"""Get current audio settings."""
	return {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"sfx_count": sfx_library.size()
	} 