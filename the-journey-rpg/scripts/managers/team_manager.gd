extends Node

class_name TeamManager

const TeamStateScript := preload("res://scripts/state/team_state.gd")

const HERO_ADVENTURER := &"hero_adventurer"
const HERO_APPRENTICE := &"hero_apprentice"
const HERO_ROSTER: Array[StringName] = [
	HERO_ADVENTURER,
	HERO_APPRENTICE,
]

signal team_changed(summary: Dictionary)

var state: TeamState
var progression_manager: ProgressionManager


func _ready() -> void:
	state = TeamStateScript.new()
	progression_manager = get_parent().get_node_or_null("ProgressionManager")
	if progression_manager != null and progression_manager.has_signal("progression_changed"):
		progression_manager.progression_changed.connect(_on_progression_changed)
	if progression_manager != null and progression_manager.has_method("get_summary"):
		_on_progression_changed(progression_manager.get_summary())
	else:
		_ensure_defaults()
		_emit_changed()


func export_state() -> Dictionary:
	var assigned_slots: Dictionary = {}
	for slot_index in state.assigned_hero_ids_by_slot.keys():
		assigned_slots[str(slot_index)] = str(state.assigned_hero_ids_by_slot[slot_index])

	var active_slots: Array[int] = []
	for slot_index in state.active_slot_indices:
		active_slots.append(slot_index)

	return {
		"unlocked_slot_count": state.unlocked_slot_count,
		"assigned_hero_ids_by_slot": assigned_slots,
		"active_slot_indices": active_slots,
	}


