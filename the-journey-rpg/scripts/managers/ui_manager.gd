extends CanvasLayer

class_name UIManager

@onready var panel_stack: TabContainer = get_node("HUD/PanelHost/PanelStack")
@onready var inventory_button: Button = get_node("HUD/QuickButtons/InventoryButton")
@onready var character_button: Button = get_node("HUD/QuickButtons/CharacterButton")
@onready var team_button: Button = get_node("HUD/QuickButtons/TeamButton")
@onready var settings_button: Button = get_node("HUD/QuickButtons/SettingsButton")
@onready var top_bar_label: Label = get_node("HUD/TopBar/TopBarLabel")
@onready var loot_feed_label: Label = get_node("HUD/LootFeed/LootFeedLabel")


func _ready() -> void:
	inventory_button.pressed.connect(_open_inventory)
	character_button.pressed.connect(_open_character)
	team_button.pressed.connect(_open_team)
	settings_button.pressed.connect(_open_settings)
	var battle_root := get_parent().get_node_or_null("BattleRoot")
	if battle_root != null and battle_root.has_signal("battle_status_changed"):
		battle_root.battle_status_changed.connect(_update_status)
	if battle_root != null and battle_root.has_signal("battle_event_changed"):
		battle_root.battle_event_changed.connect(_update_event)


func _open_inventory() -> void:
	panel_stack.current_tab = 0


func _open_character() -> void:
	panel_stack.current_tab = 1


func _open_team() -> void:
	panel_stack.current_tab = 2


func _open_settings() -> void:
	panel_stack.current_tab = 3


func _update_status(status_text: String) -> void:
	top_bar_label.text = status_text


func _update_event(event_text: String) -> void:
	loot_feed_label.text = event_text
