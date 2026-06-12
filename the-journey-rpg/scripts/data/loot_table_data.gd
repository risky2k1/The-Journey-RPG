extends Resource

class_name LootTableData

@export var id: StringName
@export var display_name: String = ""
@export_range(0.0, 1.0, 0.001) var drop_chance: float = 0.01
@export var rolls: int = 1
@export var entries: Array[Dictionary] = []
