extends Node2D

class_name BattleManager

const BattleUnitScene := preload("res://scenes/units/battle_unit.tscn")
const BattleStateScript := preload("res://scripts/state/battle_state.gd")
const LootDropScene := preload("res://scenes/battle/loot_drop.tscn")
const HeroDataResource := preload("res://resources/heroes/adventurer.tres")
const SecondHeroDataResource := preload("res://resources/heroes/apprentice.tres")
const TARGET_RULE_FRONT_FIRST := &"front_first"
const TARGET_RULE_LOWEST_HP := &"lowest_hp"
const TARGET_RULE_BACK_ROW_FIRST := &"back_row_first"
const DEFAULT_STAGE_ID := &"stage_001"

signal battle_bootstrapped
signal battle_status_changed(status_text: String)
signal battle_event_changed(event_text: String)

@onready var unit_layer: Node2D = $UnitLayer
@onready var loot_layer: Node2D = $LootLayer

var battle_state: BattleState
var hero_units: Array[BattleUnit] = []
var enemy_units: Array[BattleUnit] = []
var enemy_respawn_queue: Array = []
var hero_respawn_timers: Dictionary = {}
var hero_units_by_id: Dictionary = {}
var enemy_data_by_instance_id: Dictionary = {}
var formation_positions_by_slot: Dictionary = {
	0: Vector2(332.0, 188.0),
	1: Vector2(332.0, 220.0),
	2: Vector2(332.0, 252.0),
	3: Vector2(264.0, 188.0),
	4: Vector2(264.0, 220.0),
	5: Vector2(264.0, 252.0),
	6: Vector2(196.0, 188.0),
	7: Vector2(196.0, 220.0),
	8: Vector2(196.0, 252.0),
}
var enemy_spawn_position: Vector2 = Vector2(700.0, 194.0)
var battlefield_left_limit: float = 120.0
var battlefield_right_limit: float = 800.0
var current_stage_number: int = 1
var loot_manager: LootManager
var progression_manager: ProgressionManager
var team_manager: TeamManager
var data_registry: DataRegistry
const HERO_RESPAWN_DELAY := 10.0


func _ready() -> void:
	battle_state = BattleStateScript.new()
	loot_manager = get_parent().get_parent().get_node_or_null("AppRoot/LootManager")
	progression_manager = get_parent().get_parent().get_node_or_null("AppRoot/ProgressionManager")
	team_manager = get_parent().get_parent().get_node_or_null("AppRoot/TeamManager")
	data_registry = get_parent().get_parent().get_node_or_null("AppRoot/DataRegistry")
	if loot_manager != null:
		loot_manager.loot_dropped.connect(_spawn_loot_drop)
		loot_manager.equipment_changed.connect(_apply_equipment_to_heroes)
	if team_manager != null:
		team_manager.team_changed.connect(_on_team_changed)
	if not _validate_battle_data():
		set_physics_process(false)
		return
	_apply_stage_data()
	_sync_hero_party(true)
	_spawn_enemy()
	_emit_event("%s begins" % _current_stage_title())
	_emit_status()
	battle_bootstrapped.emit()


func _physics_process(delta: float) -> void:
	_tick_respawns(delta)
	_process_heroes(delta)
	_process_enemies(delta)
	_emit_status()


func _spawn_hero_for_entry(formation_entry: Dictionary) -> void:
	var hero_id: StringName = StringName(formation_entry.get("hero_id", &""))
	var slot_index: int = int(formation_entry.get("slot_index", 1))
	var row_index: int = int(formation_entry.get("row_index", 0))
	var column_index: int = int(formation_entry.get("column_index", 1))
	var hero_data: HeroData = _hero_data_for_id(hero_id)
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
	hero_unit.formation_slot_index = slot_index
	hero_unit.formation_row_index = row_index
	hero_unit.formation_column_index = column_index
	hero_unit.global_position = _hero_spawn_position(slot_index)
	hero_units.append(hero_unit)
	hero_units_by_id[hero_id] = hero_unit
	hero_respawn_timers[str(hero_id)] = 0.0

	if loot_manager != null:
		hero_unit.apply_stat_bonus(loot_manager.get_total_stat_bonus_for_hero(hero_unit.unit_id))


