# scripts/levels/level_1_manager.gd
extends Node

func _ready() -> void:
	# Reproducir música del nivel 1
	MusicManager.play_music("res://assets/audio/music/LEVEL 1.wav", true)
