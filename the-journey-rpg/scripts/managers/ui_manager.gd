extends CanvasLayer

class_name UIManager

@onready var panel_stack: TabContainer = get_node("HUD/PanelHost/PanelStack")
@onready var inventory_button: Button = get_node("HUD/QuickButtons/InventoryButton")
@onready var character_button: Button = get_node("HUD/QuickButtons/CharacterButton")
@onready var team_button: Button = get_node("HUD/QuickButtons/TeamButton")
@onready var settings_button: Button = get_node("HUD/QuickButtons/SettingsButton")
@onready var top_bar: PanelContainer = get_node("HUD/TopBar")
@onready var top_bar_label: Label = get_node("HUD/TopBar/TopBarLabel")
@onready var loot_feed_label: Label = get_node("HUD/LootFeed/LootFeedLabel")
@onready var inventory_item_list: ItemList = get_node("HUD/PanelHost/PanelStack/InventoryPanel/ItemList")
@onready var inventory_body_label: RichTextLabel = get_node("HUD/PanelHost/PanelStack/InventoryPanel/Body")
@onready var character_body_label: RichTextLabel = get_node("HUD/PanelHost/PanelStack/CharacterPanel/Body")
@onready var team_body_label: RichTextLabel = get_node("HUD/PanelHost/PanelStack/TeamPanel/Body")
@onready var settings_body_label: RichTextLabel = get_node("HUD/PanelHost/PanelStack/SettingsPanel/Body")
@onready var borderless_toggle: CheckButton = get_node("HUD/PanelHost/PanelStack/SettingsPanel/BorderlessToggle")
@onready var always_on_top_toggle: CheckButton = get_node("HUD/PanelHost/PanelStack/SettingsPanel/AlwaysOnTopToggle")
@onready var click_through_toggle: CheckButton = get_node("HUD/PanelHost/PanelStack/SettingsPanel/ClickThroughToggle")
@onready var scale_preset_button: OptionButton = get_node("HUD/PanelHost/PanelStack/SettingsPanel/ScalePreset")

var loot_manager: LootManager
var progression_manager: ProgressionManager
var window_behavior_manager: WindowBehaviorManager
var last_battle_status: String = "Combat idle"
var progression_summary: Dictionary = {}
var equipment_summary_text: String = "Equipped Weapon: None\nEquipped Accessory: None\nBonus HP: +0\nBonus Attack: +0"


func _ready() -> void:
	inventory_button.pressed.connect(_open_inventory)
	character_button.pressed.connect(_open_character)
	team_button.pressed.connect(_open_team)
	settings_button.pressed.connect(_open_settings)
	top_bar.gui_input.connect(_handle_window_drag_input)
	inventory_item_list.item_selected.connect(_equip_inventory_item)
	borderless_toggle.toggled.connect(_on_borderless_toggled)
	always_on_top_toggle.toggled.connect(_on_always_on_top_toggled)
	click_through_toggle.toggled.connect(_on_click_through_toggled)
	scale_preset_button.item_selected.connect(_on_scale_preset_selected)
	scale_preset_button.add_item("Compact (70%)")
	scale_preset_button.add_item("Small (85%)")
	scale_preset_button.add_item("Default (100%)")
	var battle_root := get_parent().get_node_or_null("BattleRoot")
	if battle_root != null and battle_root.has_signal("battle_status_changed"):
		battle_root.battle_status_changed.connect(_update_status)
	if battle_root != null and battle_root.has_signal("battle_event_changed"):
		battle_root.battle_event_changed.connect(_update_event)
	loot_manager = get_parent().get_parent().get_node_or_null("AppRoot/LootManager")
	if loot_manager != null and loot_manager.has_signal("inventory_changed"):
		loot_manager.inventory_changed.connect(_update_inventory)
	if loot_manager != null and loot_manager.has_signal("equipment_changed"):
		loot_manager.equipment_changed.connect(_update_character_summary)
	progression_manager = get_parent().get_parent().get_node_or_null("AppRoot/ProgressionManager")
	if progression_manager != null and progression_manager.has_signal("progression_changed"):
		progression_manager.progression_changed.connect(_update_progression)
	if progression_manager != null and progression_manager.has_signal("progression_event"):
		progression_manager.progression_event.connect(_update_event)
	if progression_manager != null and progression_manager.has_method("get_summary"):
		_update_progression(progression_manager.get_summary())
	window_behavior_manager = get_parent().get_parent().get_node_or_null("AppRoot/WindowBehaviorManager")
	if window_behavior_manager != null and window_behavior_manager.has_signal("window_state_changed"):
		window_behavior_manager.window_state_changed.connect(_update_window_settings)
	if window_behavior_manager != null and window_behavior_manager.has_method("get_summary"):
		_update_window_settings(window_behavior_manager.get_summary())


