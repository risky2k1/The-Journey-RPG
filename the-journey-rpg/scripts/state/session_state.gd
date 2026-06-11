extends RefCounted

class_name SessionState

const BattleStateScript := preload("res://scripts/state/battle_state.gd")
const InventoryStateScript := preload("res://scripts/state/inventory_state.gd")
const ProgressionStateScript := preload("res://scripts/state/progression_state.gd")
const TeamStateScript := preload("res://scripts/state/team_state.gd")

var battle_state: BattleState
var inventory_state: InventoryState
var progression_state: ProgressionState
var team_state: TeamState


func bootstrap_defaults() -> void:
	battle_state = BattleStateScript.new()
	inventory_state = InventoryStateScript.new()
	progression_state = ProgressionStateScript.new()
	team_state = TeamStateScript.new()
