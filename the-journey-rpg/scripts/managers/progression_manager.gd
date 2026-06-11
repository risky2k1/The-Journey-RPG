extends Node

class_name ProgressionManager

const ProgressionStateScript := preload("res://scripts/state/progression_state.gd")

signal progression_changed(summary: Dictionary)
signal progression_event(event_text: String)

var state: ProgressionState


func _ready() -> void:
	state = ProgressionStateScript.new()
	_emit_progression_changed()


func grant_rewards(exp_amount: int, coin_amount: int) -> void:
	var old_level: int = state.profile_level
	var old_slot_count: int = state.unlocked_team_slot_count

	state.current_exp += exp_amount
	state.currency += coin_amount

	while state.current_exp >= state.exp_to_next:
		state.current_exp -= state.exp_to_next
		state.profile_level += 1
		state.exp_to_next = _exp_requirement_for_level(state.profile_level)

	state.unlocked_team_slot_count = _slot_count_for_level(state.profile_level)

	if state.profile_level > old_level:
		progression_event.emit("Level up! Reached Lv %d" % state.profile_level)
	elif state.unlocked_team_slot_count > old_slot_count:
		progression_event.emit("New team slot unlocked")

	_emit_progression_changed()


func get_summary() -> Dictionary:
	return _build_summary()


func export_state() -> Dictionary:
	return {
		"profile_level": state.profile_level,
		"current_exp": state.current_exp,
		"exp_to_next": state.exp_to_next,
		"currency": state.currency,
		"unlocked_team_slot_count": state.unlocked_team_slot_count,
	}


func apply_state(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return

	state.profile_level = int(snapshot.get("profile_level", 1))
	state.current_exp = int(snapshot.get("current_exp", 0))
	state.exp_to_next = int(snapshot.get("exp_to_next", _exp_requirement_for_level(state.profile_level)))
	state.currency = int(snapshot.get("currency", 0))
	state.unlocked_team_slot_count = int(snapshot.get("unlocked_team_slot_count", _slot_count_for_level(state.profile_level)))
	_emit_progression_changed()


func _exp_requirement_for_level(level: int) -> int:
	return 10 + ((level - 1) * 6)


func _slot_count_for_level(level: int) -> int:
	if level >= 4:
		return 3
	if level >= 2:
		return 2
	return 1


func _build_summary() -> Dictionary:
	var slot_2_text: String = "Unlocked - Second hero prototype active" if state.unlocked_team_slot_count >= 2 else "Locked (Lv 2)"
	var slot_3_text: String = "Unlocked - Reserved for future party expansion" if state.unlocked_team_slot_count >= 3 else "Locked (Lv 4)"
	return {
		"profile_level": state.profile_level,
		"current_exp": state.current_exp,
		"exp_to_next": state.exp_to_next,
		"currency": state.currency,
		"unlocked_team_slot_count": state.unlocked_team_slot_count,
		"character_progress_text": "Level: %d\nEXP: %d/%d\nCoin: %d" % [
			state.profile_level,
			state.current_exp,
			state.exp_to_next,
			state.currency,
		],
		"team_progress_text": "Slot 1: Adventurer active\nSlot 2: %s\nSlot 3: %s" % [slot_2_text, slot_3_text],
	}


func _emit_progression_changed() -> void:
	progression_changed.emit(_build_summary())
