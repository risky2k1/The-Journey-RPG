extends CanvasLayer

class_name UIManager

@onready var panel_stack: TabContainer = get_node("HUD/PanelHost/PanelPadding/PanelStack")
@onready var inventory_button: Button = get_node("HUD/QuickButtons/InventoryButton")
@onready var character_button: Button = get_node("HUD/QuickButtons/CharacterButton")
@onready var team_button: Button = get_node("HUD/QuickButtons/TeamButton")
@onready var settings_button: Button = get_node("HUD/QuickButtons/SettingsButton")
@onready var top_bar: PanelContainer = get_node("HUD/TopBar")
@onready var top_bar_label: Label = get_node("HUD/TopBar/TopBarContent/TopBarLabel")
@onready var top_bar_sub_label: Label = get_node("HUD/TopBar/TopBarContent/TopBarSubLabel")
@onready var loot_feed_label: Label = get_node("HUD/LootFeed/LootFeedContent/LootFeedLabel")
@onready var inventory_item_list: ItemList = get_node("HUD/PanelHost/PanelPadding/PanelStack/InventoryPanel/ItemList")
@onready var inventory_body_label: RichTextLabel = get_node("HUD/PanelHost/PanelPadding/PanelStack/InventoryPanel/Body")
@onready var character_roster: HBoxContainer = get_node("HUD/PanelHost/PanelPadding/PanelStack/CharacterPanel/HeroRoster")
@onready var character_body_label: RichTextLabel = get_node("HUD/PanelHost/PanelPadding/PanelStack/CharacterPanel/Body")
@onready var team_body_label: RichTextLabel = get_node("HUD/PanelHost/PanelPadding/PanelStack/TeamPanel/Scroll/Content/Body")
@onready var team_roster: HBoxContainer = get_node("HUD/PanelHost/PanelPadding/PanelStack/TeamPanel/Scroll/Content/HeroRoster")
@onready var team_grid: GridContainer = get_node("HUD/PanelHost/PanelPadding/PanelStack/TeamPanel/Scroll/Content/FormationGrid")
@onready var settings_body_label: RichTextLabel = get_node("HUD/PanelHost/PanelPadding/PanelStack/SettingsPanel/Body")
@onready var borderless_toggle: CheckButton = get_node("HUD/PanelHost/PanelPadding/PanelStack/SettingsPanel/BorderlessToggle")
@onready var always_on_top_toggle: CheckButton = get_node("HUD/PanelHost/PanelPadding/PanelStack/SettingsPanel/AlwaysOnTopToggle")
@onready var click_through_toggle: CheckButton = get_node("HUD/PanelHost/PanelPadding/PanelStack/SettingsPanel/ClickThroughToggle")
@onready var scale_preset_button: OptionButton = get_node("HUD/PanelHost/PanelPadding/PanelStack/SettingsPanel/ScalePreset")

var loot_manager: LootManager
var progression_manager: ProgressionManager
var team_manager: TeamManager
var window_behavior_manager: WindowBehaviorManager
var last_battle_status: String = "Combat idle"
var last_event_text: String = "Latest event"
var progression_summary: Dictionary = {}
var character_equipment_summaries: Dictionary = {}
var selected_character_hero_id: StringName = &"hero_adventurer"
var selected_team_hero_id: StringName = &"hero_adventurer"
var character_roster_buttons_by_hero: Dictionary = {}
var team_roster_buttons_by_hero: Dictionary = {}
var team_slot_buttons: Array[Button] = []


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
	_setup_character_panel()
	_setup_team_panel()
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
	_refresh_loot_feed()
	team_manager = get_parent().get_parent().get_node_or_null("AppRoot/TeamManager")
	if team_manager != null and team_manager.has_signal("team_changed"):
		team_manager.team_changed.connect(_update_team_panel)
	if team_manager != null and team_manager.has_method("get_summary"):
		_update_team_panel(team_manager.get_summary())
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
	last_event_text = event_text
	_refresh_loot_feed()


