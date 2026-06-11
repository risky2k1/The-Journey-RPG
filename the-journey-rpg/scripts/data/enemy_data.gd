extends Resource

class_name EnemyData

@export var id: StringName
@export var display_name: String = ""
@export var enemy_type: StringName
@export var base_hp: int = 40
@export var base_attack: int = 4
@export var base_attack_speed: float = 0.9
@export var base_move_speed: float = 72.0
@export var attack_range: float = 36.0
@export var reward_exp: int = 2
@export var reward_coin: int = 1
@export var loot_table_id: StringName
@export var sprite_id: StringName
@export var is_boss: bool = false
