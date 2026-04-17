# scripts/levels/level_1_manager.gd
extends Node

func _ready() -> void:
	print("🎮 Level1Manager _ready() iniciado")
	
	# Reproducir música
	if MusicManager == null:
		print("❌ ERROR: MusicManager es null")
		return
	
	print("✅ MusicManager encontrado")
	MusicManager.play_music("res://assets/audio/music/LEVEL 1.wav", true)
