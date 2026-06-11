extends Node2D

class_name LootDrop

signal pickup_requested(item_data: ItemData)

@onready var shadow: Polygon2D = $Shadow
@onready var beam: ColorRect = $Beam
@onready var ring: Polygon2D = $Ring
@onready var outer: Polygon2D = $Outer
@onready var inner: Polygon2D = $Inner
@onready var item_label: Label = $ItemLabel

var item_data: ItemData
var pickup_delay: float = 1.4
var lifetime: float = 0.0
var base_position: Vector2


func configure(data: ItemData) -> void:
	item_data = data
	item_label.text = data.display_name
	base_position = position

	var rarity_color: Color = _color_for_rarity(data.rarity)
	outer.color = rarity_color
	ring.color = Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.22)
	beam.color = Color(rarity_color.r, rarity_color.g, rarity_color.b, 0.45)
	inner.color = Color(0.11, 0.12, 0.14, 1.0)
	item_label.modulate = Color(1.0, 0.98, 0.94, 1.0)


func _process(delta: float) -> void:
	lifetime += delta
	pickup_delay -= delta
	position.y = base_position.y + sin(lifetime * 4.0) * 2.5
	outer.rotation = lifetime * 0.55
	inner.rotation = -lifetime * 0.8
	ring.scale = Vector2.ONE * (1.0 + (sin(lifetime * 3.0) * 0.04))
	beam.modulate.a = 0.7 + (sin(lifetime * 2.6) * 0.12)
	shadow.scale.x = 0.92 + (sin(lifetime * 4.0) * 0.04)

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
