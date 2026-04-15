# scripts/enemies/boss_mcdonald.gd
extends CharacterBody3D

# ============== REFERENCIAS ==============
var player: Node3D = null

# ============== VARIABLES ==============
var current_health: int
var max_health: int = 150
var is_alive: bool = true

# Ataque
var attack_cooldown: float = 0.0
var attack_interval: float = 2.0  # Lanzar proyectiles cada 2 segundos
var projectiles_per_attack: int = 3  # Lanzar 3 proyectiles por ataque
var current_phase: int = 1  # Fase 1, 2 o 3 (aumenta dificultad)

# ============== SIGNALS ==============
signal health_changed(new_health)
signal died

func _ready() -> void:
	add_to_group("boss")
	current_health = max_health
	player = get_tree().get_root().find_child("Player", true, false)
	
	if player == null:
		print("❌ Boss: No encontré al jugador")
		return
	
	print("✅ Boss McDonald's inicializado")
	print("   Vida: %d | Ataque cada: %.1f segundos" % [max_health, attack_interval])

func _physics_process(delta: float) -> void:
	if not is_alive or player == null:
		return
	
	# Actualizar cooldown de ataque
	attack_cooldown -= delta
	
	# Atacar si está listo
	if attack_cooldown <= 0:
		_attack()
		attack_cooldown = attack_interval
	
	# Cambiar fase según vida (opcional pero hace más interesante)
	_update_phase()

func _attack() -> void:
	"""Ataca spawnando proyectiles"""
	
	print("👹 Boss ataca! Lanzando %d proyectiles (Fase %d)" % [projectiles_per_attack, current_phase])
	
	# Lanzar múltiples proyectiles
	for i in range(projectiles_per_attack):
		await get_tree().create_timer(0.2 * i).timeout  # Pequeño delay entre proyectiles
		_spawn_projectile()

func _spawn_projectile() -> void:
	"""Spawnea UN proyectil de papa/hamburguesa DENTRO del nivel"""
	
	# Cargar escena del proyectil
	var projectile_scene = load("res://scenes/projectiles/boss_projectile.tscn")
	var projectile = projectile_scene.instantiate()
	
	# Agregar a la escena
	get_tree().get_root().add_child(projectile)
	
	# Posición del Boss (donde aparece el proyectil)
	var spawn_pos = global_position + Vector3(0, 5, 0)  # Arriba del Boss
	
	#Destino aleatorio DENTRO del floor (20x20)
	# Floor es 20x20, así que:
	# X va de -10 a 10
	# Z va de -10 a 10
	var target_pos = Vector3(
		randf_range(-10, 10),  # X dentro del floor
		0,                      # Al nivel del suelo
		randf_range(-10, 10)    # Z dentro del floor
	)
	
	# Configurar proyectil
	projectile.setup(spawn_pos, target_pos, Constants.BEER_DAMAGE)
	
	print("  └─ Proyectil spawnado en (%.1f, %.1f, %.1f) → Target: (%.1f, %.1f, %.1f)" % [
		spawn_pos.x, spawn_pos.y, spawn_pos.z,
		target_pos.x, target_pos.y, target_pos.z
	])

func take_damage(damage: int) -> void:
	"""Recibe daño"""
	
	current_health -= damage
	emit_signal("health_changed", current_health)
	
	print("💢 Boss recibe daño: %d | Vida: %d/%d" % [damage, current_health, max_health])
	
	# Parpadeo rojo
	_flash_red()
	
	if current_health <= 0:
		die()

func _flash_red() -> void:
	"""Hace que el Boss parpadee en rojo al recibir daño"""
	
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

func _update_phase() -> void:
	"""Cambia de fase según la vida (aumenta dificultad)"""
	
	var health_percent = float(current_health) / float(max_health)
	
	if health_percent > 0.66 and current_phase != 1:
		current_phase = 1
		attack_interval = 2.0
		projectiles_per_attack = 3
		print("📊 Boss Fase 1 - Ataque lento")
	
	elif health_percent > 0.33 and current_phase != 2:
		current_phase = 2
		attack_interval = 1.5
		projectiles_per_attack = 4
		print("📊 Boss Fase 2 - Ataque más rápido")
	
	elif health_percent <= 0.33 and current_phase != 3:
		current_phase = 3
		attack_interval = 1.0
		projectiles_per_attack = 5
		print("📊 Boss Fase 3 - ATAQUE MÁXIMO!")

func die() -> void:
	"""Muere"""
	
	is_alive = false
	print("💀 ¡Boss McDonald's MUERE!")
	emit_signal("health_changed", 0)
	emit_signal("died")
	
	queue_free()
