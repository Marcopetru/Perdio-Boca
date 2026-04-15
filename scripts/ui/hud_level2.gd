# scripts/ui/hud_level2.gd
extends CanvasLayer

# ============== REFERENCIAS ==============
var health_label: Label
var ammo_label: Label
var health_bar: ProgressBar

var boss_name_label: Label
var boss_health_label: Label
var boss_health_bar: ProgressBar

# ============== VARIABLES ==============
var player: Node3D = null
var boss: Node3D = null

func _ready() -> void:
	#Obtener referencias DESPUÉS de que la escena esté lista
	health_label = $HealthContainer/HealthLabel
	ammo_label = $AmmoContainer/AmmoLabel
	health_bar = $HealthContainer/HealthBar
	
	boss_name_label = $BossContainer/BossNameLabel
	boss_health_label = $BossContainer/BossHealthLabel
	boss_health_bar = $BossContainer/BossHealthBar
	
	# Encontrar al jugador
	player = get_tree().get_root().find_child("Player", true, false)
	
	if player == null:
		print("❌ HUD Level 2: No encontré al jugador")
		return
	
	# Conectar signals del jugador
	player.health_changed.connect(_on_player_health_changed)
	player.beer_ammo_changed.connect(_on_player_ammo_changed)
	
	# Inicializar displays del jugador
	_update_health_display(player.current_health)
	_update_ammo_display(player.beer_ammo)
	
	#Esperar un frame para que el Boss esté listo
	await get_tree().process_frame
	
	#Encontrar al Boss
	boss = get_tree().get_root().find_child("Boss", true, false)
	
	if boss == null:
		print("❌ HUD Level 2: No encontré al Boss")
		return
	
	print("✅ Boss encontrado: %s | Vida: %d/%d" % [boss.name, boss.current_health, boss.max_health])
	
	#Conectar signal de vida del Boss
	if boss.has_signal("health_changed"):
		boss.health_changed.connect(_on_boss_health_changed)
		print("✅ Signal 'health_changed' del Boss conectado")
	else:
		print("❌ El Boss NO tiene signal 'health_changed'")
	
	#Inicializar displays del Boss
	_update_boss_display(boss.current_health, boss.max_health)
	boss_name_label.text = "McDonald's"
	
	print("✅ HUD Level 2 inicializado")

# ============== PLAYER SIGNALS ==============

func _on_player_health_changed(new_health: int) -> void:
	"""Se llama cuando cambia la vida del jugador"""
	
	_update_health_display(new_health)
	print("❤️ HUD: Vida actualizada a %d" % new_health)

func _on_player_ammo_changed(new_ammo: int) -> void:
	"""Se llama cuando cambia la munición de cervezas"""
	
	_update_ammo_display(new_ammo)
	print("🍺 HUD: Cervezas actualizadas a %d" % new_ammo)

# ============== BOSS SIGNALS ← NUEVO ==============

func _on_boss_health_changed(new_health: int) -> void:
	"""Se llama cuando cambia la vida del Boss"""
	
	print("🔔 Signal health_changed recibido! Vida: %d" % new_health)
	print("   Boss max_health: %d" % boss.max_health)
	print("   boss_health_bar: ", boss_health_bar)
	print("   boss_health_label: ", boss_health_label)
	
	if boss == null:
		print("❌ Boss es NULL!")
		return
	
	_update_boss_display(new_health, boss.max_health)
	print("👹 HUD: Vida del Boss actualizada a %d" % new_health)

# ============== UPDATES ==============

func _update_health_display(health: int) -> void:
	"""Actualiza la barra y label de vida del JUGADOR"""
	
	health_label.text = "HP: %d/%d" % [health, Constants.PLAYER_MAX_HEALTH]
	health_bar.value = float(health) / float(Constants.PLAYER_MAX_HEALTH) * 100.0
	
	# Cambiar color según vida
	var color = Color.GREEN
	if health < Constants.PLAYER_MAX_HEALTH * 0.5:  # Menos del 50%
		color = Color.YELLOW
	if health < Constants.PLAYER_MAX_HEALTH * 0.25:  # Menos del 25%
		color = Color.RED
	
	health_bar.modulate = color

func _update_ammo_display(ammo: int) -> void:
	"""Actualiza el label de munición"""
	
	ammo_label.text = "Cervezas: %d" % ammo

#Actualizar display del Boss
func _update_boss_display(health: int, max_health: int) -> void:
	"""Actualiza la barra y label de vida del BOSS"""
	
	boss_health_label.text = "HP: %d/%d" % [health, max_health]
	boss_health_bar.value = float(health) / float(max_health) * 100.0
	
	# Cambiar color según vida del boss
	var color = Color.RED  # Boss siempre en rojo amenazante
	if health > max_health * 0.5:
		color = Color.ORANGE  # Orange cuando está más fuerte
	
	boss_health_bar.modulate = color
