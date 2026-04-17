# scripts/ui/main_menu.gd
extends Control

# ============== REFERENCIAS ==============
@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var exit_button: Button = $VBoxContainer/ExitButton

func _ready() -> void:
	# Conectar botones
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)


func _on_play_pressed() -> void:
	"""Click en botón Jugar"""

	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func _on_exit_pressed() -> void:
	"""Click en botón Salir"""
	
	get_tree().quit()
