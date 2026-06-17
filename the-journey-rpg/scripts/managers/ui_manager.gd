extends CanvasLayer

class_name UIManager

const ACTION_PANEL_TEXTURE := preload("res://assets/ui/Action_panel.png")
const INVENTORY_PANEL_TEXTURE := preload("res://assets/ui/Inventory.png")
const CHARACTER_PANEL_TEXTURE := preload("res://assets/ui/character_panel.png")
const LOOT_PANEL_REGION := Rect2(0, 0, 112, 96)
const SIDE_PANEL_RECT := Rect2(0.0, 0.0, 192.0, 160.0)
const BUTTON_FILL_COLOR := Color(0.66, 0.9, 0.58, 0.94)
const BUTTON_HOVER_COLOR := Color(0.78, 0.95, 0.68, 0.98)
const BUTTON_PRESSED_COLOR := Color(0.42, 0.76, 0.38, 0.98)
const PANEL_TEXT_COLOR := Color(0.15, 0.14, 0.1, 1.0)
const PANEL_MUTED_TEXT_COLOR := Color(0.33, 0.31, 0.22, 0.96)

@onready var hud: Control = get_node("HUD")
@onready var panel_padding: MarginContainer = get_node("HUD/PanelHost/PanelPadding")
@onready var panel_stack: TabContainer = get_node("HUD/PanelHost/PanelPadding/PanelStack")
@onready var inventory_button: Button = get_node("HUD/QuickButtons/InventoryButton")
@onready var character_button: Button = get_node("HUD/QuickButtons/CharacterButton")
@onready var team_button: Button = get_node("HUD/QuickButtons/TeamButton")
@onready var settings_button: Button = get_node("HUD/QuickButtons/SettingsButton")
@onready var quick_buttons: HBoxContainer = get_node("HUD/QuickButtons")
@onready var top_bar: PanelContainer = get_node("HUD/TopBar")
@onready var top_bar_label: Label = get_node("HUD/TopBar/TopBarContent/TopBarLabel")
@onready var top_bar_sub_label: Label = get_node("HUD/TopBar/TopBarContent/TopBarSubLabel")
@onready var loot_feed: PanelContainer = get_node("HUD/LootFeed")
@onready var loot_feed_label: Label = get_node("HUD/LootFeed/LootFeedContent/LootFeedLabel")
@onready var panel_host: PanelContainer = get_node("HUD/PanelHost")
@onready var inventory_panel: VBoxContainer = get_node("HUD/PanelHost/PanelPadding/PanelStack/InventoryPanel")
@onready var inventory_title: Label = get_node("HUD/PanelHost/PanelPadding/PanelStack/InventoryPanel/Title")
@onready var inventory_hint: Label = get_node("HUD/PanelHost/PanelPadding/PanelStack/InventoryPanel/Hint")
@onready var inventory_item_list: ItemList = get_node("HUD/PanelHost/PanelPadding/PanelStack/InventoryPanel/ItemList")
@onready var inventory_body_label: RichTextLabel = get_node("HUD/PanelHost/PanelPadding/PanelStack/InventoryPanel/Body")
@onready var character_panel: VBoxContainer = get_node("HUD/PanelHost/PanelPadding/PanelStack/CharacterPanel")
@onready var character_title: Label = get_node("HUD/PanelHost/PanelPadding/PanelStack/CharacterPanel/Title")
@onready var character_hint: Label = get_node("HUD/PanelHost/PanelPadding/PanelStack/CharacterPanel/Hint")
@onready var character_roster: HBoxContainer = get_node("HUD/PanelHost/PanelPadding/PanelStack/CharacterPanel/HeroRoster")
@onready var character_body_label: RichTextLabel = get_node("HUD/PanelHost/PanelPadding/PanelStack/CharacterPanel/Body")
@onready var team_panel: VBoxContainer = get_node("HUD/PanelHost/PanelPadding/PanelStack/TeamPanel")
@onready var team_title: Label = get_node("HUD/PanelHost/PanelPadding/PanelStack/TeamPanel/Title")
@onready var team_hint: Label = get_node("HUD/PanelHost/PanelPadding/PanelStack/TeamPanel/Scroll/Content/Hint")
@onready var team_body_label: RichTextLabel = get_node("HUD/PanelHost/PanelPadding/PanelStack/TeamPanel/Scroll/Content/Body")
@onready var team_roster: HBoxContainer = get_node("HUD/PanelHost/PanelPadding/PanelStack/TeamPanel/Scroll/Content/HeroRoster")
@onready var team_grid: GridContainer = get_node("HUD/PanelHost/PanelPadding/PanelStack/TeamPanel/Scroll/Content/FormationGrid")
@onready var settings_panel: VBoxContainer = get_node("HUD/PanelHost/PanelPadding/PanelStack/SettingsPanel")
@onready var settings_title: Label = get_node("HUD/PanelHost/PanelPadding/PanelStack/SettingsPanel/Title")
@onready var settings_body_label: RichTextLabel = get_node("HUD/PanelHost/PanelPadding/PanelStack/SettingsPanel/Body")
@onready var settings_scale_label: Label = get_node("HUD/PanelHost/PanelPadding/PanelStack/SettingsPanel/ScaleLabel")
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
	_apply_ui_skin()
	panel_stack.tab_changed.connect(_on_panel_tab_changed)
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


