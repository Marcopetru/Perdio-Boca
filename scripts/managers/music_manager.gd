# scripts/managers/music_manager.gd
extends Node

var music_player: AudioStreamPlayer3D  # ← CAMBIO: Ahora es AudioStreamPlayer3D
var current_music: String = ""

func _ready() -> void:
	print("🎵 MusicManager _ready() iniciado")
	
	# Obtener el AudioStreamPlayer3D
	music_player = get_node_or_null("AudioStreamPlayer3D")
	
	if music_player == null:
		print("❌ ERROR: AudioStreamPlayer3D no encontrado!")
		return
	
	print("✅ AudioStreamPlayer3D encontrado")

func play_music(music_path: String, loop: bool = true) -> void:
	"""Reproduce una pista de música"""
	
	print("🎵 Reproduciendo: ", music_path)
	
	if music_player == null:
		print("❌ music_player es NULL")
		return
	
	var audio_stream = load(music_path)
	if audio_stream == null:
		print("❌ No se pudo cargar: ", music_path)
		return
	
	# Parar música anterior
	if music_player.playing:
		music_player.stop()
	
	# Configurar y reproducir
	music_player.stream = audio_stream
	music_player.volume_db = 0.0
	
	if loop and audio_stream is AudioStreamWAV:
		audio_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	music_player.play()
	print("✅ Música iniciada")

func stop_music() -> void:
	if music_player:
		music_player.stop()
		current_music = ""