func _spawn_enemy() -> void:
	_spawn_normal_enemy_pack()


func _spawn_boss() -> void:
	var boss_data: EnemyData = _current_boss_enemy_data()
	if boss_data == null:
		_report_battle_data_error("Missing boss data for stage %s" % battle_state.current_stage_id)
		return
	_spawn_enemy_from_data(boss_data, true)
	battle_state.boss_spawned = true
	_emit_event("Boss appeared: %s" % boss_data.display_name)


func _spawn_enemy_from_data(data: EnemyData, is_boss: bool) -> void:
	if data == null:
		return
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
	enemy_data_by_instance_id[enemy.get_instance_id()] = data


func _tick_respawns(delta: float) -> void:
	for index in range(enemy_respawn_queue.size() - 1, -1, -1):
		var queue_entry: Dictionary = enemy_respawn_queue[index]
		var timer_value: float = maxf(float(queue_entry.get("timer", 0.0)) - delta, 0.0)
		queue_entry["timer"] = timer_value
		enemy_respawn_queue[index] = queue_entry
		if timer_value <= 0.0:
			enemy_respawn_queue.remove_at(index)
			if not battle_state.boss_spawned:
				var enemy_id: StringName = StringName(queue_entry.get("enemy_id", &""))
				var enemy_data: EnemyData = _enemy_data_for_id(enemy_id)
				if enemy_data != null:
					_spawn_enemy_from_data(enemy_data, false)

	for hero_index in range(hero_units.size()):
		var hero_unit: BattleUnit = hero_units[hero_index]
		if not is_instance_valid(hero_unit):
			continue
		var timer_key: String = str(hero_unit.unit_id)
		var timer_value: float = float(hero_respawn_timers.get(timer_key, 0.0))
		if timer_value <= 0.0:
			continue
		timer_value = maxf(timer_value - delta, 0.0)
		hero_respawn_timers[timer_key] = timer_value
		if is_zero_approx(timer_value):
			hero_unit.revive()
			hero_unit.set_state_text("Revived")


func _process_heroes(delta: float) -> void:
	for hero_unit in hero_units:
		if not is_instance_valid(hero_unit):
			continue
		if not hero_unit.is_alive():
			continue

		var enemy: BattleUnit = _get_closest_alive_enemy(hero_unit.global_position)
		if enemy == null:
			hero_unit.play_idle_animation()
			hero_unit.set_state_text("Waiting")
			continue

		hero_unit.tick_cooldown(delta)
		var distance: float = hero_unit.global_position.distance_to(enemy.global_position)

		if distance > hero_unit.attack_range:
			_move_towards(hero_unit, enemy.global_position, delta)
			hero_unit.play_move_animation()
			hero_unit.set_state_text("Advancing")
		elif hero_unit.can_attack():
			enemy.take_damage(hero_unit.attack)
			hero_unit.reset_attack_cooldown()
			hero_unit.play_attack_animation()
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
		var hero_target: BattleUnit = _get_priority_target_hero(enemy)
		if hero_target == null:
			enemy.play_idle_animation()
			enemy.set_state_text("Waiting")
			continue

		enemy.tick_cooldown(delta)
		var distance: float = enemy.global_position.distance_to(hero_target.global_position)

		if distance > enemy.attack_range:
			_move_towards(enemy, hero_target.global_position, delta)
			enemy.play_move_animation()
			enemy.set_state_text(_enemy_target_state_text(enemy, hero_target, "Chase"))
		elif enemy.can_attack():
			hero_target.take_damage(enemy.attack)
			enemy.reset_attack_cooldown()
			enemy.play_attack_animation()
			enemy.set_state_text(_enemy_target_state_text(enemy, hero_target, "Hit %d" % enemy.attack))

			if not hero_target.is_alive():
				hero_respawn_timers[str(hero_target.unit_id)] = HERO_RESPAWN_DELAY
				hero_target.set_state_text("Respawn %ds" % int(HERO_RESPAWN_DELAY))
				if _are_all_heroes_defeated():
					_handle_party_wipe()
					return


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


