extends Node

class_name SaveManager

const SAVE_PATH := "user://save_v0_1.json"

signal save_requested

var dirty: bool = false


func _ready() -> void:
	var autosave_timer: Timer = Timer.new()
	autosave_timer.wait_time = 8.0
	autosave_timer.one_shot = false
	autosave_timer.autostart = true
	autosave_timer.timeout.connect(_on_autosave_timeout)
	add_child(autosave_timer)


func mark_dirty() -> void:
	dirty = true


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_snapshot(snapshot: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return

	file.store_string(JSON.stringify(snapshot, "\t"))
	file.close()
	dirty = false


func load_snapshot() -> Dictionary:
	if not has_save():
		return {}

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}

	var content: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: int = json.parse(content)
	if parse_result != OK:
		return {}

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		return {}

	return data as Dictionary


func _on_autosave_timeout() -> void:
	if dirty:
		save_requested.emit()
