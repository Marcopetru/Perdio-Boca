# scripts/player/player.gd
extends CharacterBody3D

# ============== REFERENCIAS ==============
@onready var animation_player = $AnimationPlayer
@onready var combat_system = $CombatSystem
@onready var movement_component = $Movement

# ============== VARIABLES DE ESTADO ==============
var current_health: int
var is_alive: bool = true
var is_attacking: bool = false
var beer_ammo: int

# ← NUEVO: Variables de knockback
var knockback_velocity = Vector3.ZERO
var knockback_duration = 0.0

# ============== SEÑALES ==============
signal health_changed(new_health)
signal died
signal beer_ammo_changed(new_ammo)

func _ready() -> void:
	current_health = Constants.PLAYER_MAX_HEALTH
	beer_ammo = Constants.PLAYER_BEER_AMMO
	emit_signal("health_changed", current_health)
	emit_signal("beer_ammo_changed", beer_ammo)

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	# ← NUEVO: Procesar knockback
	knockback_duration = max(knockback_duration - delta, 0.0)
	
	var input_vector = get_input()
	
	# Si está recibiendo knockback, aplicar eso en lugar del movimiento normal
	if knockback_duration > 0:
		velocity.x = knockback_velocity.x
		velocity.z = knockback_velocity.z
		# No recibe input mientras está siendo empujado
	else:
		# Movimiento normal
		movement_component.process(delta, input_vector)
	
	# Ataques
	if Input.is_action_just_pressed("attack_punch"):
		combat_system.punch()
	
	if Input.is_action_just_pressed("attack_beer") and beer_ammo > 0:
		combat_system.throw_beer()
		beer_ammo -= 1
		emit_signal("beer_ammo_changed", beer_ammo)

func get_input() -> Vector3:
	var input = Vector3.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.z = Input.get_axis("ui_up", "ui_down")
	return input.normalized()

func take_damage(damage: int) -> void:
	current_health -= damage
	emit_signal("health_changed", current_health)
	
	print("💢 Jugador recibe daño: ", damage, " | Vida: ", current_health)
	
	# ← NUEVO: Parpadeo rojo al recibir daño
	_flash_red()
	
	if current_health <= 0:
		die()

# ← NUEVA FUNCIÓN: Parpadeo rojo
func _flash_red() -> void:
	"""Hace que el jugador parpadee en rojo al recibir daño"""
	
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

# ← NUEVA FUNCIÓN: Recibir knockback
func take_knockback(knockback_vector: Vector3) -> void:
	"""Recibe un empuje"""
	var adjusted_knockback = knockback_vector * (1.0 - Constants.PLAYER_KNOCKBACK_RESIST)
	knockback_velocity = adjusted_knockback
	knockback_duration = 0.2
	
	print("💨 Jugador recibe knockback")

func die() -> void:
	is_alive = false
	emit_signal("died")
	print("💀 ¡Jugador muere!")