func _get_priority_target_hero(enemy: BattleUnit) -> BattleUnit:
	var target_rule: StringName = _enemy_target_rule(enemy)
	if target_rule == TARGET_RULE_LOWEST_HP:
		return _get_lowest_hp_alive_hero(enemy.global_position)
	if target_rule == TARGET_RULE_BACK_ROW_FIRST:
		return _get_priority_target_hero_by_rows(enemy.global_position, [2, 1, 0])
	return _get_priority_target_hero_by_rows(enemy.global_position, [0, 1, 2])


func _get_priority_target_hero_by_rows(source_position: Vector2, row_priority: Array[int]) -> BattleUnit:
	for target_row in row_priority:
		var closest_hero: BattleUnit
		var closest_distance: float = INF
		for hero_unit in hero_units:
			if not is_instance_valid(hero_unit) or not hero_unit.is_alive():
				continue
			if hero_unit.formation_row_index != target_row:
				continue
			var distance: float = source_position.distance_to(hero_unit.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_hero = hero_unit
		if closest_hero != null:
			return closest_hero
	return null


func _get_lowest_hp_alive_hero(source_position: Vector2) -> BattleUnit:
	var lowest_hp_hero: BattleUnit
	var lowest_hp_value: float = INF
	var closest_distance: float = INF
	for hero_unit in hero_units:
		if not is_instance_valid(hero_unit) or not hero_unit.is_alive():
			continue
		var hero_hp: float = hero_unit.current_hp
		var distance: float = source_position.distance_to(hero_unit.global_position)
		if hero_hp < lowest_hp_value:
			lowest_hp_value = hero_hp
			closest_distance = distance
			lowest_hp_hero = hero_unit
			continue
		if is_equal_approx(hero_hp, lowest_hp_value) and distance < closest_distance:
			closest_distance = distance
			lowest_hp_hero = hero_unit
	return lowest_hp_hero


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
	var status_text: String = "%s  |  Kills %d/%d  |  %s  |  Party %d/%d  |  HP %s  |  Foes %d" % [_current_stage_title(), battle_state.kill_count, battle_state.kill_target, boss_text, alive_hero_count, hero_units.size(), hero_hp_text, alive_enemy_count]
	battle_status_changed.emit(status_text)


func _handle_enemy_defeated(enemy: BattleUnit) -> void:
	if loot_manager != null:
		loot_manager.roll_loot_for_enemy(enemy.unit_id, enemy.global_position + Vector2(0.0, -18.0))
	if progression_manager != null:
		var reward: Dictionary = _reward_for_enemy(enemy.unit_id)
		progression_manager.grant_rewards(reward["exp"], reward["coin"])

	var enemy_data: EnemyData = _enemy_data_for_unit(enemy)
	enemy_data_by_instance_id.erase(enemy.get_instance_id())
	if enemy_data != null and enemy_data.is_boss:
		battle_state.boss_defeated = true
		_complete_stage()
		return

	battle_state.kill_count += 1
	_emit_event("Kill %d/%d" % [battle_state.kill_count, battle_state.kill_target])

	if battle_state.kill_count >= battle_state.kill_target and not battle_state.boss_spawned:
		_spawn_boss()
	else:
		_queue_enemy_respawn(enemy_data)


func _complete_stage() -> void:
	var completed_stage: StageData = _current_stage_data()
	var completed_stage_title: String = _stage_title_from_data(completed_stage)
	var reward_profile: RewardProfileData = _current_reward_profile()
	if progression_manager != null and reward_profile != null:
		progression_manager.grant_rewards(reward_profile.clear_reward_exp, reward_profile.clear_reward_coin)

	var next_stage_id: StringName = _next_stage_id(completed_stage)
	battle_state.current_stage_id = next_stage_id
	battle_state.kill_count = 0
	battle_state.boss_spawned = false
	battle_state.boss_defeated = false
	enemy_respawn_queue.clear()
	_apply_stage_data()
	_reset_party_positions_and_state()
	_clear_enemies()
	_emit_event("%s cleared. %s begins" % [completed_stage_title, _current_stage_title()])
	_spawn_enemy()


func _boss_hp_bonus(is_boss: bool) -> int:
	if not is_boss:
		return 0
	var spawn_profile: SpawnProfileData = _current_spawn_profile()
	if spawn_profile == null:
		return 0
	return (current_stage_number - 1) * spawn_profile.boss_hp_bonus_per_stage


func _boss_attack_bonus(is_boss: bool) -> int:
	if not is_boss:
		return 0
	var spawn_profile: SpawnProfileData = _current_spawn_profile()
	if spawn_profile == null:
		return 0
	return (current_stage_number - 1) * spawn_profile.boss_attack_bonus_per_stage


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


func _apply_equipment_to_heroes(_hero_bonus_by_id: Dictionary, _hero_summary_by_id: Dictionary) -> void:
	for hero_unit in hero_units:
		if is_instance_valid(hero_unit):
			hero_unit.apply_stat_bonus(loot_manager.get_total_stat_bonus_for_hero(hero_unit.unit_id))


func _reward_for_enemy(enemy_id: StringName) -> Dictionary:
	var enemy_data: EnemyData = _enemy_data_for_id(enemy_id)
	var reward_profile: RewardProfileData = _current_reward_profile()
	var exp_multiplier: float = reward_profile.enemy_exp_multiplier if reward_profile != null else 1.0
	var coin_multiplier: float = reward_profile.enemy_coin_multiplier if reward_profile != null else 1.0
	if enemy_data != null:
		return {
			"exp": maxi(int(round(enemy_data.reward_exp * exp_multiplier)), 0),
			"coin": maxi(int(round(enemy_data.reward_coin * coin_multiplier)), 0),
		}
	return {
		"exp": 0,
		"coin": 0,
	}


func export_state() -> Dictionary:
	return {
		"current_stage_id": str(battle_state.current_stage_id),
		"current_stage_number": current_stage_number,
		"kill_count": battle_state.kill_count,
		"kill_target": battle_state.kill_target,
		"boss_spawned": battle_state.boss_spawned,
		"boss_defeated": battle_state.boss_defeated,
	}


func apply_state(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return

	battle_state.current_stage_id = StringName(snapshot.get("current_stage_id", battle_state.current_stage_id))
	current_stage_number = int(snapshot.get("current_stage_number", 1))
	battle_state.kill_count = int(snapshot.get("kill_count", 0))
	_apply_stage_data()
	battle_state.kill_target = int(snapshot.get("kill_target", battle_state.kill_target))
	battle_state.boss_spawned = bool(snapshot.get("boss_spawned", false))
	battle_state.boss_defeated = bool(snapshot.get("boss_defeated", false))

	_clear_enemies()
	enemy_respawn_queue.clear()
	_sync_hero_party(true)

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
	enemy_data_by_instance_id.clear()


func _on_team_changed(_summary: Dictionary) -> void:
	_sync_hero_party()
	_emit_status()


func _sync_hero_party(reset_positions: bool = false) -> void:
	var active_formation: Array[Dictionary] = _get_active_formation()
	var desired_hero_ids: Array[StringName] = []
	for formation_entry in active_formation:
		var hero_id: StringName = StringName(formation_entry.get("hero_id", &""))
		desired_hero_ids.append(hero_id)
		var slot_index: int = int(formation_entry.get("slot_index", 1))
		var row_index: int = int(formation_entry.get("row_index", 0))
		var column_index: int = int(formation_entry.get("column_index", 1))
		var hero_unit: BattleUnit = hero_units_by_id.get(hero_id) as BattleUnit
		var should_reset_unit_position: bool = false
		if hero_unit == null or not is_instance_valid(hero_unit):
			_spawn_hero_for_entry(formation_entry)
			hero_unit = hero_units_by_id.get(hero_id) as BattleUnit
			should_reset_unit_position = true
		if hero_unit != null and is_instance_valid(hero_unit):
			if hero_unit.formation_slot_index != slot_index:
				should_reset_unit_position = true
			hero_unit.formation_slot_index = slot_index
			hero_unit.formation_row_index = row_index
			hero_unit.formation_column_index = column_index
			if reset_positions or should_reset_unit_position:
				hero_unit.global_position = _hero_spawn_position(hero_unit.formation_slot_index)

	var units_to_remove: Array[BattleUnit] = []
	for hero_unit in hero_units:
		if not is_instance_valid(hero_unit):
			units_to_remove.append(hero_unit)
			continue
		if not desired_hero_ids.has(hero_unit.unit_id):
			units_to_remove.append(hero_unit)

	for hero_unit in units_to_remove:
		hero_units.erase(hero_unit)
		hero_units_by_id.erase(hero_unit.unit_id)
		hero_respawn_timers.erase(str(hero_unit.unit_id))
		if is_instance_valid(hero_unit):
			hero_unit.queue_free()


func _hero_data_for_id(hero_id: StringName) -> HeroData:
	match hero_id:
		SecondHeroDataResource.id:
			return SecondHeroDataResource
		_:
			return HeroDataResource


func _spawn_normal_enemy_pack() -> void:
	var enemy_pool: Array[EnemyData] = _current_stage_enemy_pool()
	if enemy_pool.is_empty():
		_report_battle_data_error("Stage %s has no enemy pool entries" % battle_state.current_stage_id)
		return

	var spawn_profile: SpawnProfileData = _current_spawn_profile()
	if spawn_profile == null:
		_report_battle_data_error("Stage %s is missing spawn profile data" % battle_state.current_stage_id)
		return
	for pack_index in range(maxi(spawn_profile.pack_size, 1)):
		var enemy_data: EnemyData = enemy_pool[pack_index % enemy_pool.size()]
		_spawn_enemy_from_data(enemy_data, false)


func _enemy_data_for_id(enemy_id: StringName) -> EnemyData:
	if data_registry == null:
		return null
	return data_registry.get_enemy_data(enemy_id) as EnemyData


func _enemy_data_for_unit(enemy: BattleUnit) -> EnemyData:
	if enemy == null:
		return null
	return enemy_data_by_instance_id.get(enemy.get_instance_id()) as EnemyData


func _enemy_target_rule(enemy: BattleUnit) -> StringName:
	var enemy_data: EnemyData = _enemy_data_for_unit(enemy)
	if enemy_data == null:
		return TARGET_RULE_FRONT_FIRST
	return StringName(enemy_data.target_rule)


func _queue_enemy_respawn(enemy_data: EnemyData) -> void:
	if enemy_data == null or enemy_data.is_boss:
		return
	var spawn_profile: SpawnProfileData = _current_spawn_profile()
	if spawn_profile == null:
		_report_battle_data_error("Stage %s is missing spawn profile data" % battle_state.current_stage_id)
		return
	enemy_respawn_queue.append({
		"timer": maxf(spawn_profile.respawn_delay, 0.1),
		"enemy_id": enemy_data.id,
	})


func _enemy_target_state_text(enemy: BattleUnit, hero_target: BattleUnit, action_text: String) -> String:
	return "%s %s %s" % [_target_rule_label(_enemy_target_rule(enemy)), hero_target.display_name, action_text]


func _target_rule_label(target_rule: StringName) -> String:
	match target_rule:
		TARGET_RULE_LOWEST_HP:
			return "Low HP"
		TARGET_RULE_BACK_ROW_FIRST:
			return "Back"
		_:
			return "Front"


func _hero_spawn_position(slot_index: int) -> Vector2:
	if formation_positions_by_slot.has(slot_index):
		return formation_positions_by_slot[slot_index]
	return Vector2(264.0, 220.0)


func _apply_stage_data() -> void:
	var stage_data: StageData = _current_stage_data()
	if stage_data == null:
		return
	current_stage_number = maxi(stage_data.stage_number, 1)
	battle_state.kill_target = stage_data.kill_target


func _current_stage_data() -> StageData:
	if data_registry == null:
		return null
	return data_registry.get_stage_data(battle_state.current_stage_id) as StageData


func _current_spawn_profile() -> SpawnProfileData:
	var stage_data: StageData = _current_stage_data()
	if data_registry != null and stage_data != null and stage_data.spawn_profile_id != &"":
		return data_registry.get_spawn_profile_data(stage_data.spawn_profile_id) as SpawnProfileData
	return null


func _current_reward_profile() -> RewardProfileData:
	var stage_data: StageData = _current_stage_data()
	if data_registry != null and stage_data != null and stage_data.reward_profile_id != &"":
		return data_registry.get_reward_profile_data(stage_data.reward_profile_id) as RewardProfileData
	return null


func _next_stage_id(current_stage_data: StageData) -> StringName:
	if current_stage_data != null and current_stage_data.next_stage_id != &"":
		return current_stage_data.next_stage_id
	return battle_state.current_stage_id if battle_state != null else DEFAULT_STAGE_ID


func _current_stage_title() -> String:
	return _stage_title_from_data(_current_stage_data())


func _stage_title_from_data(stage_data: StageData) -> String:
	if stage_data == null:
		return "Stage %d" % current_stage_number
	if stage_data.display_name.is_empty():
		return "Stage %d" % maxi(stage_data.stage_number, 1)
	return "Stage %d %s" % [maxi(stage_data.stage_number, 1), stage_data.display_name]


func _current_stage_enemy_pool() -> Array[EnemyData]:
	var enemy_pool: Array[EnemyData] = []
	var stage_data: StageData = _current_stage_data()
	if stage_data == null:
		return enemy_pool
	for enemy_id in stage_data.enemy_pool_ids:
		var enemy_data: EnemyData = _enemy_data_for_id(StringName(enemy_id))
		if enemy_data != null:
			enemy_pool.append(enemy_data)
	return enemy_pool


func _current_boss_enemy_data() -> EnemyData:
	var stage_data: StageData = _current_stage_data()
	if stage_data == null:
		return null
	var boss_enemy_data: EnemyData = _enemy_data_for_id(stage_data.boss_enemy_id)
	return boss_enemy_data


func _validate_battle_data() -> bool:
	if data_registry == null:
		_report_battle_data_error("BattleManager requires AppRoot/DataRegistry")
		return false

	var stage_data: StageData = _current_stage_data()
	if stage_data == null:
		_report_battle_data_error("Missing stage data for %s" % battle_state.current_stage_id)
		return false
	if _current_stage_enemy_pool().is_empty():
		_report_battle_data_error("Stage %s has no valid enemy data in DataRegistry" % battle_state.current_stage_id)
		return false
	if _current_boss_enemy_data() == null:
		_report_battle_data_error("Stage %s boss enemy is missing from DataRegistry" % battle_state.current_stage_id)
		return false
	if _current_spawn_profile() == null:
		_report_battle_data_error("Stage %s spawn profile is missing from DataRegistry" % battle_state.current_stage_id)
		return false
	if _current_reward_profile() == null:
		_report_battle_data_error("Stage %s reward profile is missing from DataRegistry" % battle_state.current_stage_id)
		return false

	return true


func _report_battle_data_error(message: String) -> void:
	push_error(message)
	_emit_event(message)


func _get_active_formation() -> Array[Dictionary]:
	if team_manager != null and team_manager.has_method("get_active_formation"):
		return team_manager.get_active_formation()

	return [
		{
			"hero_id": HeroDataResource.id,
			"slot_index": 1,
			"row_index": 0,
			"column_index": 1,
		},
	]


func _are_all_heroes_defeated() -> bool:
	var has_hero: bool = false
	for hero_unit in hero_units:
		if not is_instance_valid(hero_unit):
			continue
		has_hero = true
		if hero_unit.is_alive():
			return false
	return has_hero


func _handle_party_wipe() -> void:
	enemy_respawn_queue.clear()
	_clear_enemies()
	_reset_party_positions_and_state()
	if battle_state.boss_spawned and not battle_state.boss_defeated:
		_spawn_boss()
	else:
		_spawn_enemy()
	_emit_event("Party wiped. Formation reset")


func _reset_party_positions_and_state() -> void:
	for hero_unit in hero_units:
		if not is_instance_valid(hero_unit):
			continue
		hero_respawn_timers[str(hero_unit.unit_id)] = 0.0
		hero_unit.revive()
		hero_unit.global_position = _hero_spawn_position(hero_unit.formation_slot_index)
