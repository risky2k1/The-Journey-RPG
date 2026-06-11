extends Node2D

class_name LootDrop

signal pickup_requested(item_data: ItemData)

@onready var beam: ColorRect = $Beam
@onready var outer: ColorRect = $Outer
@onready var item_label: Label = $ItemLabel

var item_data: ItemData
var pickup_delay: float = 1.4
var lifetime: float = 0.0
var base_position: Vector2


func configure(data: ItemData) -> void:
	item_data = data
	item_label.text = data.display_name
	base_position = position

	var rarity_color := _color_for_rarity(data.rarity)
	outer.color = rarity_color
	beam.color = Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.45)


func _process(delta: float) -> void:
	lifetime += delta
	pickup_delay -= delta
	position.y = base_position.y + sin(lifetime * 4.0) * 2.5

	if pickup_delay <= 0.0:
		pickup_requested.emit(item_data)
		queue_free()


func _color_for_rarity(rarity: StringName) -> Color:
	match rarity:
		&"uncommon":
			return Color(0.35, 0.95, 0.45, 1.0)
		&"rare":
			return Color(0.3, 0.55, 1.0, 1.0)
		_:
			return Color(0.85, 0.85, 0.85, 1.0)
