# scripts/managers/music_manager.gd
extends Node

var music_player: AudioStreamPlayer
var current_music: String = ""

func _ready() -> void:
	# Obtener el AudioStreamPlayer
	music_player = get_node("AudioStreamPlayer")
	
	if music_player == null:
		return
	
	print("✅ MusicManager inicializado correctamente")

func play_music(music_path: String, loop: bool = true) -> void:
	"""Reproduce una pista de música con loop"""
	
	if music_player == null:
		return
	
	# Si ya está tocando la misma música, no reiniciar
	if current_music == music_path and music_player.playing:
		return
	
	current_music = music_path
	
	var audio_stream = load(music_path)
	
	if audio_stream == null:
		return
	
	# Configurar loop
	if loop and audio_stream is AudioStreamWAV:
		audio_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	music_player.stream = audio_stream
	music_player.play()
	

func stop_music() -> void:
	"""Detiene la música"""
	if music_player:
		music_player.stop()
		current_music = ""
