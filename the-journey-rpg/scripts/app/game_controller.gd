extends Node

class_name GameController

const SessionStateScript := preload("res://scripts/state/session_state.gd")

var session_state: SessionState
var save_manager: SaveManager
var loot_manager: LootManager
var progression_manager: ProgressionManager
var battle_manager: BattleManager
var window_behavior_manager: WindowBehaviorManager


func _ready() -> void:
	session_state = SessionStateScript.new()
	session_state.bootstrap_defaults()
	call_deferred("_bootstrap_runtime")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_persist_snapshot()


func _exit_tree() -> void:
	_persist_snapshot()


func _bootstrap_runtime() -> void:
	save_manager = get_parent().get_node_or_null("SaveManager")
	loot_manager = get_parent().get_node_or_null("LootManager")
	progression_manager = get_parent().get_node_or_null("ProgressionManager")
	battle_manager = get_parent().get_parent().get_node_or_null("WindowRoot/BattleRoot")
	window_behavior_manager = get_parent().get_node_or_null("WindowBehaviorManager")

	if save_manager != null:
		save_manager.save_requested.connect(_persist_snapshot)

	if loot_manager != null:
		loot_manager.inventory_changed.connect(_on_runtime_changed)
		loot_manager.equipment_changed.connect(_on_runtime_changed)
	if progression_manager != null:
		progression_manager.progression_changed.connect(_on_runtime_changed)
	if battle_manager != null:
		battle_manager.battle_event_changed.connect(_on_runtime_changed)
	if window_behavior_manager != null:
		window_behavior_manager.window_state_changed.connect(_on_runtime_changed)

	if save_manager != null and save_manager.has_save():
		var snapshot: Dictionary = save_manager.load_snapshot()
		_apply_snapshot(snapshot)


func _apply_snapshot(snapshot: Dictionary) -> void:
	if progression_manager != null:
		progression_manager.apply_state(snapshot.get("progression", {}))
	if loot_manager != null:
		loot_manager.apply_state(snapshot.get("loot", {}))
	if battle_manager != null:
		battle_manager.apply_state(snapshot.get("battle", {}))
	if window_behavior_manager != null:
		window_behavior_manager.apply_state(snapshot.get("window", {}))


func _persist_snapshot() -> void:
	if save_manager == null:
		return

	var snapshot: Dictionary = {
		"save_version": 1,
		"progression": progression_manager.export_state() if progression_manager != null else {},
		"loot": loot_manager.export_state() if loot_manager != null else {},
		"battle": battle_manager.export_state() if battle_manager != null else {},
		"window": window_behavior_manager.export_state() if window_behavior_manager != null else {},
	}
	save_manager.save_snapshot(snapshot)


func _on_runtime_changed(_arg1 = null, _arg2 = null) -> void:
	if save_manager != null:
		save_manager.mark_dirty()
