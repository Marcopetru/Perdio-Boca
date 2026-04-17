# scripts/ui/credits_screen.gd
extends Control

# ============== REFERENCIAS ==============
@onready var scroll_container: ScrollContainer = $ScrollContainer

# ============== VARIABLES ==============
var scroll_speed: float = 40.0  # Píxeles por segundo (más lento)
var credits_finished: bool = false
var total_duration: float = 0.0  # Tiempo total de créditos

func _ready() -> void:
	# Asegurar que el scroll empieza arriba
	await get_tree().process_frame
	scroll_container.scroll_vertical = 0
	
	# Calcular duración aproximada
	var max_scroll = scroll_container.get_v_scroll_bar().max_value
	total_duration = max_scroll / scroll_speed + 3.0  # Agregar 3 segundos extra al final

func _process(delta: float) -> void:
	# Scroll automático hacia abajo
	scroll_container.scroll_vertical += int(scroll_speed * delta)
	
	# Si llegó al final, esperar 3 segundos y volver a menú
	if scroll_container.scroll_vertical >= scroll_container.get_v_scroll_bar().max_value:
		if not credits_finished:
			credits_finished = true
			await get_tree().create_timer(3.0).timeout
			_go_to_menu()
	
	# ESC para ir al menú (saltarse créditos)
	if Input.is_action_just_pressed("ui_cancel"):
		_go_to_menu()

func _go_to_menu() -> void:
	"""Volver al menú principal"""
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
