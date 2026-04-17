# scripts/camera/camera_controller.gd
extends Camera3D

# ============== VARIABLES ==============
var target: Node3D = null
var offset_x = 0.0  # Separación lateral (NO se usa, cámara centrada)
var offset_y = 10.0  # Altura (ARRIBA)
var offset_z = 15.0  # Profundidad (ATRÁS)
var follow_smoothness = 5.0

func _ready() -> void:
	target = get_tree().get_root().find_child("Player", true, false)
	
	if target == null:
		return

func _process(delta: float) -> void:
	if target == null:
		return
	
	# Posición objetivo
	var target_pos = Vector3(
		target.global_position.x,  # ← SIGUE EN X (lateral)
		offset_y,                   # ← FIJA EN Y (arriba)
		offset_z                    # ← FIJA EN Z (atrás)
	)
	
	# Interpolación suave
	global_position = global_position.lerp(target_pos, follow_smoothness * delta)
	
	# Siempre mirar al jugador
	look_at(target.global_position + Vector3(0, 1, 0), Vector3.UP)
