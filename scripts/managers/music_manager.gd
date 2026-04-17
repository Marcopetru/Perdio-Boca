# scripts/managers/music_manager.gd
extends Node

var music_player: AudioStreamPlayer
var current_music: String = ""

func _ready() -> void:
	print("🔍 MusicManager _ready() iniciado")
	
	# Obtener el AudioStreamPlayer
	music_player = get_node_or_null("AudioStreamPlayer")
	
	if music_player == null:
		print("❌ ERROR: AudioStreamPlayer no encontrado!")
		print("🔍 Hijos disponibles:", get_child_count())
		for child in get_children():
			print("  - ", child.name, " (", child.get_class(), ")")
		return
	
	print("✅ MusicManager inicializado - AudioStreamPlayer encontrado")

func play_music(music_path: String, loop: bool = true) -> void:
	"""Reproduce una pista de música con loop"""
	
	print("🔍 play_music() llamado con: ", music_path)
	
	if music_player == null:
		print("❌ ERROR: music_player es null en play_music()")
		return
	
	# Si ya está tocando la misma música, no reiniciar
	if current_music == music_path and music_player.playing:
		print("ℹ️ Música ya reproduciendo: ", music_path)
		return
	
	current_music = music_path
	
	print("📂 Cargando archivo: ", music_path)
	var audio_stream = load(music_path)
	
	if audio_stream == null:
		print("❌ ERROR: No se pudo cargar el archivo: ", music_path)
		return
	
	print("✅ Archivo cargado correctamente")
	print("🔍 Tipo de stream: ", audio_stream.get_class())
	
	# Configurar loop
	if loop:
		if audio_stream is AudioStreamWAV:
			audio_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			print("✅ Loop configurado para WAVE")
		else:
			print("⚠️ Stream no es WAV, no se configura loop")
	
	# Reproducir
	music_player.stream = audio_stream
	
	#Configurar volumen y asegurarse que no esté muted
	music_player.volume_db = 0.0  # Volumen normal
	music_player.bus = "Master"   # Enviar al bus Master
	
	music_player.play()

func stop_music() -> void:
	"""Detiene la música"""
	if music_player:
		music_player.stop()
		current_music = ""
		print("⏹️ Música detenida")
