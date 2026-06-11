extends Node2D

class_name BattleManager

const BattleUnitScene := preload("res://scenes/units/battle_unit.tscn")
const BattleStateScript := preload("res://scripts/state/battle_state.gd")
const LootDropScene := preload("res://scenes/battle/loot_drop.tscn")
const HeroDataResource := preload("res://resources/heroes/adventurer.tres")
const SecondHeroDataResource := preload("res://resources/heroes/apprentice.tres")
const EnemyDataResource := preload("res://resources/enemies/slime.tres")
const BossDataResource := preload("res://resources/enemies/slime_king.tres")

signal battle_bootstrapped
signal battle_status_changed(status_text: String)
signal battle_event_changed(event_text: String)

@onready var unit_layer: Node2D = $UnitLayer
@onready var loot_layer: Node2D = $LootLayer

var battle_state: BattleState
var hero_units: Array[BattleUnit] = []
var enemy_units: Array[BattleUnit] = []
var enemy_respawn_queue: Array[float] = []
var hero_respawn_timers: Dictionary = {}
var hero_spawn_positions: Array[Vector2] = [
	Vector2(220.0, 236.0),
	Vector2(300.0, 204.0),
	Vector2(188.0, 196.0),
]
var enemy_spawn_position: Vector2 = Vector2(700.0, 194.0)
var battlefield_left_limit: float = 120.0
var battlefield_right_limit: float = 800.0
var current_stage_number: int = 1
var loot_manager: LootManager
var progression_manager: ProgressionManager


func _ready() -> void:
	battle_state = BattleStateScript.new()
	loot_manager = get_parent().get_parent().get_node_or_null("AppRoot/LootManager")
	progression_manager = get_parent().get_parent().get_node_or_null("AppRoot/ProgressionManager")
	if loot_manager != null:
		loot_manager.loot_dropped.connect(_spawn_loot_drop)
		loot_manager.equipment_changed.connect(_apply_equipment_to_heroes)
	if progression_manager != null:
		progression_manager.progression_changed.connect(_on_progression_changed)
	_sync_hero_party()
	_spawn_enemy()
	_emit_event("Stage %d begins" % current_stage_number)
	_emit_status()
	battle_bootstrapped.emit()


func _physics_process(delta: float) -> void:
	_tick_respawns(delta)
	_process_heroes(delta)
	_process_enemies(delta)
	_emit_status()


func _spawn_hero_for_slot(slot_index: int) -> void:
	var hero_data: HeroData = _hero_data_for_slot(slot_index)
	var hero_unit: BattleUnit = BattleUnitScene.instantiate()
	unit_layer.add_child(hero_unit)
	hero_unit.configure({
		"unit_id": hero_data.id,
		"team": &"hero",
		"display_name": hero_data.display_name,
		"max_hp": hero_data.base_hp,
		"attack": hero_data.base_attack,
		"attack_speed": hero_data.base_attack_speed,
		"move_speed": hero_data.base_move_speed,
		"attack_range": hero_data.attack_range,
	})
	hero_unit.global_position = _hero_spawn_position(slot_index)
	if slot_index == 1:
		hero_unit.scale = Vector2(0.92, 0.92)
		hero_unit.body.color = Color(0.52, 0.76, 0.98, 1.0)
		hero_unit.hp_bar_fill.color = Color(0.38, 0.74, 1.0, 1.0)
		hero_unit.name_label.modulate = Color(0.88, 0.96, 1.0, 1.0)
	hero_units.append(hero_unit)
	hero_respawn_timers[slot_index] = 0.0

	if loot_manager != null:
		hero_unit.apply_stat_bonus(loot_manager.get_total_stat_bonus())


func _spawn_enemy() -> void:
	_spawn_enemy_from_data(EnemyDataResource, false)


func _spawn_boss() -> void:
	_spawn_enemy_from_data(BossDataResource, true)
	battle_state.boss_spawned = true
	_emit_event("Boss appeared: %s" % BossDataResource.display_name)


