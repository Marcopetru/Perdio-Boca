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
	print("📍 Zona %d configurada (X=%.1f)" % [zone_id, zone_x_position])  # ← CAMBIAR: Z a X

func activate_zone() -> void:
	"""Se llama cuando el jugador entra a esta zona"""
	
	if zone_active:
		return
	
	zone_active = true
	enemies_in_zone = enemies_to_spawn
	enemies_killed_in_zone = 0
	
	print("🌊 ¡ZONA %d ACTIVADA! Spawnando %d enemigos" % [zone_id, enemies_to_spawn])
	
	var spawn_manager = get_tree().get_root().find_child("SpawnManager", true, false)
	if spawn_manager:
		spawn_manager.spawn_enemies_in_zone(zone_id, enemies_to_spawn, zone_x_position)  # ← CAMBIAR: z a x

func on_enemy_killed() -> void:
	"""Se llama cuando matan un enemigo en esta zona"""
	
	enemies_killed_in_zone += 1
	
	print("💀 Enemigos restantes en zona %d: %d/%d" % [zone_id, enemies_to_spawn - enemies_killed_in_zone, enemies_to_spawn])
	
	if enemies_killed_in_zone >= enemies_in_zone:
		_zone_cleared()

func _zone_cleared() -> void:
	"""Se llama cuando se elimina a todos los enemigos"""
	
	zone_active = false
	print("✅ ¡Zona %d despejada! Puedes avanzar" % zone_id)
	emit_signal("zone_cleared")
