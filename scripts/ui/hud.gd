# scripts/ui/hud.gd
extends CanvasLayer

# ============== REFERENCIAS ==============
@onready var debug_label: Label = $DebugLabel
@onready var health_label: Label = $HealthContainer/HealthLabel
@onready var ammo_label: Label = $AmmoContainer/AmmoLabel

# ============== VARIABLES ==============
var current_zone: int = 0
var enemies_in_zone: int = 0
var enemies_killed: int = 0

func _ready() -> void:
    # Conectar con ProgressManager
    var progress_manager = get_tree().get_root().find_child("ProgressManager", true, false)
    
    if progress_manager:
        progress_manager.zone_activated.connect(_on_zone_activated)
        progress_manager.enemy_killed.connect(_on_enemy_killed)
        progress_manager.zone_cleared.connect(_on_zone_cleared)
    
    print("✅ HUD inicializado")

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

func _on_zone_cleared() -> void:
    """Se llama cuando despejaron la zona"""
    
    print("📊 HUD: Zona %d despejada" % current_zone)
    _update_debug_label()

func _update_debug_label() -> void:
    """Actualiza el texto del DebugLabel"""
    
    var remaining = enemies_in_zone - enemies_killed
    
    debug_label.text = "ZONA: %d\nEnemigos: %d/%d" % [
        current_zone,
        remaining,
        enemies_in_zone
    ]