func _apply_ui_skin() -> void:
	panel_stack.tabs_visible = false
	_apply_panel_surface(top_bar, Color(0.32, 0.23, 0.12, 0.92), Color(0.72, 0.58, 0.34, 0.9), 8)
	_apply_panel_surface(loot_feed, Color(0.9, 0.84, 0.62, 0.94), Color(0.62, 0.46, 0.24, 0.92), 8)
	_apply_panel_surface(panel_host, Color(0.9, 0.84, 0.62, 0.96), Color(0.62, 0.46, 0.24, 0.92), 10)

	top_bar.offset_left = 24.0
	top_bar.offset_top = 20.0
	top_bar.offset_right = 900.0
	top_bar.offset_bottom = 86.0
	quick_buttons.offset_left = 24.0
	quick_buttons.offset_top = 94.0
	quick_buttons.offset_right = 480.0
	quick_buttons.offset_bottom = 122.0
	loot_feed.offset_left = 24.0
	loot_feed.offset_top = 132.0
	loot_feed.offset_right = 292.0
	loot_feed.offset_bottom = 250.0
	panel_host.offset_left = 930.0
	panel_host.offset_top = 20.0
	panel_host.offset_right = 1256.0
	panel_host.offset_bottom = 690.0

	_upsert_hud_backdrop("ActionPanelArt", ACTION_PANEL_TEXTURE, Rect2(12.0, 10.0, 532.0, 128.0))
	_hide_hud_backdrop("LootPanelArt")
	_hide_hud_backdrop("SidePanelArt")

	top_bar_label.add_theme_font_size_override("font_size", 16)
	top_bar_label.modulate = Color(0.96, 0.93, 0.84, 1.0)
	top_bar_sub_label.modulate = Color(0.88, 0.8, 0.62, 0.96)
	loot_feed_label.modulate = PANEL_TEXT_COLOR
	_style_top_bar_content()
	_style_panel_host()
	_style_inventory_panel()
	_style_character_panel()
	_style_team_panel()
	_style_settings_panel()

	for button in [inventory_button, character_button, team_button, settings_button]:
		_style_quick_button(button)

	for hero_button in character_roster_buttons_by_hero.values():
		_style_roster_button(hero_button as Button, Vector2(96.0, 28.0))
	for hero_button in team_roster_buttons_by_hero.values():
		_style_roster_button(hero_button as Button, Vector2(84.0, 28.0))
	for slot_button in team_slot_buttons:
		_style_slot_button(slot_button)
	_hide_panel_art()


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
		_style_roster_button(hero_button, Vector2(96.0, 28.0))
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
		_style_roster_button(hero_button, Vector2(84.0, 28.0))

	for slot_index in range(9):
		var slot_button: Button = Button.new()
		slot_button.custom_minimum_size = Vector2(62.0, 46.0)
		slot_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		slot_button.clip_text = true
		slot_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_button.pressed.connect(_on_team_slot_pressed.bind(slot_index))
		team_grid.add_child(slot_button)
		team_slot_buttons.append(slot_button)
		_style_slot_button(slot_button)


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


func _on_panel_tab_changed(_tab_index: int) -> void:
	pass


func _apply_panel_surface(panel: PanelContainer, fill_color: Color, border_color: Color, corner_radius: int) -> void:
	panel.add_theme_stylebox_override("panel", _filled_stylebox(fill_color, border_color, corner_radius))
	panel.self_modulate = Color(1.0, 1.0, 1.0, 1.0)


