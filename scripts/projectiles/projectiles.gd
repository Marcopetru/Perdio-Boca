# scripts/projectiles/beer_projectile.gd
extends Area3D

# ============== VARIABLES ==============
var velocity = Vector3.ZERO
var damage = Constants.BEER_DAMAGE
var knockback = Constants.BEER_KNOCKBACK
var max_distance = Constants.BEER_RANGE
var traveled_distance = 0.0

var enemies_hit = []

func _ready() -> void:
	add_to_group("projectile")
	

func _physics_process(delta: float) -> void:
	# Movimiento
	position += velocity * delta
	traveled_distance += velocity.length() * delta
	
	# Desaparecer si viajó demasiado
	if traveled_distance > max_distance:
		print("🍺 Cerveza desapareció por distancia")
		queue_free()
		return
	
	# Gravedad leve
	velocity.y -= Constants.PLAYER_GRAVITY * delta * 0.5
	
	# ← NUEVO: Detección manual de enemigos cercanos
	_check_collision_with_enemies()

func setup(spawn_position: Vector3, direction: Vector3, speed: float) -> void:
	"""Configura el proyectil"""
	
	position = spawn_position
	velocity = direction.normalized() * speed
	look_at(position + velocity, Vector3.UP)

# ← NUEVA FUNCIÓN: Detección manual
func _check_collision_with_enemies() -> void:
	"""Verifica colisión con enemigos usando raycast"""
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.5  # Radio de detección
	
	query.shape = sphere
	query.transform.origin = global_position
	
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var collider = result.collider
		
		if collider.is_in_group("enemy") and collider not in enemies_hit:
			_hit_enemy(collider)

func _hit_enemy(enemy: Node3D) -> void:
	"""Golpea un enemigo"""
	
	enemies_hit.append(enemy)
	
	# Aplicar daño
	enemy.take_damage(damage)
	
	# Aplicar knockback
	var direction = velocity.normalized()
	var adjusted_knockback = knockback * (1.0 - Constants.ENEMY_KNOCKBACK_RESIST)
	enemy.take_knockback(direction * adjusted_knockback)
	
	print("�� ¡Cerveza impactó a enemigo!")
	
	# Desaparecer después del impacto
	queue_free()

func _on_area_entered(area: Area3D) -> void:
	"""Por si acaso, también detecta por signals"""
	
	if area.is_in_group("enemy") and area not in enemies_hit:
		_hit_enemy(area)
