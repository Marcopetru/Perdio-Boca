# scripts/managers/progress_manager.gd
extends Node3D

# ============== VARIABLES ==============
var player: Node3D = null
var current_level = 1
var current_zone = 0
var level_duration = 0.0  #(no la usamos pero la declaro)
var time_remaining = 0.0  #(no la usamos pero la declaro)
var current_score = 0
var enemies_killed = 0
var level_active = true

# Definición de zonas
var zones = [
	{"id": 1, "x": -30.0, "enemies": 2, "next_x": 0.0},      # Zona izquierda
	{"id": 2, "x": 0.0, "enemies": 3, "next_x": 30.0},       # Zona centro
	{"id": 3, "x": 30.0, "enemies": 4, "next_x": 60.0},      # Zona derecha
]

var current_zone_controller: Area3D = null
var zone_blocked = true

# ============== SIGNALS ==============
signal level_started(level_number: int)
signal zone_activated(zone_id: int, enemies: int)
signal zone_cleared(zone_id: int)
signal enemy_killed()
signal level_finished(victory: bool)
signal score_changed(new_score: int)
signal zone_blocked_changed(blocked: bool)

func _ready() -> void:
	add_to_group("progress_manager")
	
	player = get_tree().get_root().find_child("Player", true, false)
	
	if player == null:
		print("❌ ProgressManager: No encontré al jugador")
		return
	
	player.died.connect(_on_player_died)
	
	_activate_zone(0)
	
	time_remaining = level_duration
	
	print("✅ ProgressManager inicializado")
	emit_signal("level_started", current_level)

func _process(_delta: float) -> void:
	if not level_active or player == null:
		return
	
	# Verificar si el jugador intenta pasar una zona bloqueada
	if zone_blocked and current_zone < zones.size():
		var zone_limit = zones[current_zone]["next_x"]  # ← CAMBIAR: next_z a next_x
		
		if player.global_position.x > zone_limit:  # ← CAMBIAR: position.z a position.x
			# Bloquear jugador - no puede pasar
			player.global_position.x = zone_limit  # ← CAMBIAR: position.z a position.x
			print("⛔ ¡BLOQUEADO! Derrota a todos los enemigos antes de avanzar")
	
	# Verificar si el jugador entró a una zona
	_check_zone_entry()

func _check_zone_entry() -> void:
	"""Verifica si el jugador entró a una zona y la activa"""
	
	if current_zone >= zones.size():
		return
	
	var current_zone_data = zones[current_zone]
	var player_x = player.global_position.x
	
	# Si el jugador está dentro de rango de la zona y aún no está activada
	if player_x >= current_zone_data["x"] - 10.0 and not zone_blocked:
		# Activar zona
		_activate_zone(current_zone)

func _activate_zone(zone_index: int) -> void:
	"""Activa una zona"""
	
	if zone_index >= zones.size():
		_go_to_boss()
		return
	
	current_zone = zone_index
	var zone_data = zones[zone_index]
	
	zone_blocked = true
	emit_signal("zone_blocked_changed", true)
	emit_signal("zone_activated", zone_data["id"], zone_data["enemies"])
	
	print("🌊 ZONA %d ACTIVADA" % zone_data["id"])
	
	var spawn_manager = get_tree().get_root().find_child("SpawnManager", true, false)
	if spawn_manager:
		spawn_manager.spawn_zone_enemies(zone_data["id"], zone_data["enemies"], zone_data["x"])

func on_zone_cleared() -> void:
	"""Se llama cuando despejaron la zona actual"""
	
	zone_blocked = false
	emit_signal("zone_blocked_changed", false)
	emit_signal("zone_cleared", zones[current_zone]["id"])
	
	print("✅ Zona despejada. Puedes avanzar a la siguiente")
	
	# Cargar la siguiente zona
	current_zone += 1
	
	#Hay que verificar si hay más zonas
	if current_zone >= zones.size():
		# ¡No hay más zonas! Ir al boss
		_go_to_boss()
	else:
		# Hay más zonas, activar la siguiente
		_activate_zone(current_zone)

func on_enemy_killed() -> void:
	"""Se llama cuando matan un enemigo"""
	
	enemies_killed += 1
	emit_signal("enemy_killed")
	
	current_score += 10
	emit_signal("score_changed", current_score)


func _go_to_boss() -> void:
	"""Transición al boss"""
	
	current_score += 2000  # Bonus por completar el nivel
	emit_signal("score_changed", current_score)
	
	level_active = false
	
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/levels/level_2_boss.tscn")

func _on_player_died() -> void:
	"""Se llama cuando el jugador muere"""
	
	if not level_active:
		return
	
	level_active = false
	
	emit_signal("level_finished", false)
	
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