func _spawn_enemy_from_data(data: EnemyData, is_boss: bool) -> void:
	var enemy: BattleUnit = BattleUnitScene.instantiate()
	unit_layer.add_child(enemy)
	enemy.configure({
		"unit_id": data.id,
		"team": &"enemy",
		"display_name": data.display_name,
		"max_hp": data.base_hp + _boss_hp_bonus(is_boss),
		"attack": data.base_attack + _boss_attack_bonus(is_boss),
		"attack_speed": data.base_attack_speed,
		"move_speed": data.base_move_speed,
		"attack_range": data.attack_range,
	})
	enemy.global_position = enemy_spawn_position + Vector2(randf_range(-24.0, 24.0), randf_range(-10.0, 10.0))
	if is_boss:
		enemy.scale = Vector2(1.2, 1.2)
		enemy.global_position = enemy_spawn_position + Vector2(0.0, -8.0)
		enemy.set_state_text("Boss")
	enemy_units.append(enemy)


func _tick_respawns(delta: float) -> void:
	for index in range(enemy_respawn_queue.size() - 1, -1, -1):
		enemy_respawn_queue[index] -= delta
		if enemy_respawn_queue[index] <= 0.0:
			enemy_respawn_queue.remove_at(index)
			if not battle_state.boss_spawned:
				_spawn_enemy()

	for hero_index in range(hero_units.size()):
		var hero_unit: BattleUnit = hero_units[hero_index]
		if not is_instance_valid(hero_unit):
			continue
		var timer_value: float = float(hero_respawn_timers.get(hero_index, 0.0))
		if timer_value <= 0.0:
			continue
		timer_value = maxf(timer_value - delta, 0.0)
		hero_respawn_timers[hero_index] = timer_value
		if is_zero_approx(timer_value):
			hero_unit.revive()
			hero_unit.global_position = _hero_spawn_position(hero_index)


func _process_heroes(delta: float) -> void:
	for hero_unit in hero_units:
		if not is_instance_valid(hero_unit):
			continue
		if not hero_unit.is_alive():
			continue

		var enemy: BattleUnit = _get_closest_alive_enemy(hero_unit.global_position)
		if enemy == null:
			hero_unit.set_state_text("Waiting")
			continue

		hero_unit.tick_cooldown(delta)
		var distance: float = hero_unit.global_position.distance_to(enemy.global_position)

		if distance > hero_unit.attack_range:
			_move_towards(hero_unit, enemy.global_position, delta)
			hero_unit.set_state_text("Advancing")
		elif hero_unit.can_attack():
			enemy.take_damage(hero_unit.attack)
			hero_unit.reset_attack_cooldown()
			hero_unit.set_state_text("Hit %d" % hero_unit.attack)

			if not enemy.is_alive():
				_handle_enemy_defeated(enemy)
				enemy_units.erase(enemy)
				enemy.queue_free()


func _process_enemies(delta: float) -> void:
	for enemy in enemy_units:
		if not is_instance_valid(enemy):
			continue
		if not enemy.is_alive():
			continue
		var hero_target: BattleUnit = _get_closest_alive_hero(enemy.global_position)
		if hero_target == null:
			enemy.set_state_text("Waiting")
			continue

		enemy.tick_cooldown(delta)
		var distance: float = enemy.global_position.distance_to(hero_target.global_position)

		if distance > enemy.attack_range:
			_move_towards(enemy, hero_target.global_position, delta)
			enemy.set_state_text("Closing")
		elif enemy.can_attack():
			hero_target.take_damage(enemy.attack)
			enemy.reset_attack_cooldown()
			enemy.set_state_text("Hit %d" % enemy.attack)

			if not hero_target.is_alive():
				var hero_slot_index: int = hero_units.find(hero_target)
				if hero_slot_index >= 0:
					hero_respawn_timers[hero_slot_index] = 2.0
				hero_target.set_state_text("Respawn 2s")


