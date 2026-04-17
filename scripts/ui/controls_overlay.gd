# scripts/ui/controls_overlay.gd
extends CanvasLayer

@onready var panel: Control = $ControlsPanel

# ============== VARIABLES ==============
const DISPLAY_TIME: float = 4.0  # Mostrar 4 segundos

func _ready() -> void:
	# Mostrar overlay
	panel.visible = true
	
	# Esperar y desaparecer
	await get_tree().create_timer(DISPLAY_TIME).timeout
	
	# Fade out suave
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 1.0)
	
	# Eliminar después del fade
	await tween.finished
	queue_free()

func _process(_delta: float) -> void:
	# ESC para cerrar antes de tiempo
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
