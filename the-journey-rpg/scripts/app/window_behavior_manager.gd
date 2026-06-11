extends Node

class_name WindowBehaviorManager

const BASE_WINDOW_SIZE := Vector2i(1280, 320)
const SCALE_COMPACT := 0.70
const SCALE_SMALL := 0.85
const SCALE_DEFAULT := 1.00

signal window_state_changed(summary: Dictionary)

var window_ref: Window
var borderless_enabled: bool = true
var always_on_top_enabled: bool = true
var click_through_enabled: bool = false
var scale_factor: float = SCALE_SMALL
var drag_active: bool = false
var drag_mouse_offset: Vector2i = Vector2i.ZERO


func _ready() -> void:
	window_ref = get_window()
	if window_ref == null:
		return

	window_ref.content_scale_size = BASE_WINDOW_SIZE
	window_ref.content_scale_factor = 1.0
	_apply_window_state()
	_emit_state_changed()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_F8:
			set_click_through_enabled(not click_through_enabled)


func export_state() -> Dictionary:
	var window_position: Vector2i = Vector2i.ZERO
	if window_ref != null:
		window_position = window_ref.position

	return {
		"borderless_enabled": borderless_enabled,
		"always_on_top_enabled": always_on_top_enabled,
		"click_through_enabled": click_through_enabled,
		"scale_factor": scale_factor,
		"window_position_x": window_position.x,
		"window_position_y": window_position.y,
	}


func apply_state(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		_apply_window_state()
		_emit_state_changed()
		return

	borderless_enabled = bool(snapshot.get("borderless_enabled", borderless_enabled))
	always_on_top_enabled = bool(snapshot.get("always_on_top_enabled", always_on_top_enabled))
	click_through_enabled = bool(snapshot.get("click_through_enabled", click_through_enabled))
	scale_factor = clampf(float(snapshot.get("scale_factor", scale_factor)), SCALE_COMPACT, SCALE_DEFAULT)
	_apply_window_state()

	if window_ref != null:
		var position_x: int = int(snapshot.get("window_position_x", window_ref.position.x))
		var position_y: int = int(snapshot.get("window_position_y", window_ref.position.y))
		window_ref.position = Vector2i(position_x, position_y)

	_emit_state_changed()


func set_borderless_enabled(enabled: bool) -> void:
	borderless_enabled = enabled
	if window_ref != null:
		window_ref.borderless = borderless_enabled
	_emit_state_changed()


func set_always_on_top_enabled(enabled: bool) -> void:
	always_on_top_enabled = enabled
	if window_ref != null:
		window_ref.always_on_top = always_on_top_enabled
	_emit_state_changed()


func set_click_through_enabled(enabled: bool) -> void:
	click_through_enabled = enabled
	if window_ref != null:
		_update_mouse_passthrough()
	_emit_state_changed()


func set_scale_preset(preset_id: int) -> void:
	match preset_id:
		0:
			scale_factor = SCALE_COMPACT
		1:
			scale_factor = SCALE_SMALL
		_:
			scale_factor = SCALE_DEFAULT

	_apply_window_size()
	_emit_state_changed()


func get_scale_preset_id() -> int:
	if is_equal_approx(scale_factor, SCALE_COMPACT):
		return 0
	if is_equal_approx(scale_factor, SCALE_SMALL):
		return 1
	return 2


func begin_window_drag() -> void:
	if window_ref == null:
		return
	drag_active = true
	drag_mouse_offset = window_ref.position - DisplayServer.mouse_get_position()


func update_window_drag() -> void:
	if not drag_active or window_ref == null:
		return
	window_ref.position = DisplayServer.mouse_get_position() + drag_mouse_offset


func end_window_drag() -> void:
	if not drag_active:
		return
	drag_active = false
	_emit_state_changed()


func get_summary() -> Dictionary:
	var position_text: String = "Unknown"
	if window_ref != null:
		position_text = "%d, %d" % [window_ref.position.x, window_ref.position.y]

	return {
		"borderless_enabled": borderless_enabled,
		"always_on_top_enabled": always_on_top_enabled,
		"click_through_enabled": click_through_enabled,
		"scale_preset_id": get_scale_preset_id(),
		"summary_text": "Borderless: %s\nAlways on top: %s\nScale: %s\nClick-through: %s\nWindow position: %s\n\nDrag the top status bar to move the window.\nPress F8 to toggle click-through quickly." % [
			"On" if borderless_enabled else "Off",
			"On" if always_on_top_enabled else "Off",
			_scale_label(),
			"On" if click_through_enabled else "Off",
			position_text,
		],
	}


func _apply_window_state() -> void:
	if window_ref == null:
		return

	window_ref.borderless = borderless_enabled
	window_ref.always_on_top = always_on_top_enabled
	_apply_window_size()
	_update_mouse_passthrough()


func _apply_window_size() -> void:
	if window_ref == null:
		return

	var scaled_width: int = int(round(float(BASE_WINDOW_SIZE.x) * scale_factor))
	var scaled_height: int = int(round(float(BASE_WINDOW_SIZE.y) * scale_factor))
	window_ref.size = Vector2i(scaled_width, scaled_height)
	_update_mouse_passthrough()


func _update_mouse_passthrough() -> void:
	if window_ref == null:
		return

	if not click_through_enabled:
		window_ref.mouse_passthrough = false
		window_ref.mouse_passthrough_polygon = PackedVector2Array()
		return

	window_ref.mouse_passthrough = false
	window_ref.mouse_passthrough_polygon = _build_interaction_polygon()


func _build_interaction_polygon() -> PackedVector2Array:
	if window_ref == null:
		return PackedVector2Array()

	var scale_x: float = float(window_ref.size.x) / float(BASE_WINDOW_SIZE.x)
	var scale_y: float = float(window_ref.size.y) / float(BASE_WINDOW_SIZE.y)
	return PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(float(window_ref.size.x), 0.0),
		Vector2(float(window_ref.size.x), 316.0 * scale_y),
		Vector2(940.0 * scale_x, 316.0 * scale_y),
		Vector2(940.0 * scale_x, 108.0 * scale_y),
		Vector2(0.0, 108.0 * scale_y),
	])


func _scale_label() -> String:
	match get_scale_preset_id():
		0:
			return "Compact (70%)"
		1:
			return "Small (85%)"
		_:
			return "Default (100%)"


func _emit_state_changed() -> void:
	window_state_changed.emit(get_summary())
