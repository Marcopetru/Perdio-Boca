# scripts/levels/zone_controller.gd
extends Area3D

# ============== VARIABLES ==============
@export var zone_id: int = 1
@export var zone_x_position: float = -30.0  # ← CAMBIAR: zone_z_position a zone_x_position
@export var enemies_to_spawn: int = 2
@export var next_zone_x: float = 0.0  # ← CAMBIAR: next_zone_z a next_zone_x

var enemies_in_zone = 0
var enemies_killed_in_zone = 0
var zone_active = false

# ============== SIGNALS ==============
signal zone_cleared

func _ready() -> void:
	add_to_group("zone")

func activate_zone() -> void:
	"""Se llama cuando el jugador entra a esta zona"""
	
	if zone_active:
		return
	
	zone_active = true
	enemies_in_zone = enemies_to_spawn
	enemies_killed_in_zone = 0
	
	
	var spawn_manager = get_tree().get_root().find_child("SpawnManager", true, false)
	if spawn_manager:
		spawn_manager.spawn_enemies_in_zone(zone_id, enemies_to_spawn, zone_x_position)  # ← CAMBIAR: z a x

func on_enemy_killed() -> void:
	"""Se llama cuando matan un enemigo en esta zona"""
	
	enemies_killed_in_zone += 1
	
	if enemies_killed_in_zone >= enemies_in_zone:
		_zone_cleared()

func _zone_cleared() -> void:
	"""Se llama cuando se elimina a todos los enemigos"""
	
	zone_active = false
	emit_signal("zone_cleared")
