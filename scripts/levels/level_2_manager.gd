# scripts/levels/level_2_manager.gd
extends Node

func _ready() -> void:
	# Reproducir música del nivel 2
	MusicManager.play_music("res://assets/audio/music/LEVEL 2.wav", true)
