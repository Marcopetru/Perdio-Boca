# scripts/ui/hud.gd
extends CanvasLayer

# ============== REFERENCIAS ==============
@onready var debug_label: Label = $DebugLabel
@onready var health_label: Label = $HealthContainer/HealthLabel
@onready var ammo_label: Label = $AmmoContainer/AmmoLabel
@onready var health_bar: ProgressBar = $HealthContainer/HealthBar

# ============== VARIABLES ==============
var current_zone: int = 0
var enemies_in_zone: int = 0
var enemies_killed: int = 0
var player: Node3D = null

func _ready() -> void:
	# Encontrar al jugador
	player = get_tree().get_root().find_child("Player", true, false)
	
	if player == null:
		print("❌ HUD: No encontré al jugador")
		return
	
	# ← NUEVO: Conectar signals del jugador
	player.health_changed.connect(_on_player_health_changed)
	player.beer_ammo_changed.connect(_on_player_ammo_changed)
	
	# Conectar con ProgressManager
	var progress_manager = get_tree().get_root().find_child("ProgressManager", true, false)
	
	if progress_manager:
		progress_manager.zone_activated.connect(_on_zone_activated)
		progress_manager.enemy_killed.connect(_on_enemy_killed)
		progress_manager.zone_cleared.connect(_on_zone_cleared)
	
	# ← NUEVO: Inicializar displays
	_update_health_display(player.current_health)
	_update_ammo_display(player.beer_ammo)
	
	print("✅ HUD inicializado")

# ============== ZONE SIGNALS ==============

func _on_zone_activated(zone_id: int, enemies: int) -> void:
	"""Se llama cuando se activa una zona"""
	
	current_zone = zone_id
	enemies_in_zone = enemies
	enemies_killed = 0
	
	_update_debug_label()
	print("📊 HUD: Zona %d activada (%d enemigos)" % [zone_id, enemies])

func _on_enemy_killed() -> void:
	"""Se llama cuando matan un enemigo"""
	
	enemies_killed += 1
	_update_debug_label()

func _on_zone_cleared(zone_id: int) -> void:
	"""Se llama cuando despejaron la zona"""
	
	print("📊 HUD: Zona %d despejada" % zone_id)
	_update_debug_label()

# ============== PLAYER SIGNALS ==============

# ← NUEVA: Signal de vida
func _on_player_health_changed(new_health: int) -> void:
	"""Se llama cuando cambia la vida del jugador"""
	
	_update_health_display(new_health)
	print("❤️ HUD: Vida actualizada a %d" % new_health)

# ← NUEVA: Signal de munición
func _on_player_ammo_changed(new_ammo: int) -> void:
	"""Se llama cuando cambia la munición de cervezas"""
	
	_update_ammo_display(new_ammo)
	print("🍺 HUD: Cervezas actualizadas a %d" % new_ammo)

# ============== UPDATES ==============

func _update_health_display(health: int) -> void:
	"""Actualiza la barra y label de vida"""
	
	health_label.text = "HP: %d/%d" % [health, Constants.PLAYER_MAX_HEALTH]
	health_bar.value = float(health) / float(Constants.PLAYER_MAX_HEALTH) * 100.0
	
	# ← NUEVO: Cambiar color según vida
	var color = Color.GREEN
	if health < Constants.PLAYER_MAX_HEALTH * 0.5:  # Menos del 50%
		color = Color.YELLOW
	if health < Constants.PLAYER_MAX_HEALTH * 0.25:  # Menos del 25%
		color = Color.RED
	
	health_bar.modulate = color

func _update_ammo_display(ammo: int) -> void:
	"""Actualiza el label de munición"""
	
	ammo_label.text = "Cervezas: %d" % ammo

func _update_debug_label() -> void:
	"""Actualiza el texto de zonas y enemigos"""
	
	var remaining = enemies_in_zone - enemies_killed
	
	debug_label.text = "ZONA: %d\nEnemigos: %d/%d" % [
		current_zone,
		remaining,
		enemies_in_zone
	]
