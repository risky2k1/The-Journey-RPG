extends Node

class_name LootManager

const RustySwordData := preload("res://resources/items/rusty_sword.tres")
const GreenRingData := preload("res://resources/items/green_ring.tres")
const WornBucklerData := preload("res://resources/items/worn_buckler.tres")
const PatchedArmorData := preload("res://resources/items/patched_armor.tres")
const LeatherGlovesData := preload("res://resources/items/leather_gloves.tres")
const TrailBootsData := preload("res://resources/items/trail_boots.tres")
const CopperCharmData := preload("res://resources/items/copper_charm.tres")
const EQUIPMENT_SLOTS: Array[StringName] = [
	&"weapon",
	&"offhand",
	&"armor",
	&"gloves",
	&"boots",
	&"necklace",
	&"ring",
]
const HERO_ADVENTURER := &"hero_adventurer"

signal loot_dropped(item_data: ItemData, world_position: Vector2)
signal inventory_changed(inventory_text: String, inventory_entries: Array)
signal equipment_changed(hero_bonus_by_id: Dictionary, hero_summary_by_id: Dictionary)

var collected_item_ids: Array[StringName] = []
var recent_item_names: Array[String] = []
var inventory_items: Array[ItemData] = []
var equipped_by_hero: Dictionary = {}


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


func equip_item_at(index: int, hero_id: StringName = HERO_ADVENTURER) -> void:
	if index < 0 or index >= inventory_items.size():
		return

	var item_data: ItemData = inventory_items[index]
	var equipped_by_slot: Dictionary = _hero_equipment(hero_id)
	equipped_by_slot[item_data.slot_type] = item_data
	_emit_inventory_changed()
	_emit_equipment_changed()


func get_total_stat_bonus_for_hero(hero_id: StringName) -> Dictionary:
	return _build_total_stat_bonus_for_hero(hero_id)


func get_character_summary(hero_id: StringName) -> String:
	return _build_character_summary(hero_id)


func _roll_item(enemy_id: StringName) -> ItemData:
	if enemy_id == &"enemy_slime_king":
		if randf() <= 0.08:
			return _roll_weighted_item()
		return null

	if randf() <= 0.01:
		return _roll_weighted_item()

	return null


func _roll_weighted_item() -> ItemData:
	var item_pool: Array[ItemData] = [
		RustySwordData,
		WornBucklerData,
		PatchedArmorData,
		LeatherGlovesData,
		TrailBootsData,
		GreenRingData,
		CopperCharmData,
	]
	var total_weight: int = 0
	for item_data in item_pool:
		total_weight += item_data.drop_weight

	var roll: int = randi_range(1, total_weight)
	var cursor: int = 0
	for item_data in item_pool:
		cursor += item_data.drop_weight
		if roll <= cursor:
			return item_data
	return RustySwordData


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
		var equipped_owner: String = _equipped_owner_name(item_data)
		entries.append({
			"index": index,
			"label": "%s [%s]%s" % [
				item_data.display_name,
				str(item_data.rarity),
				" {%s}" % equipped_owner if equipped_owner != "" else "",
			],
			"rarity": item_data.rarity,
			"equipped_owner": equipped_owner,
		})
	return entries


func _build_total_stat_bonus_for_hero(hero_id: StringName) -> Dictionary:
	var total: Dictionary = {
		"hp": 0,
		"attack": 0,
	}

	for item_data in _hero_equipment(hero_id).values():
		if item_data == null:
			continue
		total["hp"] += int(item_data.stat_profile.get("hp", 0))
		total["attack"] += int(item_data.stat_profile.get("attack", 0))

	return total


func _build_character_summary(hero_id: StringName) -> String:
	var equipped_by_slot: Dictionary = _hero_equipment(hero_id)
	var lines: PackedStringArray = []
	lines.append("Hero: %s" % _hero_name(hero_id))
	lines.append("")
	lines.append("Equipment")
	for slot_type in EQUIPMENT_SLOTS:
		var item_name: String = "Empty"
		if equipped_by_slot.has(slot_type):
			var item_data: ItemData = equipped_by_slot[slot_type]
			if item_data != null:
				item_name = item_data.display_name
		lines.append("- %s: %s" % [_slot_label(slot_type), item_name])

	var total: Dictionary = _build_total_stat_bonus_for_hero(hero_id)
	lines.append("")
	lines.append("Bonus HP: +%d" % int(total.get("hp", 0)))
	lines.append("Bonus Attack: +%d" % int(total.get("attack", 0)))
	return "\n".join(lines)


func _hero_equipment(hero_id: StringName) -> Dictionary:
	if not equipped_by_hero.has(hero_id):
		equipped_by_hero[hero_id] = {}
	return equipped_by_hero[hero_id]


func _equipped_owner_name(item_data: ItemData) -> String:
	for hero_id in equipped_by_hero.keys():
		var equipped_by_slot: Dictionary = equipped_by_hero[hero_id]
		if equipped_by_slot.get(item_data.slot_type) == item_data:
			return _hero_name(StringName(hero_id))
	return ""


