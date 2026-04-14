# scripts/utils/constants.gd
extends Node

# ============== PLAYER ==============
const PLAYER_SPEED = 5.0
const PLAYER_JUMP_FORCE = 7.0
const PLAYER_GRAVITY = 9.8
const PLAYER_MAX_HEALTH = 100
const PLAYER_ATTACK_COOLDOWN = 0.5
const PLAYER_KNOCKBACK_RESIST = 0.5  # El jugador resiste 50% del knockback

# Ataque puño
const PUNCH_DAMAGE = 10
const PUNCH_RANGE = 1.5
const PUNCH_COOLDOWN = 0.3
const PUNCH_KNOCKBACK = 5.0  # ← NUEVO

# Ataque cerveza
const BEER_DAMAGE = 15
const BEER_RANGE = 5.0
const BEER_COOLDOWN = 1.0
const BEER_KNOCKBACK = 8.0  # ← NUEVO
const PLAYER_BEER_AMMO = 5

# ============== ENEMIGOS ==============
const ENEMY_SPEED = 2.5
const ENEMY_HEALTH = 30
const ENEMY_DAMAGE = 10
const ENEMY_DETECTION_RANGE = 10.0
const ENEMY_ATTACK_RANGE = 2.0
const ENEMY_ATTACK_COOLDOWN = 1.5
const ENEMY_KNOCKBACK_RESIST = 0.7  # ← NUEVO (reducen knockback un 30%)

# ============== SCORE ==============
const POINTS_PER_ENEMY = 10
const POINTS_PER_SECOND_SURVIVED = 1

# ============== SPAWN ==============
const SPAWN_INITIAL_ENEMIES = 2  # Enemigos al inicio
const SPAWN_WAVE_INTERVAL = 10.0  # Segundos entre olas
const SPAWN_ENEMIES_PER_WAVE = 1  # Cuántos agregar cada ola
const SPAWN_MAX_ENEMIES = 15  # Máximo de enemigos simultáneos
const SPAWN_POSITIONS = [
	Vector3(-5, 0, -8),
	Vector3(5, 0, -8),
	Vector3(-7, 0, -10),
	Vector3(7, 0, -10),
	Vector3(0, 0, -12),
	Vector3(-3, 0, -10),
	Vector3(3, 0, -10),
]

# ============== BOSS ==============
const BOSS_HEALTH = 200
const BOSS_ATTACK_COOLDOWN = 2.0

# ============== NIVEL ==============
const LEVEL_1_DURATION = 150.0
const LEVEL_2_DURATION = 120.0

# ============== UI ==============
const HUD_FONT_SIZE = 32

# ============== DEBUG ==============
const DEBUG_MODE = true  # ← Mostrar hitboxes en pantalla
