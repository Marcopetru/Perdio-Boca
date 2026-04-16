# scripts/levels/level_2_manager.gd
extends Node

func _ready() -> void:
	
	# Reproducir música
	if MusicManager:
		MusicManager.play_music("res://assets/audio/music/LEVEL 2.wav", true)
	return
