extends Node2D

class_name BattleUnit

@onready var body: Polygon2D = $Body
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
		body.color = Color(0.36, 0.8, 0.55, 1.0)
		hp_bar_fill.color = Color(0.2, 0.85, 0.25, 1.0)
	else:
		body.color = Color(0.86, 0.35, 0.36, 1.0)
		hp_bar_fill.color = Color(0.92, 0.48, 0.22, 1.0)

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


func _update_hp_bar() -> void:
	var ratio := 0.0 if max_hp <= 0 else current_hp / float(max_hp)
	hp_bar_fill.size.x = 56.0 * ratio
	hp_bar_fill.position.x = -28.0
	hp_bar_background.size.x = 56.0
	hp_bar_background.position.x = -28.0
