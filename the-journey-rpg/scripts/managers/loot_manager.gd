extends Node

class_name LootManager

const RustySwordData := preload("res://resources/items/rusty_sword.tres")
const GreenRingData := preload("res://resources/items/green_ring.tres")

signal loot_dropped(item_data: ItemData, world_position: Vector2)
signal inventory_changed(inventory_text: String)

var collected_item_ids: Array[StringName] = []
var recent_item_names: Array[String] = []


func roll_loot_for_enemy(enemy_id: StringName, world_position: Vector2) -> void:
	var item := _roll_item(enemy_id)
	if item == null:
		return

	loot_dropped.emit(item, world_position)


func register_pickup(item_data: ItemData) -> void:
	collected_item_ids.append(item_data.id)
	recent_item_names.push_front(item_data.display_name)
	if recent_item_names.size() > 6:
		recent_item_names.resize(6)

	inventory_changed.emit(_build_inventory_text())


func _roll_item(enemy_id: StringName) -> ItemData:
	if enemy_id == &"enemy_slime_king":
		return _roll_weighted_item()

	if randf() <= 0.45:
		return _roll_weighted_item()

	return null


func _roll_weighted_item() -> ItemData:
	var total_weight := RustySwordData.drop_weight + GreenRingData.drop_weight
	var roll := randi_range(1, total_weight)

	if roll <= RustySwordData.drop_weight:
		return RustySwordData

	return GreenRingData


func _build_inventory_text() -> String:
	if recent_item_names.is_empty():
		return "Inventory items will appear here while\nbattle remains visible."

	var lines: PackedStringArray = ["Recent loot:"]
	for item_name in recent_item_names:
		lines.append("- %s" % item_name)
	return "\n".join(lines)
