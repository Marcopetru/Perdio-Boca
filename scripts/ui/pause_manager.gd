# scripts/ui/pause_manager.gd
extends CanvasLayer

# ============== REFERENCIAS ==============
@onready var pause_panel: Control = $PausePanel
@onready var continue_button: Button = $PausePanel/VBoxContainer/ContinueButton
@onready var menu_button: Button = $PausePanel/VBoxContainer/MenuButton

# ============== VARIABLES ==============
var is_paused: bool = false

func _ready() -> void:
	# Conectar botones
	continue_button.pressed.connect(_on_continue_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	
	# Ocultar panel al inicio
	pause_panel.visible = false

func _process(_delta: float) -> void:
	# Presionar ESC para pausar/reanudar
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	"""Alterna entre pausa y normal"""
	
	is_paused = !is_paused
	
	if is_paused:
		_pause_game()
	else:
		_resume_game()

func _pause_game() -> void:
	"""Pausa el juego"""
	
	get_tree().paused = true
	pause_panel.visible = true

func _resume_game() -> void:
	"""Reanuda el juego"""
	
	get_tree().paused = false
	pause_panel.visible = false
	is_paused = false

func _on_continue_pressed() -> void:
	"""Click en botón Continuar"""
	
	_resume_game()

func _on_menu_pressed() -> void:
	"""Click en botón Menú Principal"""
	
	get_tree().paused = false  # Reanudar ANTES de cambiar escena
	# Aquí iremos al menú cuando lo creemos
	# get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
