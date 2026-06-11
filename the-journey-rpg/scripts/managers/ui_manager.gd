extends CanvasLayer

class_name UIManager

@onready var panel_stack: TabContainer = get_node("HUD/PanelHost/PanelStack")
@onready var inventory_button: Button = get_node("HUD/QuickButtons/InventoryButton")
@onready var character_button: Button = get_node("HUD/QuickButtons/CharacterButton")
@onready var team_button: Button = get_node("HUD/QuickButtons/TeamButton")
@onready var settings_button: Button = get_node("HUD/QuickButtons/SettingsButton")
@onready var top_bar_label: Label = get_node("HUD/TopBar/TopBarLabel")
@onready var loot_feed_label: Label = get_node("HUD/LootFeed/LootFeedLabel")
@onready var inventory_item_list: ItemList = get_node("HUD/PanelHost/PanelStack/InventoryPanel/ItemList")
@onready var inventory_body_label: RichTextLabel = get_node("HUD/PanelHost/PanelStack/InventoryPanel/Body")
@onready var character_body_label: RichTextLabel = get_node("HUD/PanelHost/PanelStack/CharacterPanel/Body")
@onready var team_body_label: RichTextLabel = get_node("HUD/PanelHost/PanelStack/TeamPanel/Body")

var loot_manager: LootManager
var progression_manager: ProgressionManager
var last_battle_status: String = "Combat idle"
var progression_summary: Dictionary = {}
var equipment_summary_text: String = "Equipped Weapon: None\nEquipped Accessory: None\nBonus HP: +0\nBonus Attack: +0"


func _ready() -> void:
	inventory_button.pressed.connect(_open_inventory)
	character_button.pressed.connect(_open_character)
	team_button.pressed.connect(_open_team)
	settings_button.pressed.connect(_open_settings)
	inventory_item_list.item_selected.connect(_equip_inventory_item)
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
	loot_feed_label.text = event_text


func _update_inventory(inventory_text: String, inventory_entries: Array) -> void:
	inventory_body_label.text = inventory_text
	inventory_item_list.clear()

	for entry in inventory_entries:
		var item_index := inventory_item_list.add_item(entry["label"])
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
