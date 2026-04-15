# scripts/projectiles/boss_projectile.gd
extends Area3D

# ============== VARIABLES ==============
var damage = Constants.BEER_DAMAGE
var max_fall_distance = 100.0  # Distancia máxima de caída
var fallen_distance = 0.0

var start_pos = Vector3.ZERO
var fall_speed = 5.0  #Velocidad de caída lineal

var player_hit = false  # Para no golpear 2 veces

func _ready() -> void:
	add_to_group("boss_projectile")

func _physics_process(delta: float) -> void:
	
	position.y -= fall_speed * delta
	
	# Contar distancia caída
	fallen_distance += fall_speed * delta
	
	# Desaparecer si cayó demasiado o llegó al suelo
	if fallen_distance > max_fall_distance or position.y < -1.0:
		print("💨 Proyectil del Boss desaparece (tocó piso)")
		queue_free()
		return
	
	# Detectar colisión con el jugador
	_check_collision_with_player()

func setup(spawn_position: Vector3, target_x_z: Vector2, dmg: int) -> void:
	"""Configura el proyectil
	
	spawn_position: Donde aparece (arriba en el cielo)
	target_x_z: Coordenadas X,Z del suelo donde va a caer (Y se ignora)
	dmg: Daño que causa
	"""
	
	position = spawn_position
	position.x = target_x_z.x  # Posicionar en X del destino
	position.z = target_x_z.y  # Posicionar en Z del destino (Y es la altura)
	
	damage = dmg
	start_pos = position
	
	print("🍟 Proyectil del Boss creado en (%.1f, %.1f, %.1f) - Caerá en (%.1f, %.1f)" % [
		position.x, position.y, position.z,
		target_x_z.x, target_x_z.y
	])

func _check_collision_with_player() -> void:
	"""Detecta colisión SOLO con el jugador (NO con el Boss)"""
	
	# Verificar si el proyectil está cerca del jugador
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.5  # Radio de detección
	
	query.shape = sphere
	query.transform.origin = global_position
	
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var collider = result.collider
		
		#SOLO Player, NO Boss
		if collider.name == "Player" and not player_hit:
			_hit_player(collider)

func _hit_player(player: Node3D) -> void:
	"""Golpea al jugador"""
	
	if player_hit:
		return  # No golpear 2 veces
	
	player_hit = true
	
	# Aplicar daño (10 puntos)
	player.take_damage(10)
	
	# Aplicar knockback
	var direction = (player.global_position - global_position).normalized()
	var knockback_force = 3.0
	player.take_knockback(direction * knockback_force)
	
	print("💥 ¡Proyectil del Boss impactó al jugador!")
	
	# Desaparecer después del impacto
	queue_free()

func _on_area_entered(area: Area3D) -> void:
	"""Por si acaso, también detecta por signals"""
	
	if area.name == "Player" and not player_hit:
		_hit_player(area)