func _hero_name(hero_id: StringName) -> String:
	match hero_id:
		&"hero_apprentice":
			return "Apprentice"
		_:
			return "Adventurer"


func _slot_label(slot_type: StringName) -> String:
	match slot_type:
		&"offhand":
			return "Offhand"
		&"armor":
			return "Armor"
		&"gloves":
			return "Gloves"
		&"boots":
			return "Boots"
		&"necklace":
			return "Necklace"
		&"ring":
			return "Ring"
		_:
			return "Weapon"


func _emit_inventory_changed() -> void:
	inventory_changed.emit(_build_inventory_text(), _build_inventory_entries())


func _emit_equipment_changed() -> void:
	equipment_changed.emit(_build_all_hero_bonuses(), _build_all_hero_summaries())


func _build_all_hero_bonuses() -> Dictionary:
	var hero_bonus_by_id: Dictionary = {}
	for hero_id in equipped_by_hero.keys():
		hero_bonus_by_id[hero_id] = _build_total_stat_bonus_for_hero(StringName(hero_id))
	return hero_bonus_by_id


func _build_all_hero_summaries() -> Dictionary:
	var hero_summary_by_id: Dictionary = {}
	for hero_id in equipped_by_hero.keys():
		hero_summary_by_id[hero_id] = _build_character_summary(StringName(hero_id))
	return hero_summary_by_id


func export_state() -> Dictionary:
	var inventory_ids: Array[String] = []
	for item_data in inventory_items:
		inventory_ids.append(str(item_data.id))

	var equipped_by_hero_ids: Dictionary = {}
	for hero_id in equipped_by_hero.keys():
		var equipped_ids: Dictionary = {}
		var equipped_by_slot: Dictionary = equipped_by_hero[hero_id]
		for slot_type in equipped_by_slot.keys():
			var equipped_item: ItemData = equipped_by_slot[slot_type]
			equipped_ids[str(slot_type)] = str(equipped_item.id)
		equipped_by_hero_ids[str(hero_id)] = equipped_ids

	return {
		"inventory_ids": inventory_ids,
		"equipped_by_hero": equipped_by_hero_ids,
		"recent_item_names": recent_item_names.duplicate(),
	}


func apply_state(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return

	inventory_items.clear()
	equipped_by_hero.clear()
	recent_item_names.clear()
	collected_item_ids.clear()

	var inventory_ids: Array = snapshot.get("inventory_ids", [])
	for item_id in inventory_ids:
		var item_data: ItemData = _item_from_id(StringName(item_id))
		if item_data != null:
			inventory_items.append(item_data)
			collected_item_ids.append(item_data.id)

	var equipped_by_hero_ids: Dictionary = snapshot.get("equipped_by_hero", {})
	for hero_id_key in equipped_by_hero_ids.keys():
		var hero_id: StringName = StringName(hero_id_key)
		var equipped_ids: Dictionary = equipped_by_hero_ids[hero_id_key]
		var equipped_by_slot: Dictionary = _hero_equipment(hero_id)
		for slot_type in equipped_ids.keys():
			var equipped_item_id: StringName = StringName(equipped_ids[slot_type])
			var equipped_item: ItemData = _item_from_id(equipped_item_id)
			var normalized_slot_type: StringName = _normalize_slot_type(StringName(slot_type))
			if equipped_item != null:
				equipped_by_slot[normalized_slot_type] = equipped_item

	var legacy_equipped_ids: Dictionary = snapshot.get("equipped_ids", {})
	if not legacy_equipped_ids.is_empty() and equipped_by_hero.is_empty():
		var legacy_slots: Dictionary = _hero_equipment(HERO_ADVENTURER)
		for slot_type in legacy_equipped_ids.keys():
			var equipped_item_id: StringName = StringName(legacy_equipped_ids[slot_type])
			var equipped_item: ItemData = _item_from_id(equipped_item_id)
			var normalized_slot_type: StringName = _normalize_slot_type(StringName(slot_type))
			if equipped_item != null:
				legacy_slots[normalized_slot_type] = equipped_item

	var recent_names: Array = snapshot.get("recent_item_names", [])
	for item_name in recent_names:
		recent_item_names.append(str(item_name))

	_emit_inventory_changed()
	_emit_equipment_changed()


func _item_from_id(item_id: StringName) -> ItemData:
	match item_id:
		&"item_copper_charm":
			return CopperCharmData
		&"item_green_ring":
			return GreenRingData
		&"item_leather_gloves":
			return LeatherGlovesData
		&"item_patched_armor":
			return PatchedArmorData
		&"item_rusty_sword":
			return RustySwordData
		&"item_trail_boots":
			return TrailBootsData
		&"item_worn_buckler":
			return WornBucklerData
		_:
			return null


func _normalize_slot_type(slot_type: StringName) -> StringName:
	if slot_type == &"accessory":
		return &"ring"
	return slot_type
