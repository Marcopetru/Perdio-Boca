# scripts/player/animation_controller.gd
extends Node3D

# ============== REFERENCIAS ==============
var animation_player: AnimationPlayer
var model: Node3D  # El nodo que se rota según dirección

# ============== VARIABLES ==============
var current_animation: String = "idle"
var is_playing: bool = false

func _ready() -> void:
	# Obtener referencias
	animation_player = get_node_or_null("AnimationPlayer")
	model = get_node_or_null("Model")
	
	if animation_player == null:
		print("❌ AnimationPlayer no encontrado!")
		return
	
	print("✅ AnimationController listo")

func play_animation(anim_name: String) -> void:
	"""Reproduce una animación"""
	
	if animation_player == null:
		return
	
	if current_animation != anim_name:
		animation_player.play(anim_name)
		current_animation = anim_name
		print("▶️ Animación: ", anim_name)

func set_model_rotation(direction: Vector3) -> void:
	"""Rota el modelo según la dirección de movimiento"""
	
	if model == null or direction.length() < 0.1:
		return
	
	# Calcular el ángulo hacia donde mira
	var angle = atan2(direction.x, direction.z)
	model.rotation.y = angle
