# scripts/projectiles/boss_projectile.gd
extends Area3D

# ============== VARIABLES ==============
var velocity = Vector3.ZERO
var damage = Constants.BEER_DAMAGE
var max_distance = 50.0  # Distancia máxima antes de desaparecer
var traveled_distance = 0.0

var target_pos = Vector3.ZERO
var speed = 15.0  # Velocidad de caída

var player_hit = false  # Para no golpear 2 veces

func _ready() -> void:
	add_to_group("boss_projectile")

func _physics_process(delta: float) -> void:
	if target_pos == Vector3.ZERO:
		return
	
	# Dirección hacia el destino
	var direction = (target_pos - global_position).normalized()
	
	# Movimiento hacia el destino
	velocity = direction * speed
	position += velocity * delta
	
	# Contar distancia viajada
	traveled_distance += velocity.length() * delta
	
	# Gravedad leve
	velocity.y -= Constants.PLAYER_GRAVITY * delta * 0.3
	
	# Desaparecer si viajó demasiado o llegó al suelo
	if traveled_distance > max_distance or position.y < -1.0:
		print("💨 Proyectil del Boss desaparece")
		queue_free()
		return
	
	# Detectar colisión con el jugador
	_check_collision_with_player()

func setup(spawn_position: Vector3, target: Vector3, dmg: int) -> void:
	"""Configura el proyectil"""
	
	position = spawn_position
	target_pos = target
	damage = dmg
	
	print("🍟 Proyectil del Boss creado: %s → %s" % [spawn_position, target_pos])

func _check_collision_with_player() -> void:
	"""Detecta colisión con el jugador"""
	
	# Verificar si el proyectil está cerca del jugador
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.3  # Radio de detección (pequeño)
	
	query.shape = sphere
	query.transform.origin = global_position
	
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var collider = result.collider
		
		# Verificar si es el jugador
		if collider.name == "Player" and not player_hit:
			_hit_player(collider)

func _hit_player(player: Node3D) -> void:
	"""Golpea al jugador"""
	
	if player_hit:
		return  # No golpear 2 veces
	
	player_hit = true
	
	# Aplicar daño
	player.take_damage(damage)
	
	# Aplicar knockback
	var direction = (player.global_position - global_position).normalized()
	var knockback_force = 5.0
	player.take_knockback(direction * knockback_force)
	
	print("💥 ¡Proyectil del Boss impactó al jugador!")
	
	# Desaparecer después del impacto
	queue_free()

func _on_area_entered(area: Area3D) -> void:
	"""Por si acaso, también detecta por signals"""
	
	if area.name == "Player" and not player_hit:
		_hit_player(area)
