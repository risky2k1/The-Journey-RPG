extends Resource

class_name TeamSlotData

@export var id: StringName
@export var slot_index: int = 0
@export var unlock_requirement_type: StringName = &"level"
@export var unlock_requirement_value: int = 1
@export var preferred_role: StringName = &"any"