func _move_towards(unit: BattleUnit, target_position: Vector2, delta: float) -> void:
	var direction := (target_position - unit.global_position).normalized()
	unit.global_position += direction * unit.move_speed * delta
	unit.global_position.x = clamp(unit.global_position.x, battlefield_left_limit, battlefield_right_limit)


func _get_closest_alive_enemy(source_position: Vector2) -> BattleUnit:
	var closest_enemy: BattleUnit
	var closest_distance: float = INF
	for enemy in enemy_units:
		if not is_instance_valid(enemy) or not enemy.is_alive():
			continue
		var distance: float = source_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	return closest_enemy


func _get_closest_alive_hero(source_position: Vector2) -> BattleUnit:
	var closest_hero: BattleUnit
	var closest_distance: float = INF
	for hero_unit in hero_units:
		if not is_instance_valid(hero_unit) or not hero_unit.is_alive():
			continue
		var distance: float = source_position.distance_to(hero_unit.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_hero = hero_unit
	return closest_hero


func _emit_status() -> void:
	var hero_hp_segments: PackedStringArray = []
	var alive_hero_count: int = 0
	for hero_unit in hero_units:
		if not is_instance_valid(hero_unit):
			continue
		if hero_unit.is_alive():
			alive_hero_count += 1
		hero_hp_segments.append("%s %d/%d" % [hero_unit.display_name, int(hero_unit.current_hp), hero_unit.max_hp])

	var hero_hp_text: String = "-" if hero_hp_segments.is_empty() else ", ".join(hero_hp_segments)

	var alive_enemy_count := 0
	for enemy in enemy_units:
		if is_instance_valid(enemy) and enemy.is_alive():
			alive_enemy_count += 1

	var boss_text: String = "Boss active" if battle_state.boss_spawned else "Boss soon"
	var status_text: String = "Stage %d  |  Kills %d/%d  |  %s  |  Party %d/%d  |  HP %s  |  Foes %d" % [current_stage_number, battle_state.kill_count, battle_state.kill_target, boss_text, alive_hero_count, hero_units.size(), hero_hp_text, alive_enemy_count]
	battle_status_changed.emit(status_text)


func _handle_enemy_defeated(enemy: BattleUnit) -> void:
	if loot_manager != null:
		loot_manager.roll_loot_for_enemy(enemy.unit_id, enemy.global_position + Vector2(0.0, -18.0))
	if progression_manager != null:
		var reward: Dictionary = _reward_for_enemy(enemy.unit_id)
		progression_manager.grant_rewards(reward["exp"], reward["coin"])

	if enemy.unit_id == BossDataResource.id:
		battle_state.boss_defeated = true
		_complete_stage()
		return

	battle_state.kill_count += 1
	_emit_event("Kill %d/%d" % [battle_state.kill_count, battle_state.kill_target])

	if battle_state.kill_count >= battle_state.kill_target and not battle_state.boss_spawned:
		_spawn_boss()
	else:
		enemy_respawn_queue.append(1.1)


func _complete_stage() -> void:
	current_stage_number += 1
	battle_state.kill_count = 0
	battle_state.kill_target += 4
	battle_state.boss_spawned = false
	battle_state.boss_defeated = false
	_emit_event("Stage %d unlocked" % current_stage_number)
	_spawn_enemy()


func _boss_hp_bonus(is_boss: bool) -> int:
	if not is_boss:
		return 0
	return (current_stage_number - 1) * 20


func _boss_attack_bonus(is_boss: bool) -> int:
	if not is_boss:
		return 0
	return current_stage_number - 1


func _emit_event(event_text: String) -> void:
	battle_event_changed.emit(event_text)


func _spawn_loot_drop(item_data: ItemData, world_position: Vector2) -> void:
	var loot_drop: LootDrop = LootDropScene.instantiate()
	loot_layer.add_child(loot_drop)
	loot_drop.global_position = world_position
	loot_drop.configure(item_data)
	loot_drop.pickup_requested.connect(_on_loot_pickup)
	_emit_event("Loot dropped: %s" % item_data.display_name)


func _on_loot_pickup(item_data: ItemData) -> void:
	if loot_manager != null:
		loot_manager.register_pickup(item_data)
	_emit_event("Picked up: %s" % item_data.display_name)


func _apply_equipment_to_heroes(total_stats: Dictionary, _summary_text: String) -> void:
	for hero_unit in hero_units:
		if is_instance_valid(hero_unit):
			hero_unit.apply_stat_bonus(total_stats)


func _reward_for_enemy(enemy_id: StringName) -> Dictionary:
	if enemy_id == BossDataResource.id:
		return {
			"exp": BossDataResource.reward_exp,
			"coin": BossDataResource.reward_coin,
		}

	return {
		"exp": EnemyDataResource.reward_exp,
		"coin": EnemyDataResource.reward_coin,
	}


func export_state() -> Dictionary:
	return {
		"current_stage_number": current_stage_number,
		"kill_count": battle_state.kill_count,
		"kill_target": battle_state.kill_target,
		"boss_spawned": battle_state.boss_spawned,
		"boss_defeated": battle_state.boss_defeated,
	}


func apply_state(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return

	current_stage_number = int(snapshot.get("current_stage_number", 1))
	battle_state.kill_count = int(snapshot.get("kill_count", 0))
	battle_state.kill_target = int(snapshot.get("kill_target", 20))
	battle_state.boss_spawned = bool(snapshot.get("boss_spawned", false))
	battle_state.boss_defeated = bool(snapshot.get("boss_defeated", false))

	_clear_enemies()
	enemy_respawn_queue.clear()
	_sync_hero_party()

	if battle_state.boss_spawned and not battle_state.boss_defeated:
		_spawn_boss()
	else:
		_spawn_enemy()

	_emit_event("Save loaded")
	_emit_status()


func _clear_enemies() -> void:
	for enemy in enemy_units:
		if is_instance_valid(enemy):
			enemy.queue_free()
	enemy_units.clear()


func _on_progression_changed(summary: Dictionary) -> void:
	var unlocked_slot_count: int = int(summary.get("unlocked_team_slot_count", 1))
	_sync_hero_party(unlocked_slot_count)
	_emit_status()


func _sync_hero_party(unlocked_slot_count: int = -1) -> void:
	var desired_hero_count: int = _desired_hero_count(unlocked_slot_count)
	while hero_units.size() < desired_hero_count:
		_spawn_hero_for_slot(hero_units.size())
	while hero_units.size() > desired_hero_count:
		var hero_unit: BattleUnit = hero_units.pop_back()
		var removed_slot_index: int = hero_units.size()
		hero_respawn_timers.erase(removed_slot_index)
		if is_instance_valid(hero_unit):
			hero_unit.queue_free()
	for hero_index in range(hero_units.size()):
		if is_instance_valid(hero_units[hero_index]):
			hero_units[hero_index].global_position = _hero_spawn_position(hero_index)


func _desired_hero_count(unlocked_slot_count: int = -1) -> int:
	if unlocked_slot_count < 0:
		if progression_manager != null and progression_manager.has_method("get_summary"):
			var summary: Dictionary = progression_manager.get_summary()
			unlocked_slot_count = int(summary.get("unlocked_team_slot_count", 1))
		else:
			unlocked_slot_count = 1
	return mini(unlocked_slot_count, 2)


func _hero_data_for_slot(slot_index: int) -> HeroData:
	match slot_index:
		1:
			return SecondHeroDataResource
		_:
			return HeroDataResource


func _hero_spawn_position(slot_index: int) -> Vector2:
	if slot_index >= 0 and slot_index < hero_spawn_positions.size():
		return hero_spawn_positions[slot_index]
	return hero_spawn_positions[0]
