# scripts/managers/music_manager.gd
extends Node

# Referencia al AudioStreamPlayer
@onready var music_player: AudioStreamPlayer = $AudioStreamPlayer

# Variables de control
var current_music: String = ""
var is_paused: bool = false

func _ready() -> void:
	# Hacer que sea accesible globalmente
	name = "MusicManager"
	add_to_group("managers")

# Función para cambiar música
func play_music(music_path: String, loop: bool = true) -> void:
	"""Reproduce una pista de música"""
	
	# Si ya está tocando la misma música, no reiniciar
	if current_music == music_path and music_player.playing:
		return
	
	current_music = music_path
	
	var audio_stream = load(music_path)
	
	
	music_player.stream = audio_stream
	
	# Configurar loop
	if loop:
		audio_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	else:
		audio_stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	music_player.play()
	

# Función para pausar/reanudar música
func toggle_pause() -> void:
	"""Pausa o reanuda la música"""
	if music_player.playing:
		music_player.stream_paused = true
		is_paused = true
		
	else:
		music_player.stream_paused = false
		is_paused = false
		

# Función para detener música
func stop_music() -> void:
	"""Detiene la música"""
	music_player.stop()
	current_music = ""
	