func _input(event: InputEvent) -> void:
	if window_behavior_manager == null:
		return

	if event is InputEventMouseMotion:
		window_behavior_manager.update_window_drag()
		return

	if event is InputEventMouseButton:
		var button_event: InputEventMouseButton = event
		if button_event.button_index == MOUSE_BUTTON_LEFT and not button_event.pressed:
			window_behavior_manager.end_window_drag()


func _open_inventory() -> void:
	panel_stack.current_tab = 0


func _open_character() -> void:
	panel_stack.current_tab = 1


func _open_team() -> void:
	panel_stack.current_tab = 2


func _open_settings() -> void:
	panel_stack.current_tab = 3


func _update_status(status_text: String) -> void:
	last_battle_status = status_text
	_refresh_top_bar()


func _update_event(event_text: String) -> void:
	loot_feed_label.text = event_text.left(48)


func _update_inventory(inventory_text: String, inventory_entries: Array) -> void:
	inventory_body_label.text = inventory_text
	inventory_item_list.clear()

	for entry in inventory_entries:
		inventory_item_list.add_item(entry["label"])
		var item_index: int = inventory_item_list.get_item_count() - 1
		inventory_item_list.set_item_metadata(item_index, entry["index"])
		inventory_item_list.set_item_custom_fg_color(item_index, _color_for_rarity(StringName(entry["rarity"])))


func _update_character_summary(_total_stats: Dictionary, summary_text: String) -> void:
	equipment_summary_text = summary_text
	_refresh_character_summary()


func _equip_inventory_item(item_index: int) -> void:
	if loot_manager == null:
		return

	var inventory_index = inventory_item_list.get_item_metadata(item_index)
	loot_manager.equip_item_at(inventory_index)
	loot_feed_label.text = "Equipped item from inventory"


func _color_for_rarity(rarity: StringName) -> Color:
	match rarity:
		&"uncommon":
			return Color(0.45, 0.95, 0.55, 1.0)
		&"rare":
			return Color(0.45, 0.65, 1.0, 1.0)
		_:
			return Color(0.9, 0.9, 0.9, 1.0)


func _update_progression(summary: Dictionary) -> void:
	progression_summary = summary
	_refresh_top_bar()
	_refresh_character_summary()
	team_body_label.text = String(summary.get("team_progress_text", ""))


func _refresh_top_bar() -> void:
	var level: int = int(progression_summary.get("profile_level", 1))
	var exp: int = int(progression_summary.get("current_exp", 0))
	var exp_to_next: int = int(progression_summary.get("exp_to_next", 10))
	var coin: int = int(progression_summary.get("currency", 0))
	top_bar_label.text = "Lv %d  |  EXP %d/%d  |  Coin %d  |  %s" % [
		level,
		exp,
		exp_to_next,
		coin,
		last_battle_status,
	]


func _refresh_character_summary() -> void:
	var progress_text: String = String(progression_summary.get("character_progress_text", "Level: 1\nEXP: 0/10\nCoin: 0"))
	character_body_label.text = "%s\n\n%s" % [progress_text, equipment_summary_text]


func _update_window_settings(summary: Dictionary) -> void:
	var borderless_value: bool = bool(summary.get("borderless_enabled", false))
	var always_on_top_value: bool = bool(summary.get("always_on_top_enabled", false))
	var click_through_value: bool = bool(summary.get("click_through_enabled", false))
	var scale_preset_id: int = int(summary.get("scale_preset_id", 1))
	var summary_text: String = String(summary.get("summary_text", "Window settings"))

	borderless_toggle.set_pressed_no_signal(borderless_value)
	always_on_top_toggle.set_pressed_no_signal(always_on_top_value)
	click_through_toggle.set_pressed_no_signal(click_through_value)
	scale_preset_button.select(scale_preset_id)
	settings_body_label.text = summary_text


func _on_borderless_toggled(button_pressed: bool) -> void:
	if window_behavior_manager != null:
		window_behavior_manager.set_borderless_enabled(button_pressed)


func _on_always_on_top_toggled(button_pressed: bool) -> void:
	if window_behavior_manager != null:
		window_behavior_manager.set_always_on_top_enabled(button_pressed)


func _on_click_through_toggled(button_pressed: bool) -> void:
	if window_behavior_manager != null:
		window_behavior_manager.set_click_through_enabled(button_pressed)


func _on_scale_preset_selected(index: int) -> void:
	if window_behavior_manager != null:
		window_behavior_manager.set_scale_preset(index)


func _handle_window_drag_input(event: InputEvent) -> void:
	if window_behavior_manager == null:
		return

	if event is InputEventMouseButton:
		var button_event: InputEventMouseButton = event
		if button_event.button_index != MOUSE_BUTTON_LEFT:
			return
		if button_event.pressed:
			window_behavior_manager.begin_window_drag()
		else:
			window_behavior_manager.end_window_drag()
		return

	if event is InputEventMouseMotion:
		window_behavior_manager.update_window_drag()