func _upsert_hud_backdrop(node_name: String, texture: Texture2D, rect: Rect2) -> void:
	var texture_rect: TextureRect = hud.get_node_or_null(node_name) as TextureRect
	if texture_rect == null:
		texture_rect = TextureRect.new()
		texture_rect.name = node_name
		texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
		hud.add_child(texture_rect)
		hud.move_child(texture_rect, 0)
	texture_rect.texture = texture
	texture_rect.position = rect.position
	texture_rect.size = rect.size


func _hide_hud_backdrop(node_name: String) -> void:
	var texture_rect: TextureRect = hud.get_node_or_null(node_name) as TextureRect
	if texture_rect != null:
		texture_rect.visible = false


func _upsert_panel_backdrop(texture: Texture2D) -> void:
	var texture_rect: TextureRect = panel_host.get_node_or_null("PanelArt") as TextureRect
	if texture_rect == null:
		texture_rect = TextureRect.new()
		texture_rect.name = "PanelArt"
		texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
		panel_host.add_child(texture_rect)
		panel_host.move_child(texture_rect, 0)
		texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_rect.texture = texture
	texture_rect.visible = true


func _atlas_texture(texture: Texture2D, region: Rect2) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = region
	return atlas


func _hide_panel_art() -> void:
	var texture_rect: TextureRect = panel_host.get_node_or_null("PanelArt") as TextureRect
	if texture_rect != null:
		texture_rect.visible = false


func _style_top_bar_content() -> void:
	top_bar_label.add_theme_color_override("font_color", Color(0.96, 0.93, 0.84, 1.0))
	top_bar_sub_label.add_theme_color_override("font_color", Color(0.88, 0.8, 0.62, 0.96))
	loot_feed_label.add_theme_color_override("font_color", PANEL_TEXT_COLOR)


func _style_panel_host() -> void:
	panel_padding.add_theme_constant_override("margin_left", 14)
	panel_padding.add_theme_constant_override("margin_top", 14)
	panel_padding.add_theme_constant_override("margin_right", 14)
	panel_padding.add_theme_constant_override("margin_bottom", 14)


func _style_inventory_panel() -> void:
	_style_panel_title(inventory_title)
	_style_panel_hint(inventory_hint)
	_style_rich_text_panel(inventory_body_label, Color(0.22, 0.18, 0.1, 0.82))
	inventory_item_list.add_theme_color_override("font_color", PANEL_TEXT_COLOR)
	inventory_item_list.add_theme_stylebox_override("panel", _filled_stylebox(Color(0.95, 0.88, 0.64, 0.44), Color(0.38, 0.28, 0.12, 0.72), 4))
	inventory_item_list.custom_minimum_size = Vector2(0.0, 260.0)
	inventory_body_label.custom_minimum_size = Vector2(0.0, 170.0)


func _style_character_panel() -> void:
	_style_panel_title(character_title)
	_style_panel_hint(character_hint)
	_style_rich_text_panel(character_body_label, Color(0.18, 0.2, 0.14, 0.82))
	character_body_label.custom_minimum_size = Vector2(0.0, 430.0)


func _style_team_panel() -> void:
	_style_panel_title(team_title)
	_style_panel_hint(team_hint)
	_style_rich_text_panel(team_body_label, Color(0.16, 0.18, 0.14, 0.82))
	team_grid.add_theme_constant_override("h_separation", 8)
	team_grid.add_theme_constant_override("v_separation", 8)
	team_body_label.custom_minimum_size = Vector2(0.0, 220.0)


func _style_settings_panel() -> void:
	_style_panel_title(settings_title)
	_style_panel_title(settings_scale_label, 13)
	_style_rich_text_panel(settings_body_label, Color(0.16, 0.18, 0.14, 0.82))
	for toggle in [borderless_toggle, always_on_top_toggle, click_through_toggle]:
		_style_toggle(toggle)
	_style_option_button(scale_preset_button)


func _style_panel_title(label: Label, font_size: int = 15) -> void:
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", PANEL_TEXT_COLOR)


func _style_panel_hint(label: Label) -> void:
	label.add_theme_color_override("font_color", PANEL_MUTED_TEXT_COLOR)


func _style_rich_text_panel(label: RichTextLabel, background_color: Color) -> void:
	label.add_theme_color_override("default_color", PANEL_TEXT_COLOR)
	label.add_theme_stylebox_override("normal", _filled_stylebox(background_color, Color(0.12, 0.1, 0.06, 0.72), 6))


