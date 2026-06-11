extends Node2D

class_name BattleUnit

@onready var shadow: Polygon2D = $Shadow
@onready var aura: Polygon2D = $Aura
@onready var back_accent: Polygon2D = $BackAccent
@onready var body: Polygon2D = $Body
@onready var chest_accent: Polygon2D = $ChestAccent
@onready var weapon: Polygon2D = $Weapon
@onready var name_label: Label = $NameLabel
@onready var hp_bar_fill: ColorRect = $HpBarFill
@onready var hp_bar_background: ColorRect = $HpBarBackground
@onready var state_label: Label = $StateLabel

var unit_id: StringName
var team: StringName
var display_name: String = ""
var base_max_hp: int = 100
var base_attack: int = 10
var base_attack_speed: float = 1.0
var base_move_speed: float = 80.0
var base_attack_range: float = 48.0
var max_hp: int = 100
var current_hp: float = 100.0
var attack: int = 10
var attack_speed: float = 1.0
var move_speed: float = 80.0
var attack_range: float = 48.0
var attack_cooldown_remaining: float = 0.0
var alive: bool = true
var formation_slot_index: int = -1
var formation_row_index: int = 0
var formation_column_index: int = 1


func configure(config: Dictionary) -> void:
	unit_id = config.get("unit_id", &"")
	team = config.get("team", &"neutral")
	display_name = config.get("display_name", "Unit")
	base_max_hp = config.get("max_hp", 100)
	base_attack = config.get("attack", 10)
	base_attack_speed = max(config.get("attack_speed", 1.0), 0.1)
	base_move_speed = config.get("move_speed", 80.0)
	base_attack_range = config.get("attack_range", 48.0)
	max_hp = base_max_hp
	current_hp = max_hp
	attack = base_attack
	attack_speed = base_attack_speed
	move_speed = base_move_speed
	attack_range = base_attack_range

	if team == &"hero":
		_apply_hero_visuals()
	else:
		_apply_enemy_visuals()

	name_label.text = display_name
	_update_hp_bar()
	set_state_text("Ready")


func is_alive() -> bool:
	return alive


func tick_cooldown(delta: float) -> void:
	attack_cooldown_remaining = max(attack_cooldown_remaining - delta, 0.0)


func can_attack() -> bool:
	return alive and attack_cooldown_remaining <= 0.0


func reset_attack_cooldown() -> void:
	attack_cooldown_remaining = 1.0 / attack_speed


func take_damage(amount: float) -> void:
	if not alive:
		return

	current_hp = max(current_hp - amount, 0.0)
	_update_hp_bar()

	if current_hp <= 0.0:
		alive = false
		set_state_text("Down")
		modulate = Color(0.6, 0.6, 0.6, 0.8)


func revive() -> void:
	alive = true
	current_hp = max_hp
	attack_cooldown_remaining = 0.0
	modulate = Color.WHITE
	_update_hp_bar()
	set_state_text("Revived")


func set_state_text(value: String) -> void:
	state_label.text = value


func apply_stat_bonus(stat_bonus: Dictionary) -> void:
	var previous_max_hp: int = maxi(max_hp, 1)
	var hp_ratio: float = clampf(current_hp / float(previous_max_hp), 0.0, 1.0)

	max_hp = base_max_hp + int(stat_bonus.get("hp", 0))
	attack = base_attack + int(stat_bonus.get("attack", 0))
	attack_speed = base_attack_speed
	move_speed = base_move_speed
	attack_range = base_attack_range
	current_hp = max_hp * hp_ratio if alive else current_hp
	_update_hp_bar()
	set_state_text("Equipped")


func _apply_hero_visuals() -> void:
	if unit_id == &"hero_apprentice":
		scale = Vector2(0.92, 0.92)
		body.color = Color(0.36, 0.58, 0.92, 1.0)
		back_accent.color = Color(0.15, 0.23, 0.34, 1.0)
		chest_accent.color = Color(0.9, 0.94, 1.0, 0.92)
		weapon.color = Color(0.78, 0.9, 1.0, 1.0)
		aura.color = Color(0.4, 0.7, 1.0, 0.16)
		hp_bar_fill.color = Color(0.42, 0.74, 1.0, 1.0)
		name_label.modulate = Color(0.9, 0.96, 1.0, 1.0)
		return

	scale = Vector2.ONE
	body.color = Color(0.36, 0.8, 0.55, 1.0)
	back_accent.color = Color(0.15, 0.26, 0.2, 1.0)
	chest_accent.color = Color(0.88, 0.98, 0.9, 0.9)
	weapon.color = Color(0.92, 0.84, 0.6, 1.0)
	aura.color = Color(0.35, 0.8, 0.58, 0.14)
	hp_bar_fill.color = Color(0.2, 0.85, 0.25, 1.0)
	name_label.modulate = Color(0.9, 1.0, 0.92, 1.0)


func _apply_enemy_visuals() -> void:
	scale = Vector2.ONE
	if unit_id == &"enemy_slime_king":
		body.color = Color(0.52, 0.2, 0.62, 1.0)
		back_accent.color = Color(0.24, 0.09, 0.28, 1.0)
		chest_accent.color = Color(0.9, 0.72, 1.0, 0.78)
		weapon.color = Color(0.9, 0.54, 0.94, 1.0)
		aura.color = Color(0.78, 0.38, 0.95, 0.2)
		hp_bar_fill.color = Color(0.98, 0.46, 0.82, 1.0)
		name_label.modulate = Color(1.0, 0.9, 1.0, 1.0)
		return
	if unit_id == &"enemy_needle_bat":
		scale = Vector2(0.84, 0.84)
		body.color = Color(0.54, 0.46, 0.9, 1.0)
		back_accent.color = Color(0.18, 0.14, 0.32, 1.0)
		chest_accent.color = Color(0.9, 0.88, 1.0, 0.86)
		weapon.color = Color(0.78, 0.7, 1.0, 1.0)
		aura.color = Color(0.56, 0.52, 1.0, 0.14)
		hp_bar_fill.color = Color(0.74, 0.62, 1.0, 1.0)
		name_label.modulate = Color(0.95, 0.93, 1.0, 1.0)
		return

	body.color = Color(0.86, 0.35, 0.36, 1.0)
	back_accent.color = Color(0.34, 0.12, 0.14, 1.0)
	chest_accent.color = Color(1.0, 0.84, 0.74, 0.82)
	weapon.color = Color(0.95, 0.62, 0.26, 1.0)
	aura.color = Color(0.9, 0.38, 0.32, 0.14)
	hp_bar_fill.color = Color(0.92, 0.48, 0.22, 1.0)
	name_label.modulate = Color(1.0, 0.93, 0.92, 1.0)


func _update_hp_bar() -> void:
	var ratio: float = 0.0 if max_hp <= 0 else current_hp / float(max_hp)
	hp_bar_fill.size.x = 56.0 * ratio
	hp_bar_fill.position.x = -34.0
	hp_bar_background.size.x = 68.0
	hp_bar_background.position.x = -34.0
	shadow.scale.x = 0.82 + (ratio * 0.2)