func apply_state(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		_ensure_defaults()
		_emit_changed()
		return

	state.unlocked_slot_count = int(snapshot.get("unlocked_slot_count", state.unlocked_slot_count))
	state.assigned_hero_ids_by_slot.clear()
	state.active_slot_indices.clear()

	var assigned_slots: Dictionary = snapshot.get("assigned_hero_ids_by_slot", {})
	for slot_key in assigned_slots.keys():
		var slot_index: int = int(slot_key)
		var hero_id: StringName = StringName(assigned_slots[slot_key])
		if _is_valid_slot_index(slot_index) and HERO_ROSTER.has(hero_id):
			state.assigned_hero_ids_by_slot[slot_index] = hero_id

	var active_slots: Array = snapshot.get("active_slot_indices", [])
	for slot_value in active_slots:
		var slot_index: int = int(slot_value)
		if _is_valid_slot_index(slot_index):
			state.active_slot_indices.append(slot_index)

	_ensure_defaults()
	_emit_changed()


func get_summary() -> Dictionary:
	var available_hero_ids: Array[StringName] = get_available_hero_ids()
	var slots: Array[Dictionary] = []
	for slot_index in range(9):
		var hero_id: StringName = StringName(state.assigned_hero_ids_by_slot.get(slot_index, &""))
		var is_unlocked: bool = _is_slot_unlocked(slot_index)
		slots.append({
			"slot_index": slot_index,
			"row_index": _row_for_slot(slot_index),
			"column_index": _column_for_slot(slot_index),
			"row_label": _row_name(_row_for_slot(slot_index)),
			"column_label": _column_name(_column_for_slot(slot_index)),
			"unlocked": is_unlocked,
			"hero_id": hero_id,
			"hero_name": _hero_name(hero_id),
			"button_text": _slot_button_text(slot_index, hero_id, is_unlocked),
		})

	var hero_entries: Array[Dictionary] = []
	for hero_id in HERO_ROSTER:
		var is_available: bool = available_hero_ids.has(hero_id)
		hero_entries.append({
			"hero_id": hero_id,
			"hero_name": _hero_name(hero_id),
			"available": is_available,
			"assigned_slot_index": _slot_for_hero(hero_id),
		})

	var active_lines: PackedStringArray = []
	for hero_id in available_hero_ids:
		var slot_index: int = _slot_for_hero(hero_id)
		if slot_index >= 0:
			active_lines.append("%s: %s %s" % [_hero_name(hero_id), _row_name(_row_for_slot(slot_index)), _column_name(_column_for_slot(slot_index))])
		else:
			active_lines.append("%s: Unassigned" % _hero_name(hero_id))

	var body_text: String = "Formation Rules\nEnemies hit Front row first, then Middle, then Back.\nThis establishes the default targeting rule for future enemy AI.\n\nActive Heroes\n%s" % [
		"\n".join(active_lines) if not active_lines.is_empty() else "No active heroes",
	]

	return {
		"unlocked_slot_count": state.unlocked_slot_count,
		"available_heroes": hero_entries,
		"slots": slots,
		"body_text": body_text,
	}


func get_active_formation() -> Array[Dictionary]:
	var formation: Array[Dictionary] = []
	for hero_id in get_available_hero_ids():
		var slot_index: int = _slot_for_hero(hero_id)
		if slot_index < 0 or not _is_slot_unlocked(slot_index):
			continue
		formation.append({
			"hero_id": hero_id,
			"slot_index": slot_index,
			"row_index": _row_for_slot(slot_index),
			"column_index": _column_for_slot(slot_index),
		})
	return formation


func assign_hero_to_slot(hero_id: StringName, slot_index: int) -> void:
	if not HERO_ROSTER.has(hero_id):
		return
	if not get_available_hero_ids().has(hero_id):
		return
	if not _is_slot_unlocked(slot_index):
		return

	var previous_slot: int = _slot_for_hero(hero_id)
	if previous_slot >= 0:
		state.assigned_hero_ids_by_slot.erase(previous_slot)

	var replaced_hero_id: StringName = StringName(state.assigned_hero_ids_by_slot.get(slot_index, &""))
	state.assigned_hero_ids_by_slot[slot_index] = hero_id

	if replaced_hero_id != &"" and replaced_hero_id != hero_id and previous_slot >= 0:
		state.assigned_hero_ids_by_slot[previous_slot] = replaced_hero_id

	_rebuild_active_slots()
	_emit_changed()


func clear_slot(slot_index: int) -> void:
	if not _is_slot_unlocked(slot_index):
		return
	if not state.assigned_hero_ids_by_slot.has(slot_index):
		return

	state.assigned_hero_ids_by_slot.erase(slot_index)
	_ensure_defaults()
	_emit_changed()


func get_available_hero_ids() -> Array[StringName]:
	var available_count: int = mini(state.unlocked_slot_count, HERO_ROSTER.size())
	var hero_ids: Array[StringName] = []
	for hero_index in range(available_count):
		hero_ids.append(HERO_ROSTER[hero_index])
	return hero_ids


func _on_progression_changed(summary: Dictionary) -> void:
	state.unlocked_slot_count = int(summary.get("unlocked_team_slot_count", 1))
	_ensure_defaults()
	_emit_changed()


func _ensure_defaults() -> void:
	var available_hero_ids: Array[StringName] = get_available_hero_ids()
	var keys_to_remove: Array[int] = []
	for slot_index in state.assigned_hero_ids_by_slot.keys():
		var hero_id: StringName = StringName(state.assigned_hero_ids_by_slot[slot_index])
		if not _is_slot_unlocked(int(slot_index)) or not available_hero_ids.has(hero_id):
			keys_to_remove.append(int(slot_index))
	for slot_index in keys_to_remove:
		state.assigned_hero_ids_by_slot.erase(slot_index)

	var default_slots: Array[int] = [1, 4]
	for hero_index in range(available_hero_ids.size()):
		var hero_id: StringName = available_hero_ids[hero_index]
		if _slot_for_hero(hero_id) >= 0:
			continue
		var default_slot: int = default_slots[mini(hero_index, default_slots.size() - 1)]
		if not state.assigned_hero_ids_by_slot.has(default_slot):
			state.assigned_hero_ids_by_slot[default_slot] = hero_id
			continue
		for slot_index in range(9):
			if _is_slot_unlocked(slot_index) and not state.assigned_hero_ids_by_slot.has(slot_index):
				state.assigned_hero_ids_by_slot[slot_index] = hero_id
				break

	_rebuild_active_slots()


func _rebuild_active_slots() -> void:
	state.active_slot_indices.clear()
	for slot_index in state.assigned_hero_ids_by_slot.keys():
		var typed_slot_index: int = int(slot_index)
		if _is_slot_unlocked(typed_slot_index):
			state.active_slot_indices.append(typed_slot_index)
	state.active_slot_indices.sort()


func _slot_for_hero(hero_id: StringName) -> int:
	for slot_index in state.assigned_hero_ids_by_slot.keys():
		if StringName(state.assigned_hero_ids_by_slot[slot_index]) == hero_id:
			return int(slot_index)
	return -1


func _is_slot_unlocked(slot_index: int) -> bool:
	if not _is_valid_slot_index(slot_index):
		return false
	return _row_for_slot(slot_index) < state.unlocked_slot_count


func _is_valid_slot_index(slot_index: int) -> bool:
	return slot_index >= 0 and slot_index < 9


func _row_for_slot(slot_index: int) -> int:
	return slot_index / 3


func _column_for_slot(slot_index: int) -> int:
	return slot_index % 3


func _row_name(row_index: int) -> String:
	match row_index:
		0:
			return "Front"
		1:
			return "Middle"
		_:
			return "Back"


func _column_name(column_index: int) -> String:
	match column_index:
		0:
			return "Top"
		1:
			return "Center"
		_:
			return "Bottom"


func _slot_button_text(slot_index: int, hero_id: StringName, is_unlocked: bool) -> String:
	var slot_label: String = "%s\n%s" % [_row_name(_row_for_slot(slot_index)).left(1), _column_name(_column_for_slot(slot_index)).left(1)]
	if not is_unlocked:
		return "%s\nLocked" % slot_label
	if hero_id == &"":
		return "%s\nEmpty" % slot_label
	return "%s\n%s" % [slot_label, _hero_name(hero_id)]


func _hero_name(hero_id: StringName) -> String:
	match hero_id:
		HERO_ADVENTURER:
			return "Adventurer"
		HERO_APPRENTICE:
			return "Apprentice"
		_:
			return "None"


func _emit_changed() -> void:
	team_changed.emit(get_summary())
