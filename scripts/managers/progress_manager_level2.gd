# scripts/managers/progress_manager_level2.gd
extends Node3D

# ============== VARIABLES ==============
var player: Node3D = null
var boss: Node3D = null
var level_active: bool = true
var current_score: int = 0

# ============== SIGNALS ==============
signal level_finished(victory: bool)
signal score_changed(new_score: int)

func _ready() -> void:
	add_to_group("progress_manager")
	
	# Encontrar al jugador
	player = get_tree().get_root().find_child("Player", true, false)
	
	if player == null:
		print("❌ ProgressManager Level 2: No encontré al jugador")
		return
	
	# Conectar signal de muerte del jugador
	player.died.connect(_on_player_died)
	
	# Encontrar al Boss
	boss = get_tree().get_root().find_child("Boss", true, false)
	
	if boss == null:
		print("❌ ProgressManager Level 2: No encontré al Boss")
		return
	
	# Conectar signal de muerte del Boss
	boss.died.connect(_on_boss_died)
	
	print("✅ ProgressManager Level 2 inicializado")
	print("   Jugador: %s | Boss: %s" % [player.name, boss.name])

func _process(_delta: float) -> void:
	if not level_active or player == null:
		return
	
	# (Aquí podría haber lógica adicional si necesitas)

# ============== SIGNALS DEL JUGADOR ==============

func _on_player_died() -> void:
	"""Se llama cuando el jugador muere"""
	
	if not level_active:
		return
	
	level_active = false
	
	print("💀 ¡DERROTA! Score: %d" % current_score)
	
	emit_signal("level_finished", false)
	
	# Esperar 2 segundos y recargar nivel
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

# ============== SIGNALS DEL BOSS ==============

func _on_boss_died() -> void:
	"""Se llama cuando el Boss muere - ¡VICTORIA!"""
	
	if not level_active:
		return
	
	level_active = false
	
	# Bonus por derrotar al Boss
	current_score += 5000
	emit_signal("score_changed", current_score)
	
	print("🎉 ¡VICTORIA! ¡Boss derrotado!")
	print("   Score final: %d" % current_score)
	
	emit_signal("level_finished", true)
	
	# Esperar 2 segundos y ir a pantalla de victoria
	await get_tree().create_timer(2.0).timeout
	_go_to_victory_screen()

func _go_to_victory_screen() -> void:
	"""Transición a pantalla de victoria"""
	
	print("🎯 Yendo a pantalla de victoria...")
	
	# Por ahora, recargar el nivel (después crearemos la pantalla de victoria)
	# get_tree().change_scene_to_file("res://scenes/ui/victory_screen.tscn")
	
	# Temporalmente, volver al menú o recargar
	get_tree().reload_current_scene()
