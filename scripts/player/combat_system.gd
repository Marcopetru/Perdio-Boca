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

	print("🥊 PUÑO - Daño: ", Constants.PUNCH_DAMAGE, " | Rango: ", Constants.PUNCH_RANGE)

	# Reproducir sonido placeholder
	_play_sound("punch_impact")

	# Detectar enemigos en rango
	_apply_damage_in_range(
		Constants.PUNCH_RANGE,
		Constants.PUNCH_DAMAGE,
		Constants.PUNCH_KNOCKBACK
	)

	# Animar (placeholder: cambiar color)
	_animate_attack("punch")

	emit_signal("attack_finished", "punch")
	is_attacking = false

# ============== CERVEZA ==============
func throw_beer() -> void:
	if beer_cooldown > 0:
		return

	beer_cooldown = Constants.BEER_COOLDOWN
	is_attacking = true

	emit_signal("attack_started", "beer")

	print("🍺 CERVEZA - Daño: ", Constants.BEER_DAMAGE, " | Rango: ", Constants.BEER_RANGE)

	# Reproducir sonido
	_play_sound("beer_throw")

	# Crear proyectil
	_create_beer_projectile()

	# Animar
	_animate_attack("beer")

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
	
	var enemies_hit = 0
	for result in results:
		var collider = result.collider
		
		# ← CAMBIO: Detectar enemigos O el Boss
		if collider.is_in_group("enemy") or collider.is_in_group("boss"):
			# Aplicar daño
			collider.take_damage(damage)
			enemies_hit += 1
			
			# ← CAMBIO: Solo knockback si es enemigo (NO al boss)
			if collider.is_in_group("enemy"):
				var direction = (collider.global_position - player.global_position).normalized()
				var adjusted_knockback = knockback * (1.0 - Constants.ENEMY_KNOCKBACK_RESIST)
				collider.take_knockback(direction * adjusted_knockback)
			
			print("✓ ¡Golpe acertado!")
	
	if enemies_hit == 0:
		print("✗ No había enemigos en rango")
	else:
		print("✓ Golpeaste ", enemies_hit, " objetivo(s)")

func _create_beer_projectile() -> void:
	"""Crea un proyectil de cerveza real"""
	
	# Cargar la escena del proyectil
	var beer_scene = load("res://scenes/projectiles/beer_projectile.tscn")
	var projectile = beer_scene.instantiate()
	
	# Agregar a la escena
	get_tree().get_root().add_child(projectile)
	
	# Configurar posición y dirección
	var spawn_pos = player.global_position + Vector3(0, 0.5, 0)
	# Usar basis.z en lugar de -basis.z para que vaya en la dirección correcta
	var direction = player.global_transform.basis.z
	
	projectile.setup(spawn_pos, direction, 15.0)

func _animate_attack(attack_type: String) -> void:
	"""Placeholder de animación - sin efecto visual por ahora"""
	
	# Cuando tengamos animaciones reales, aquí reproduciremos la animación
	# Por ahora solo feedback de sonido (en _play_sound)
	
	print("⚡ Ataque: ", attack_type)

func _play_sound(sound_name: String) -> void:
	"""Placeholder para reproducir sonidos"""

	print("🔊 Sonido: ", sound_name)

	# TODO: Integrar AudioStreamPlayer cuando tengamos los SFX reales
