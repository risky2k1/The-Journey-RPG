extends Node

class_name SaveManager

const SAVE_PATH := "user://save_v0_1.json"


func mark_dirty() -> void:
	pass


func save_snapshot(_snapshot: Dictionary) -> void:
	pass


func load_snapshot() -> Dictionary:
	return {}
