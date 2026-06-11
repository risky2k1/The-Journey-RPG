extends CanvasLayer

class_name UIManager

@onready var panel_stack: TabContainer = get_node("HUD/PanelHost/PanelStack")
@onready var inventory_button: Button = get_node("HUD/QuickButtons/InventoryButton")
@onready var character_button: Button = get_node("HUD/QuickButtons/CharacterButton")
@onready var team_button: Button = get_node("HUD/QuickButtons/TeamButton")
@onready var settings_button: Button = get_node("HUD/QuickButtons/SettingsButton")


func _ready() -> void:
	inventory_button.pressed.connect(_open_inventory)
	character_button.pressed.connect(_open_character)
	team_button.pressed.connect(_open_team)
	settings_button.pressed.connect(_open_settings)


func _open_inventory() -> void:
	panel_stack.current_tab = 0


func _open_character() -> void:
	panel_stack.current_tab = 1


func _open_team() -> void:
	panel_stack.current_tab = 2


func _open_settings() -> void:
	panel_stack.current_tab = 3
