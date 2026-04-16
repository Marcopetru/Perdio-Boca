# scripts/player/player.gd
extends CharacterBody3D

# ============== REFERENCIAS ==============
@onready var animation_player = $"Anim bostero/AnimationPlayer"
@onready var combat_system = $CombatSystem
@onready var movement_component = $Movement
@onready var model = self #para rotar al modelo
@onready var sfx_player = $SFXPlayer  # ← NUEVO
var footstep_timer: float = 0.0  #para controlar frecuencia de pasos
const FOOTSTEP_INTERVAL: float = 0.4  #cada 0.4 segundos

# ============== VARIABLES DE ESTADO ==============
var current_health: int
var is_alive: bool = true
var is_attacking: bool = false
var beer_ammo: int
var punch_cooldown: float = 0.0
var beer_cooldown: float = 0.0

#Variables de knockback
var knockback_velocity = Vector3.ZERO
var knockback_duration = 0.0

#Variable de dirección actual
var last_direction = Vector3(0, 0, -1)  # Mira hacia adelante por defecto

# ============== SEÑALES ==============
signal health_changed(new_health)
signal died
signal beer_ammo_changed(new_ammo)

func _ready() -> void:
	current_health = Constants.PLAYER_MAX_HEALTH
	beer_ammo = Constants.PLAYER_BEER_AMMO
	is_alive = true
	
	emit_signal("health_changed", current_health)
	emit_signal("beer_ammo_changed", beer_ammo)
	
	# Reproducir animación idle al empezar
	if animation_player:
		animation_player.play("idle")
	
	print("✅ Player inicializado - Vida: %d | Cervezas: %d" % [current_health, beer_ammo])

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	# Decrementar cooldowns CADA FRAME
	punch_cooldown = max(punch_cooldown - delta, 0.0)
	beer_cooldown = max(beer_cooldown - delta, 0.0)
	
	# Procesar knockback
	knockback_duration = max(knockback_duration - delta, 0.0)
	
	var input_vector = get_input()
	
	# Si está recibiendo knockback, aplicar eso en lugar del movimiento normal
	if knockback_duration > 0:
		velocity.x = knockback_velocity.x
		velocity.z = knockback_velocity.z
	else:
		# Movimiento normal
		movement_component.process(delta, input_vector)
	
	# Rotar modelo según dirección
	if input_vector.length() > 0.1:
		last_direction = input_vector
		_rotate_model(input_vector)
		# Cambiar a walk si NO está atacando
		if not is_attacking and animation_player.current_animation != "walk":
			print("▶️ Cambiando a: walk")
			_play_animation("walk")
		
		#Reproducir sonido de pasos mientras camina
		footstep_timer -= delta
		if footstep_timer <= 0:
			_play_footstep_sound()
			footstep_timer = FOOTSTEP_INTERVAL
	else:
		# Cambiar a idle si NO está atacando
		if not is_attacking and animation_player.current_animation != "idle":
			print("▶️ Cambiando a: idle")
			_play_animation("idle")
		
		#Resetear timer si no se mueve
		footstep_timer = 0.0
	
	# Ataques
	if Input.is_action_just_pressed("attack_punch"):
		if punch_cooldown <= 0:
			is_attacking = true
			combat_system.punch()
			_play_animation("punch_02")
			punch_cooldown = 0.8
			await get_tree().create_timer(0.5).timeout
			is_attacking = false
	
	if Input.is_action_just_pressed("attack_beer"):
		if beer_ammo > 0 and beer_cooldown <= 0:
			is_attacking = true
			combat_system.throw_beer()
			beer_ammo -= 1
			emit_signal("beer_ammo_changed", beer_ammo)
			_play_animation("throw")
			beer_cooldown = 1.2
			await get_tree().create_timer(0.8).timeout
			is_attacking = false

#Reproducir animación
func _play_animation(anim_name: String) -> void:
	"""Reproduce una animación"""
	if animation_player:
		animation_player.play(anim_name)

#Rotar modelo según dirección
func _rotate_model(direction: Vector3) -> void:
	"""Rota el modelo hacia la dirección de movimiento"""
	if model == null or direction.length() < 0.1:
		return
	
	# Calcular ángulo: invertir X para que coincida con las animaciones
	var angle = atan2(-direction.x, -direction.z)
	
	# Sumar 180° porque el modelo mira hacia atrás por defecto
	model.rotation.y = angle + PI
	
func take_damage(damage: int) -> void:
	"""Recibe daño"""
	
	current_health -= damage
	emit_signal("health_changed", current_health)
	
	print("💢 Jugador recibe daño: ", damage, " | Vida: ", current_health)
	
	# Parpadeo rojo al recibir daño
	_flash_red()
	
	if current_health <= 0:
		die()

func _flash_red() -> void:
	"""Hace que el jugador parpadee en rojo al recibir daño"""
	
	if model == null:
		return
	
	# Obtener todos los meshes del modelo
	var mesh_instances = _get_all_mesh_instances(model)
	
	# Cambiar a rojo
	for mesh_inst in mesh_instances:
		var red_material = StandardMaterial3D.new()
		red_material.albedo_color = Color.RED
		mesh_inst.material_override = red_material
	
	# Revertir después de 0.2 segundos
	await get_tree().create_timer(0.2).timeout
	
	# Restaurar material original
	for mesh_inst in mesh_instances:
		mesh_inst.material_override = null

func _get_all_mesh_instances(node: Node) -> Array:
	"""Obtiene todos los MeshInstance3D de un nodo y sus hijos"""
	var instances = []
	
	if node is MeshInstance3D:
		instances.append(node)
	
	for child in node.get_children():
		instances += _get_all_mesh_instances(child)
	
	return instances

#Recibir knockback
func take_knockback(knockback_vector: Vector3) -> void:
	"""Recibe un empuje"""
	var adjusted_knockback = knockback_vector * (1.0 - Constants.PLAYER_KNOCKBACK_RESIST)
	knockback_velocity = adjusted_knockback
	knockback_duration = 0.2
	
	print("💨 Jugador recibe knockback")

func die() -> void:
	is_alive = false
	emit_signal("died")
	print("💀 ¡Jugador muere!")
	
	
func get_input() -> Vector3:
	var input = Vector3.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.z = Input.get_axis("ui_up", "ui_down")
	return input.normalized()
	
	
func _play_footstep_sound() -> void:
	"""Reproduce el sonido de un paso"""
	if sfx_player == null:
		return
	
	var audio_stream = load("res://assets/audio/sfx/Pasos 2.wav")
	
	if audio_stream == null:
		print("⚠️ No se pudo cargar el sonido de pasos")
		return
	
	sfx_player.stream = audio_stream
	sfx_player.play()
