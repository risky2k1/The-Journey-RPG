extends Resource

class_name HeroData

@export var id: StringName
@export var display_name: String = ""
@export var class_id: StringName
@export var base_hp: int = 100
@export var base_attack: int = 10
@export var base_attack_speed: float = 1.0
@export var base_move_speed: float = 80.0
@export var attack_range: float = 48.0
@export var starting_skill_ids: Array[StringName] = []
@export var sprite_id: StringName
@export var portrait_id: StringName
