# scripts/enemies/enemy_base.gd
extends CharacterBody3D

# ============== REFERENCIAS ==============
var player: Node3D = null
@onready var animation_player = $"Animaciones Policia all/AnimationPlayer"  # para las animaciones
@onready var model = self  # para rotar el modelo

# ============== VARIABLES ==============
var current_health: int
var is_alive: bool = true
var attack_cooldown: float = 0.0
var knockback_velocity = Vector3.ZERO
var knockback_duration = 0.0

#VARIABLES PARA ANIMACIÓN
var last_direction = Vector3(0, 0, -1)  # Dirección hacia la cual mira el enemigo
var is_attacking: bool = false  # Para saber si está en animación de ataque

# ============== SIGNALS ==============
signal died

func _ready() -> void:
	add_to_group("enemy")
	current_health = Constants.ENEMY_HEALTH
	player = get_tree().get_root().find_child("Player", true, false)

func _physics_process(delta: float) -> void:
	if not is_alive or player == null:
		return
	
	# Decrementar cooldown de ataque
	attack_cooldown = max(attack_cooldown - delta, 0.0)
	
	# Procesar knockback
	knockback_duration = max(knockback_duration - delta, 0.0)
	
	if knockback_duration > 0:
		# Si está siendo empujado, aplicar knockback
		velocity.x = knockback_velocity.x
		velocity.z = knockback_velocity.z
		# No anima mientras está en knockback
	else:
		# Comportamiento normal si no está siendo empujado
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player > Constants.ENEMY_ATTACK_RANGE:
			# Perseguir al jugador
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * Constants.ENEMY_SPEED
			velocity.z = direction.z * Constants.ENEMY_SPEED
			
			# Rotar modelo hacia el jugador
			_rotate_model(direction)
			
			#Reproducir animación de caminar si no está atacando
			if not is_attacking and animation_player.current_animation != "walk":
				animation_player.play("walk")
		else:
			# Dentro de rango de ataque: parar de moverse
			velocity.x = 0
			velocity.z = 0
			
			#Reproducir animación idle si no está atacando
			if not is_attacking and animation_player.current_animation != "idle":
				animation_player.play("idle")
		
		#Solo atacar si está en rango, no está en cooldown y no está atacando
		if distance_to_player < Constants.ENEMY_ATTACK_RANGE and attack_cooldown <= 0 and not is_attacking:
			attack()
	
	# Gravedad
	velocity.y -= Constants.PLAYER_GRAVITY * delta
	
	# Aplicar movimiento
	self.velocity = velocity
	move_and_slide()

#Función para recibir knockback
func take_knockback(knockback_vector: Vector3) -> void:
	"""Recibe un empuje"""
	knockback_velocity = knockback_vector
	knockback_duration = 0.15  # Duración del empuje en segundos
	print("💨 Enemigo recibe knockback")

#Rotar hacia la dirección
func _rotate_model(direction: Vector3) -> void:
	"""Rota el modelo hacia la dirección de movimiento"""
	if model == null or direction.length() < 0.1:
		return
	
	# Calcular ángulo: invertir X para que coincida con las animaciones
	var angle = atan2(-direction.x, -direction.z)
	
	# Sumar 180° porque el modelo mira hacia atrás por defecto
	model.rotation.y = angle + PI

func attack() -> void:
	"""Ataque del enemigo con animación, sonido y cooldown mejorado"""
	is_attacking = true  # Marca que está atacando
	attack_cooldown = Constants.ENEMY_ATTACK_COOLDOWN  # Establece cooldown
	
	if player:
		# Reproducir animación de ataque
		if animation_player:
			animation_player.play("punch_01")
		
		# ← NUEVO: Reproducir sonido de golpe del policía
		_play_sound("res://assets/audio/sfx/Golpe 2.wav")
		
		# Aplicar daño al jugador
		player.take_damage(Constants.ENEMY_DAMAGE)
		
		# Aplicar knockback al jugador
		var direction = (player.global_position - global_position).normalized()
		player.take_knockback(direction * 3.0)
	
	# Esperar a que termine la animación de ataque
	if animation_player:
		# Esperar a que termine la animación (ajusta el tiempo según tu animación)
		await get_tree().create_timer(0.6).timeout
	
	is_attacking = false  # Ya terminó de atacar

func take_damage(damage: int) -> void:
	current_health -= damage
	
	#Parpadeo rojo al recibir daño
	_flash_red()
	
	if current_health <= 0:
		die()


func _flash_red() -> void:
	"""Hace que el enemigo parpadee en rojo al recibir daño"""
	
	if model == null:
		return
	
	# Obtener todos los meshes del modelo (como hace el jugador)
	var mesh_instances = _get_all_mesh_instances(model)
	
	if mesh_instances.is_empty():
		print("⚠️ No se encontraron MeshInstance3D en el enemigo")
		return
	
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

#Recupera la skin original despues de parpadear
func _get_all_mesh_instances(node: Node) -> Array:
	"""Obtiene todos los MeshInstance3D de un nodo y sus hijos"""
	var instances = []
	
	if node is MeshInstance3D:
		instances.append(node)
	
	for child in node.get_children():
		instances += _get_all_mesh_instances(child)
	
	return instances

#Reproducir sonido
func _play_sound(sound_path: String) -> void:
	"""Reproduce un sonido de efecto"""
	
	var sfx_player = get_node_or_null("SFXPlayer")
	
	var audio_stream = load(sound_path)
	
	sfx_player.stream = audio_stream
	sfx_player.play()

func die() -> void:
	is_alive = false
	emit_signal("died")
	queue_free()
