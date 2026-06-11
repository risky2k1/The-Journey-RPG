extends Node2D

class_name BattleManager

const BattleUnitScene := preload("res://scenes/units/battle_unit.tscn")
const HeroDataResource := preload("res://resources/heroes/adventurer.tres")
const EnemyDataResource := preload("res://resources/enemies/slime.tres")

signal battle_bootstrapped
signal battle_status_changed(status_text: String)

@onready var unit_layer: Node2D = $UnitLayer

var hero_unit: BattleUnit
var enemy_units: Array[BattleUnit] = []
var enemy_respawn_queue: Array[float] = []
var hero_respawn_timer: float = 0.0
var hero_spawn_position := Vector2(180.0, 244.0)
var enemy_spawn_position := Vector2(760.0, 170.0)
var battlefield_left_limit := 150.0
var battlefield_right_limit := 820.0


func _ready() -> void:
	_spawn_hero()
	_spawn_enemy()
	_emit_status()
	battle_bootstrapped.emit()


func _physics_process(delta: float) -> void:
	_tick_respawns(delta)
	_process_hero(delta)
	_process_enemies(delta)
	_emit_status()


func _spawn_hero() -> void:
	hero_unit = BattleUnitScene.instantiate()
	unit_layer.add_child(hero_unit)
	hero_unit.configure({
		"unit_id": HeroDataResource.id,
		"team": &"hero",
		"display_name": HeroDataResource.display_name,
		"max_hp": HeroDataResource.base_hp,
		"attack": HeroDataResource.base_attack,
		"attack_speed": HeroDataResource.base_attack_speed,
		"move_speed": HeroDataResource.base_move_speed,
		"attack_range": HeroDataResource.attack_range,
	})
	hero_unit.global_position = hero_spawn_position


func _spawn_enemy() -> void:
	var enemy: BattleUnit = BattleUnitScene.instantiate()
	unit_layer.add_child(enemy)
	enemy.configure({
		"unit_id": EnemyDataResource.id,
		"team": &"enemy",
		"display_name": EnemyDataResource.display_name,
		"max_hp": EnemyDataResource.base_hp,
		"attack": EnemyDataResource.base_attack,
		"attack_speed": EnemyDataResource.base_attack_speed,
		"move_speed": EnemyDataResource.base_move_speed,
		"attack_range": EnemyDataResource.attack_range,
	})
	enemy.global_position = enemy_spawn_position + Vector2(randf_range(-24.0, 24.0), randf_range(-10.0, 10.0))
	enemy_units.append(enemy)


func _tick_respawns(delta: float) -> void:
	for index in range(enemy_respawn_queue.size() - 1, -1, -1):
		enemy_respawn_queue[index] -= delta
		if enemy_respawn_queue[index] <= 0.0:
			enemy_respawn_queue.remove_at(index)
			_spawn_enemy()

	if hero_respawn_timer > 0.0:
		hero_respawn_timer = max(hero_respawn_timer - delta, 0.0)
		if hero_respawn_timer == 0.0 and is_instance_valid(hero_unit):
			hero_unit.revive()
			hero_unit.global_position = hero_spawn_position


func _process_hero(delta: float) -> void:
	if not is_instance_valid(hero_unit):
		return
	if not hero_unit.is_alive():
		return

	var enemy := _get_first_alive_enemy()
	if enemy == null:
		hero_unit.set_state_text("Waiting")
		return

	hero_unit.tick_cooldown(delta)
	var distance := hero_unit.global_position.distance_to(enemy.global_position)

	if distance > hero_unit.attack_range:
		_move_towards(hero_unit, enemy.global_position, delta)
		hero_unit.set_state_text("Advancing")
	elif hero_unit.can_attack():
		enemy.take_damage(hero_unit.attack)
		hero_unit.reset_attack_cooldown()
		hero_unit.set_state_text("Hit %d" % hero_unit.attack)

		if not enemy.is_alive():
			enemy_units.erase(enemy)
			enemy_respawn_queue.append(1.1)
			enemy.queue_free()


func _process_enemies(delta: float) -> void:
	if not is_instance_valid(hero_unit):
		return

	for enemy in enemy_units:
		if not is_instance_valid(enemy):
			continue
		if not enemy.is_alive():
			continue
		if not hero_unit.is_alive():
			enemy.set_state_text("Waiting")
			continue

		enemy.tick_cooldown(delta)
		var distance := enemy.global_position.distance_to(hero_unit.global_position)

		if distance > enemy.attack_range:
			_move_towards(enemy, hero_unit.global_position, delta)
			enemy.set_state_text("Closing")
		elif enemy.can_attack():
			hero_unit.take_damage(enemy.attack)
			enemy.reset_attack_cooldown()
			enemy.set_state_text("Hit %d" % enemy.attack)

			if not hero_unit.is_alive():
				hero_respawn_timer = 2.0
				hero_unit.set_state_text("Respawn 2s")


func _move_towards(unit: BattleUnit, target_position: Vector2, delta: float) -> void:
	var direction := (target_position - unit.global_position).normalized()
	unit.global_position += direction * unit.move_speed * delta
	unit.global_position.x = clamp(unit.global_position.x, battlefield_left_limit, battlefield_right_limit)


func _get_first_alive_enemy() -> BattleUnit:
	for enemy in enemy_units:
		if is_instance_valid(enemy) and enemy.is_alive():
			return enemy
	return null


func _emit_status() -> void:
	var hero_hp_text := "-"
	if is_instance_valid(hero_unit):
		hero_hp_text = "%d/%d" % [int(hero_unit.current_hp), hero_unit.max_hp]

	var alive_enemy_count := 0
	for enemy in enemy_units:
		if is_instance_valid(enemy) and enemy.is_alive():
			alive_enemy_count += 1

	var status_text := "Combat live  |  Hero HP %s  |  Enemies %d" % [hero_hp_text, alive_enemy_count]
	battle_status_changed.emit(status_text)
