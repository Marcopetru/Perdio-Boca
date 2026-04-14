# scripts/player/movement.gd
extends Node

@onready var player = get_parent()

var velocity = Vector3.ZERO

func process(delta: float, input_vector: Vector3) -> void:
	# Aplicar gravedad
	velocity.y -= Constants.PLAYER_GRAVITY * delta
	
	# Movimiento horizontal
	var target_velocity = input_vector * Constants.PLAYER_SPEED
	velocity.x = target_velocity.x
	velocity.z = target_velocity.z
	
	# Salto
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		velocity.y = Constants.PLAYER_JUMP_FORCE
	
	# Aplicar velocidad
	player.velocity = velocity
	player.move_and_slide()
	
	# Animaciones (temporal)
	if input_vector.length() > 0:
		player.rotation.y = atan2(-input_vector.x, -input_vector.z)
