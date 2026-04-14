# scripts/enemies/enemy_base.gd
extends CharacterBody3D

# ============== REFERENCIAS ==============
var player: Node3D = null

# ============== VARIABLES ==============
var current_health: int
var is_alive: bool = true
var attack_cooldown: float = 0.0
var knockback_velocity = Vector3.ZERO  # ← NUEVO
var knockback_duration = 0.0  # ← NUEVO

# ============== SIGNALS ==============
signal died

func _ready() -> void:
	add_to_group("enemy")
	current_health = Constants.ENEMY_HEALTH
	player = get_tree().get_root().find_child("Player", true, false)

func _physics_process(delta: float) -> void:
	if not is_alive or player == null:
		return
	
	attack_cooldown = max(attack_cooldown - delta, 0.0)
	
	# ← NUEVO: Aplicar knockback
	knockback_duration = max(knockback_duration - delta, 0.0)
	if knockback_duration > 0:
		velocity.x = knockback_velocity.x
		velocity.z = knockback_velocity.z
	else:
		# Comportamiento normal si no está siendo empujado
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player > Constants.ENEMY_ATTACK_RANGE:
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * Constants.ENEMY_SPEED
			velocity.z = direction.z * Constants.ENEMY_SPEED
		else:
			velocity.x = 0
			velocity.z = 0
		
		if distance_to_player < Constants.ENEMY_ATTACK_RANGE and attack_cooldown <= 0:
			attack()
	
	# Gravedad
	velocity.y -= Constants.PLAYER_GRAVITY * delta
	
	# Aplicar movimiento
	self.velocity = velocity
	move_and_slide()

# ← NUEVO: Función para recibir knockback
func take_knockback(knockback_vector: Vector3) -> void:
	"""Recibe un empuje"""
	knockback_velocity = knockback_vector
	knockback_duration = 0.15  # Duración del empuje en segundos
	print("💨 Enemigo recibe knockback")

func attack() -> void:
	attack_cooldown = Constants.ENEMY_ATTACK_COOLDOWN
	if player:
		player.take_damage(Constants.ENEMY_DAMAGE)
		
		# ← NUEVO: Aplicar knockback al jugador
		var direction = (player.global_position - global_position).normalized()
		player.take_knockback(direction * 3.0)  # 3.0 es la fuerza del knockback
	
	print("⚔️ ¡Enemigo atacó!")

func take_damage(damage: int) -> void:
	current_health -= damage
	print("🩹 Enemigo recibe daño. Vida: ", current_health, "/", Constants.ENEMY_HEALTH)
	
	# ← NUEVO: Parpadeo rojo al recibir daño
	_flash_red()
	
	if current_health <= 0:
		die()

# ← NUEVA FUNCIÓN
func _flash_red() -> void:
	"""Hace que el enemigo parpadee en rojo al recibir daño"""
	
	var mesh_instance = get_node_or_null("MeshInstance3D")
	
	if mesh_instance == null:
		return
	
	# Cambiar a rojo
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.RED
	mesh_instance.set_surface_override_material(0, material)
	
	# Revertir después de 0.15 segundos
	await get_tree().create_timer(0.15).timeout
	
	material = StandardMaterial3D.new()
	material.albedo_color = Color.WHITE
	mesh_instance.set_surface_override_material(0, material)

func die() -> void:
	is_alive = false
	print("💀 Enemigo muere")
	emit_signal("died")
	queue_free()