func _style_toggle(toggle: CheckButton) -> void:
	toggle.add_theme_color_override("font_color", PANEL_TEXT_COLOR)
	toggle.add_theme_color_override("font_hover_color", PANEL_TEXT_COLOR)
	toggle.add_theme_color_override("font_pressed_color", PANEL_TEXT_COLOR)


func _style_option_button(button: OptionButton) -> void:
	button.add_theme_color_override("font_color", PANEL_TEXT_COLOR)
	button.add_theme_color_override("font_hover_color", PANEL_TEXT_COLOR)
	button.add_theme_stylebox_override("normal", _filled_stylebox(Color(0.9, 0.84, 0.62, 0.86), Color(0.24, 0.18, 0.1, 0.78), 4))
	button.add_theme_stylebox_override("hover", _filled_stylebox(Color(0.94, 0.9, 0.7, 0.94), Color(0.24, 0.18, 0.1, 0.9), 4))
	button.add_theme_stylebox_override("pressed", _filled_stylebox(Color(0.84, 0.78, 0.56, 0.98), Color(0.18, 0.14, 0.08, 1.0), 4))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _style_quick_button(button: Button) -> void:
	button.flat = false
	button.custom_minimum_size = Vector2(104.0, 24.0)
	button.add_theme_color_override("font_color", Color(0.06, 0.11, 0.08, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.1, 0.2, 0.12, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.12, 0.24, 0.14, 1.0))
	button.add_theme_stylebox_override("normal", _filled_stylebox(BUTTON_FILL_COLOR, Color(0.16, 0.22, 0.12, 0.94), 6))
	button.add_theme_stylebox_override("hover", _filled_stylebox(BUTTON_HOVER_COLOR, Color(0.18, 0.28, 0.14, 1.0), 6))
	button.add_theme_stylebox_override("pressed", _filled_stylebox(BUTTON_PRESSED_COLOR, Color(0.12, 0.18, 0.1, 1.0), 6))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _style_roster_button(button: Button, minimum_size: Vector2) -> void:
	if button == null:
		return
	button.flat = false
	button.custom_minimum_size = minimum_size
	button.add_theme_color_override("font_color", Color(0.08, 0.1, 0.08, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.06, 0.08, 0.06, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.1, 0.14, 0.1, 1.0))
	button.add_theme_stylebox_override("normal", _filled_stylebox(Color(0.92, 0.84, 0.6, 0.82), Color(0.28, 0.2, 0.1, 0.74), 5))
	button.add_theme_stylebox_override("hover", _filled_stylebox(Color(0.96, 0.9, 0.7, 0.9), Color(0.32, 0.24, 0.12, 0.86), 5))
	button.add_theme_stylebox_override("pressed", _filled_stylebox(Color(0.82, 0.74, 0.52, 0.96), Color(0.18, 0.14, 0.08, 1.0), 5))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _style_slot_button(button: Button) -> void:
	if button == null:
		return
	button.add_theme_color_override("font_color", Color(0.14, 0.16, 0.14, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.3, 0.34, 0.32, 0.82))
	button.add_theme_stylebox_override("normal", _filled_stylebox(Color(0.9, 0.84, 0.64, 0.72), Color(0.28, 0.22, 0.1, 0.68), 6))
	button.add_theme_stylebox_override("hover", _filled_stylebox(Color(0.94, 0.9, 0.72, 0.88), Color(0.32, 0.26, 0.12, 0.82), 6))
	button.add_theme_stylebox_override("pressed", _filled_stylebox(Color(0.76, 0.88, 0.68, 0.94), Color(0.2, 0.26, 0.14, 0.92), 6))
	button.add_theme_stylebox_override("disabled", _filled_stylebox(Color(0.78, 0.78, 0.78, 0.38), Color(0.24, 0.24, 0.24, 0.42), 6))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _filled_stylebox(fill_color: Color, border_color: Color, corner_radius: int) -> StyleBoxFlat:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = fill_color
	stylebox.border_color = border_color
	stylebox.set_border_width_all(2)
	stylebox.set_corner_radius_all(corner_radius)
	stylebox.content_margin_left = 10.0
	stylebox.content_margin_top = 8.0
	stylebox.content_margin_right = 10.0
	stylebox.content_margin_bottom = 8.0
	return stylebox
