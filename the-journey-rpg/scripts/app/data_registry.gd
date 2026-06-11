extends Node

class_name DataRegistry

const HERO_DATA_DIR := "res://resources/heroes"
const ENEMY_DATA_DIR := "res://resources/enemies"
const STAGE_DATA_DIR := "res://resources/stages"
const ITEM_DATA_DIR := "res://resources/items"

var heroes: Dictionary[StringName, Resource] = {}
var enemies: Dictionary[StringName, Resource] = {}
var stages: Dictionary[StringName, Resource] = {}
var items: Dictionary[StringName, Resource] = {}


func _ready() -> void:
	heroes = _load_resources(HERO_DATA_DIR)
	enemies = _load_resources(ENEMY_DATA_DIR)
	stages = _load_resources(STAGE_DATA_DIR)
	items = _load_resources(ITEM_DATA_DIR)


func get_hero_data(id: StringName) -> Resource:
	return heroes.get(id)


func get_enemy_data(id: StringName) -> Resource:
	return enemies.get(id)


func get_stage_data(id: StringName) -> Resource:
	return stages.get(id)


func get_item_data(id: StringName) -> Resource:
	return items.get(id)


func _load_resources(directory: String) -> Dictionary[StringName, Resource]:
	var result: Dictionary[StringName, Resource] = {}
	var dir := DirAccess.open(directory)

	if dir == null:
		return result

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var path := directory.path_join(file_name)
			var resource := load(path)
			if resource != null and resource.get("id") != null:
				result[StringName(resource.id)] = resource
		file_name = dir.get_next()
	dir.list_dir_end()

	return result
