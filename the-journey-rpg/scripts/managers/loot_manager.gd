extends Node

class_name LootManager

const RustySwordData := preload("res://resources/items/rusty_sword.tres")
const GreenRingData := preload("res://resources/items/green_ring.tres")

signal loot_dropped(item_data: ItemData, world_position: Vector2)
signal inventory_changed(inventory_text: String, inventory_entries: Array)
signal equipment_changed(total_stats: Dictionary, summary_text: String)

var collected_item_ids: Array[StringName] = []
var recent_item_names: Array[String] = []
var inventory_items: Array[ItemData] = []
var equipped_by_slot: Dictionary = {}


func roll_loot_for_enemy(enemy_id: StringName, world_position: Vector2) -> void:
	var item: ItemData = _roll_item(enemy_id)
	if item == null:
		return

	loot_dropped.emit(item, world_position)


func register_pickup(item_data: ItemData) -> void:
	collected_item_ids.append(item_data.id)
	inventory_items.append(item_data)
	recent_item_names.push_front(item_data.display_name)
	if recent_item_names.size() > 6:
		recent_item_names.resize(6)

	_emit_inventory_changed()


func equip_item_at(index: int) -> void:
	if index < 0 or index >= inventory_items.size():
		return

	var item_data: ItemData = inventory_items[index]
	equipped_by_slot[item_data.slot_type] = item_data
	_emit_inventory_changed()
	equipment_changed.emit(_build_total_stat_bonus(), _build_character_summary())


func _roll_item(enemy_id: StringName) -> ItemData:
	if enemy_id == &"enemy_slime_king":
		return _roll_weighted_item()

	if randf() <= 0.45:
		return _roll_weighted_item()

	return null


func _roll_weighted_item() -> ItemData:
	var total_weight: int = RustySwordData.drop_weight + GreenRingData.drop_weight
	var roll: int = randi_range(1, total_weight)

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


func _build_inventory_entries() -> Array:
	var entries: Array = []
	for index in range(inventory_items.size()):
		var item_data: ItemData = inventory_items[index]
		var equipped: bool = equipped_by_slot.get(item_data.slot_type) == item_data
		entries.append({
			"index": index,
			"label": "%s%s [%s]" % ["[E] " if equipped else "", item_data.display_name, String(item_data.rarity)],
			"rarity": item_data.rarity,
			"equipped": equipped,
		})
	return entries


func _build_total_stat_bonus() -> Dictionary:
	var total: Dictionary = {
		"hp": 0,
		"attack": 0,
	}

	for item_data in equipped_by_slot.values():
		if item_data == null:
			continue
		total["hp"] += int(item_data.stat_profile.get("hp", 0))
		total["attack"] += int(item_data.stat_profile.get("attack", 0))

	return total


func _build_character_summary() -> String:
	var weapon_name: String = "None"
	var accessory_name: String = "None"

	if equipped_by_slot.has(&"weapon"):
		weapon_name = equipped_by_slot[&"weapon"].display_name
	if equipped_by_slot.has(&"accessory"):
		accessory_name = equipped_by_slot[&"accessory"].display_name

	var total: Dictionary = _build_total_stat_bonus()
	return "Equipped Weapon: %s\nEquipped Accessory: %s\nBonus HP: +%d\nBonus Attack: +%d" % [
		weapon_name,
		accessory_name,
		total["hp"],
		total["attack"],
	]


func _emit_inventory_changed() -> void:
	inventory_changed.emit(_build_inventory_text(), _build_inventory_entries())


func export_state() -> Dictionary:
	var inventory_ids: Array[String] = []
	for item_data in inventory_items:
		inventory_ids.append(String(item_data.id))

	var equipped_ids: Dictionary = {}
	for slot_type in equipped_by_slot.keys():
		var equipped_item: ItemData = equipped_by_slot[slot_type]
		equipped_ids[String(slot_type)] = String(equipped_item.id)

	return {
		"inventory_ids": inventory_ids,
		"equipped_ids": equipped_ids,
		"recent_item_names": recent_item_names.duplicate(),
	}


func apply_state(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return

	inventory_items.clear()
	equipped_by_slot.clear()
	recent_item_names.clear()
	collected_item_ids.clear()

	var inventory_ids: Array = snapshot.get("inventory_ids", [])
	for item_id in inventory_ids:
		var item_data: ItemData = _item_from_id(StringName(item_id))
		if item_data != null:
			inventory_items.append(item_data)
			collected_item_ids.append(item_data.id)

	var equipped_ids: Dictionary = snapshot.get("equipped_ids", {})
	for slot_type in equipped_ids.keys():
		var equipped_item_id: StringName = StringName(equipped_ids[slot_type])
		var equipped_item: ItemData = _item_from_id(equipped_item_id)
		if equipped_item != null:
			equipped_by_slot[StringName(slot_type)] = equipped_item

	var recent_names: Array = snapshot.get("recent_item_names", [])
	for item_name in recent_names:
		recent_item_names.append(String(item_name))

	_emit_inventory_changed()
	equipment_changed.emit(_build_total_stat_bonus(), _build_character_summary())


func _item_from_id(item_id: StringName) -> ItemData:
	match item_id:
		&"item_green_ring":
			return GreenRingData
		&"item_rusty_sword":
			return RustySwordData
		_:
			return null
