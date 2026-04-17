# scripts/enemies/boss_mcdonald.gd
extends CharacterBody3D

# ============== REFERENCIAS ==============
var player: Node3D = null

# ============== VARIABLES ==============
var current_health: int
var max_health: int = 300
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
		return
	
	# Delay antes de empezar a atacar
	attack_cooldown = 2.0
	
	#Emitir signal al inicializarse
	emit_signal("health_changed", current_health)
	

func _physics_process(delta: float) -> void:
	#Si no está vivo, NO hacer nada
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
	
	# Lanzar múltiples proyectiles
	for i in range(projectiles_per_attack):
		await get_tree().create_timer(0.2 * i).timeout  # Pequeño delay entre proyectiles
		_spawn_projectile()

func _spawn_projectile() -> void:
	"""Spawnea UN proyectil que cae del cielo"""
	
	# Cargar escena del proyectil
	var projectile_scene = load("res://scenes/projectiles/boss_projectile.tscn")
	var projectile = projectile_scene.instantiate()
	
	# Agregar a la escena
	get_tree().get_root().add_child(projectile)
	
	#El proyectil aparece arriba (en el cielo)
	var spawn_pos = Vector3(0, 20, 0)  # Arriba del nivel, en el centro
	
	#Destino aleatorio DENTRO del floor (20x20) - SOLO X y Z
	var target_x_z = Vector2(
		randf_range(-10, 10),  # X dentro del floor
		randf_range(-10, 10)   # Z dentro del floor
	)
	
	#Pasar X,Z del destino (no Position3D)
	projectile.setup(spawn_pos, target_x_z, Constants.BEER_DAMAGE)
	

func take_damage(damage: int) -> void:
	"""Recibe daño"""
	
	current_health -= damage
	emit_signal("health_changed", current_health)
	
	#Parpadeo rojo
	_flash_red()
	
	if current_health <= 0:
		die()

#Parpadeo rojo al recibir daño
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
	"""Cambia de fase según la vida"""
	
	var health_percent = float(current_health) / float(max_health)
	
	if health_percent > 0.66 and current_phase != 1:
		current_phase = 1
		attack_interval = 2.0
		projectiles_per_attack = 5  # ← CAMBIO: 3 → 5
	
	elif health_percent > 0.33 and current_phase != 2:
		current_phase = 2
		attack_interval = 1.5
		projectiles_per_attack = 7  # ← CAMBIO: 4 → 7
	
	elif health_percent <= 0.33 and current_phase != 3:
		current_phase = 3
		attack_interval = 1.0
		projectiles_per_attack = 9  # ← CAMBIO: 5 → 9

func die() -> void:
	"""El boss muere"""
	
	is_alive = false  # ← IMPORTANTE: Primero desactivar para evitar más ataques
	
	# Esperar 2 segundos antes de ir a créditos
	await get_tree().create_timer(2.0).timeout
	
	#IR A CRÉDITOS
	get_tree().change_scene_to_file("res://scenes/ui/credits_screen.tscn")
