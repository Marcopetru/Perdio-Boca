# scripts/managers/spawn_manager.gd
extends Node3D

# ============== VARIABLES ==============
var enemy_scene = preload("res://scenes/enemies/police_officer.tscn")
var progress_manager: Node3D = null

func _ready() -> void:
	add_to_group("spawn_manager")
	
	progress_manager = get_tree().get_root().find_child("ProgressManager", true, false)

func spawn_zone_enemies(zone_id: int, enemy_count: int, zone_x: float) -> void:
	"""Spawnea enemigos en una zona específica"""
	
	for i in range(enemy_count):
		# Delay entre spawns
		await get_tree().create_timer(0.5 * i).timeout
		_spawn_single_enemy(zone_x, zone_id)

func _spawn_single_enemy(zone_x: float, _zone_id: int) -> void:
	"""Spawnea UN enemigo"""
	
	# Spawn adelante o atrás (Z)
	var spawn_z = 8.0 if randf() > 0.5 else -8.0
	var spawn_pos = Vector3(zone_x, 0, spawn_z)
	
	# Instanciar
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	enemy.global_position = spawn_pos
	
	# Conectar muerte
	enemy.died.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	"""Se llama cuando un enemigo muere"""
	
	if progress_manager:
		progress_manager.on_enemy_killed()
	
	# ← AGREGAR ESTO: Esperar un frame para que queue_free() termine
	await get_tree().process_frame
	
	# Verificar si todos los enemigos fueron derrotados
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	for enemy in enemies:
		print("  - Enemigo vivo: %s" % enemy.name)
	
	if enemies.size() == 0:
		print("✅ ¡Todos los enemigos derrotados!")
		if progress_manager:
			progress_manager.on_zone_cleared()
