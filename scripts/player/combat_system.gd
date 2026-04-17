# scripts/player/combat_system.gd
extends Node3D

@onready var player = get_parent()

# ============== VARIABLES DE COOLDOWN ==============
var punch_cooldown: float = 0.0
var beer_cooldown: float = 0.0
var is_attacking: bool = false

# ============== SEÑALES ==============
signal attack_started(attack_type: String)
signal attack_finished(attack_type: String)

func _process(delta: float) -> void:
	# Actualizar cooldowns
	punch_cooldown = max(punch_cooldown - delta, 0.0)
	beer_cooldown = max(beer_cooldown - delta, 0.0)

# ============== PUÑO ==============
func punch() -> void:
	# Verificar si está en cooldown
	if punch_cooldown > 0:
		return

	# Establecer cooldown
	punch_cooldown = Constants.PUNCH_COOLDOWN
	is_attacking = true

	emit_signal("attack_started", "punch")

	#Reproducir sonido de golpe
	_play_sound("res://assets/audio/sfx/Golpe 1.wav")

	# Detectar enemigos en rango
	_apply_damage_in_range(
		Constants.PUNCH_RANGE,
		Constants.PUNCH_DAMAGE,
		Constants.PUNCH_KNOCKBACK
	)

	emit_signal("attack_finished", "punch")
	is_attacking = false

# ============== CERVEZA ==============
func throw_beer() -> void:
	if beer_cooldown > 0:
		return

	beer_cooldown = Constants.BEER_COOLDOWN
	is_attacking = true

	emit_signal("attack_started", "beer")

	#Reproducir sonido de lanzamiento
	_play_sound("res://assets/audio/sfx/Cerveza 1.wav")

	# Crear proyectil
	_create_beer_projectile()

	emit_signal("attack_finished", "beer")
	is_attacking = false

# ============== FUNCIONES AUXILIARES ==============

func _apply_damage_in_range(detection_range: float, damage: int, knockback: float) -> void:
	"""Detecta enemigos y al Boss en rango y aplica daño + knockback"""
	
	var space_state = player.get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = detection_range
	
	query.shape = sphere
	query.transform.origin = player.global_position
	query.exclude = [player]
	
	# Detectar todos los colisionadores en la esfera
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var collider = result.collider
		#Detectar enemigos O el Boss
		if collider.is_in_group("enemy") or collider.is_in_group("boss"):
			# Aplicar daño
			collider.take_damage(damage)
			
			#Solo knockback si es enemigo (NO al boss)
			if collider.is_in_group("enemy"):
				var direction = (collider.global_position - player.global_position).normalized()
				var adjusted_knockback = knockback * (1.0 - Constants.ENEMY_KNOCKBACK_RESIST)
				collider.take_knockback(direction * adjusted_knockback)

func _create_beer_projectile() -> void:
	"""Crea un proyectil de cerveza real"""
	
	# Cargar la escena del proyectil
	var beer_scene = load("res://scenes/projectiles/beer_projectile.tscn")
	var projectile = beer_scene.instantiate()
	
	# Agregar a la escena
	get_tree().get_root().add_child(projectile)
	
	# Configurar posición y dirección
	# Salir más adelante (1.5 en lugar de 1.0) y más a la altura correcta
	var spawn_pos = player.global_position + Vector3(0, 1.2, 0) + player.global_transform.basis.z * 0.8
	
	# Usar basis.z para que vaya en la dirección correcta
	var direction = player.global_transform.basis.z
	
	# Velocidad más baja (10.0 en lugar de 15.0)
	projectile.setup(spawn_pos, direction, 10.0)

func _play_sound(sound_path: String) -> void:
	"""Reproduce un sonido de efecto"""
	
	# Obtener el AudioStreamPlayer del jugador
	var sfx_player = player.get_node_or_null("SFXPlayer")
	# Cargar el sonido
	var audio_stream = load(sound_path)
	# Reproducir
	sfx_player.stream = audio_stream
	sfx_player.play()