func _update_inventory(inventory_text: String, inventory_entries: Array) -> void:
	inventory_body_label.text = inventory_text
	inventory_item_list.clear()

	for entry in inventory_entries:
		inventory_item_list.add_item(entry["label"])
		var item_index: int = inventory_item_list.get_item_count() - 1
		inventory_item_list.set_item_metadata(item_index, entry["index"])
		inventory_item_list.set_item_custom_fg_color(item_index, _color_for_rarity(StringName(entry["rarity"])))


func _update_character_summary(_hero_bonus_by_id: Dictionary, hero_summary_by_id: Dictionary) -> void:
	character_equipment_summaries = hero_summary_by_id.duplicate()
	_refresh_character_summary()


func _equip_inventory_item(item_index: int) -> void:
	if loot_manager == null:
		return

	var inventory_index = inventory_item_list.get_item_metadata(item_index)
	loot_manager.equip_item_at(inventory_index, selected_character_hero_id)
	last_event_text = "Equipped item to %s" % _team_hero_name(selected_character_hero_id)
	_refresh_loot_feed()


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


func _refresh_top_bar() -> void:
	var level: int = int(progression_summary.get("profile_level", 1))
	var exp: int = int(progression_summary.get("current_exp", 0))
	var exp_to_next: int = int(progression_summary.get("exp_to_next", 10))
	var coin: int = int(progression_summary.get("currency", 0))
	top_bar_label.text = "Lv %d  |  EXP %d/%d  |  Coin %d" % [
		level,
		exp,
		exp_to_next,
		coin,
	]
	top_bar_sub_label.text = "%s  |  Drag this bar to move the window" % last_battle_status


func _refresh_character_summary() -> void:
	var progress_text: String = str(progression_summary.get("character_progress_text", "Level: 1\nEXP: 0/10\nCoin: 0"))
	var equipment_text: String = ""
	if character_equipment_summaries.has(selected_character_hero_id):
		equipment_text = str(character_equipment_summaries[selected_character_hero_id])
	elif loot_manager != null:
		equipment_text = loot_manager.get_character_summary(selected_character_hero_id)
	character_body_label.text = "%s\n\n%s" % [progress_text, equipment_text]


func _refresh_loot_feed() -> void:
	loot_feed_label.text = last_event_text.left(88)


func _setup_character_panel() -> void:
	var hero_ids: Array[StringName] = [
		&"hero_adventurer",
		&"hero_apprentice",
	]
	for hero_id in hero_ids:
		var hero_button: Button = Button.new()
		hero_button.custom_minimum_size = Vector2(96.0, 28.0)
		hero_button.toggle_mode = true
		hero_button.text = _team_hero_name(hero_id)
		hero_button.pressed.connect(_on_character_hero_selected.bind(hero_id))
		character_roster.add_child(hero_button)
		character_roster_buttons_by_hero[hero_id] = hero_button
	_refresh_character_roster_selection()


func _setup_team_panel() -> void:
	var hero_ids: Array[StringName] = [
		&"hero_adventurer",
		&"hero_apprentice",
	]
	for hero_id in hero_ids:
		var hero_button: Button = Button.new()
		hero_button.custom_minimum_size = Vector2(84.0, 28.0)
		hero_button.toggle_mode = true
		hero_button.text = _team_hero_name(hero_id)
		hero_button.pressed.connect(_on_team_hero_selected.bind(hero_id))
		team_roster.add_child(hero_button)
		team_roster_buttons_by_hero[hero_id] = hero_button

	for slot_index in range(9):
		var slot_button: Button = Button.new()
		slot_button.custom_minimum_size = Vector2(62.0, 46.0)
		slot_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		slot_button.clip_text = true
		slot_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_button.pressed.connect(_on_team_slot_pressed.bind(slot_index))
		team_grid.add_child(slot_button)
		team_slot_buttons.append(slot_button)


func _update_team_panel(summary: Dictionary) -> void:
	team_body_label.text = str(summary.get("body_text", "Team formation"))

	var available_heroes: Array = summary.get("available_heroes", [])
	for hero_entry in available_heroes:
		var hero_id: StringName = StringName(hero_entry.get("hero_id", &""))
		var hero_button: Button = team_roster_buttons_by_hero.get(hero_id) as Button
		var character_button: Button = character_roster_buttons_by_hero.get(hero_id) as Button
		if hero_button == null:
			continue
		var is_available: bool = bool(hero_entry.get("available", false))
		var assigned_slot_index: int = int(hero_entry.get("assigned_slot_index", -1))
		hero_button.disabled = not is_available
		if character_button != null:
			character_button.disabled = not is_available
		hero_button.set_pressed_no_signal(selected_team_hero_id == hero_id and is_available)
		hero_button.text = "%s%s" % [
			_team_hero_name(hero_id),
			" [%d]" % [assigned_slot_index + 1] if assigned_slot_index >= 0 else "",
		]
		if character_button != null:
			character_button.text = _team_hero_name(hero_id)
		if not is_available and selected_team_hero_id == hero_id:
			selected_team_hero_id = &"hero_adventurer"
		if not is_available and selected_character_hero_id == hero_id:
			selected_character_hero_id = &"hero_adventurer"

	var slots: Array = summary.get("slots", [])
	for slot_index in range(mini(slots.size(), team_slot_buttons.size())):
		var slot_summary: Dictionary = slots[slot_index]
		var slot_button: Button = team_slot_buttons[slot_index]
		var is_unlocked: bool = bool(slot_summary.get("unlocked", false))
		slot_button.disabled = not is_unlocked
		slot_button.text = str(slot_summary.get("button_text", "Slot"))
		var hero_id: StringName = StringName(slot_summary.get("hero_id", &""))
		if not is_unlocked:
			slot_button.modulate = Color(0.72, 0.72, 0.76, 0.72)
		elif hero_id == &"":
			slot_button.modulate = Color(0.94, 0.94, 0.98, 1.0)
		elif hero_id == &"hero_apprentice":
			slot_button.modulate = Color(0.84, 0.92, 1.0, 1.0)
		else:
			slot_button.modulate = Color(0.86, 1.0, 0.9, 1.0)

	_refresh_team_roster_selection()
	_refresh_character_roster_selection()
	_refresh_character_summary()


func _refresh_team_roster_selection() -> void:
	for hero_id in team_roster_buttons_by_hero.keys():
		var hero_button: Button = team_roster_buttons_by_hero[hero_id] as Button
		if hero_button != null:
			hero_button.set_pressed_no_signal(StringName(hero_id) == selected_team_hero_id and not hero_button.disabled)


func _refresh_character_roster_selection() -> void:
	for hero_id in character_roster_buttons_by_hero.keys():
		var hero_button: Button = character_roster_buttons_by_hero[hero_id] as Button
		if hero_button != null:
			hero_button.set_pressed_no_signal(StringName(hero_id) == selected_character_hero_id and not hero_button.disabled)


func _on_team_hero_selected(hero_id: StringName) -> void:
	selected_team_hero_id = hero_id
	_refresh_team_roster_selection()


func _on_character_hero_selected(hero_id: StringName) -> void:
	selected_character_hero_id = hero_id
	_refresh_character_roster_selection()
	_refresh_character_summary()


func _on_team_slot_pressed(slot_index: int) -> void:
	if team_manager == null:
		return
	team_manager.assign_hero_to_slot(selected_team_hero_id, slot_index)


func _team_hero_name(hero_id: StringName) -> String:
	match hero_id:
		&"hero_apprentice":
			return "Apprentice"
		_:
			return "Adventurer"


func _update_window_settings(summary: Dictionary) -> void:
	var borderless_value: bool = bool(summary.get("borderless_enabled", false))
	var always_on_top_value: bool = bool(summary.get("always_on_top_enabled", false))
	var click_through_value: bool = bool(summary.get("click_through_enabled", false))
	var scale_preset_id: int = int(summary.get("scale_preset_id", 1))
	var summary_text: String = str(summary.get("summary_text", "Window settings"))

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
