extends Node2D

class_name BattleUnit

const VISUAL_PROFILES := {
	&"hero_adventurer": {
		"base_dir": "res://assets/sprites/imported/ranger-variant-3",
		"scale": Vector2(0.13, 0.13),
		"offset": Vector2(0.0, -8.0),
		"animations": {
			"idle": "Idle",
			"move": "Running",
			"attack": "Slashing",
			"hurt": "Hurt",
			"down": "Dying",
		},
	},
	&"hero_apprentice": {
		"base_dir": "res://assets/sprites/imported/ranger-variant-1",
		"scale": Vector2(0.13, 0.13),
		"offset": Vector2(0.0, -8.0),
		"animations": {
			"idle": "Idle",
			"move": "Running",
			"attack": "Shooting",
			"hurt": "Hurt",
			"down": "Dying",
		},
	},
	&"enemy_slime": {
		"base_dir": "res://assets/sprites/imported/skeleton",
		"scale": Vector2(0.12, 0.12),
		"offset": Vector2(0.0, -10.0),
		"animations": {
			"idle": "Idle",
			"move": "Running",
			"attack": "Slashing",
			"hurt": "Hurt",
			"down": "Dying",
		},
	},
	&"enemy_slime_king": {
		"base_dir": "res://assets/sprites/imported/dark-oracle",
		"scale": Vector2(0.15, 0.15),
		"offset": Vector2(0.0, -18.0),
		"animations": {
			"idle": "Idle",
			"move": "Running",
			"attack": "Throwing",
			"hurt": "Hurt",
			"down": "Dying",
		},
	},
}

static var sprite_frames_cache: Dictionary = {}

@onready var shadow: Polygon2D = $Shadow
@onready var aura: Polygon2D = $Aura
@onready var visual_sprite: AnimatedSprite2D = $VisualSprite
@onready var back_accent: Polygon2D = $BackAccent
@onready var body: Polygon2D = $Body
@onready var chest_accent: Polygon2D = $ChestAccent
@onready var weapon: Polygon2D = $Weapon
@onready var name_label: Label = $NameLabel
@onready var hp_bar_fill: ColorRect = $HpBarFill
@onready var hp_bar_background: ColorRect = $HpBarBackground
@onready var state_label: Label = $StateLabel

var unit_id: StringName
var team: StringName
var display_name: String = ""
var base_max_hp: int = 100
var base_attack: int = 10
var base_attack_speed: float = 1.0
var base_move_speed: float = 80.0
var base_attack_range: float = 48.0
var max_hp: int = 100
var current_hp: float = 100.0
var attack: int = 10
var attack_speed: float = 1.0
var move_speed: float = 80.0
var attack_range: float = 48.0
var attack_cooldown_remaining: float = 0.0
var alive: bool = true
var formation_slot_index: int = -1
var formation_row_index: int = 0
var formation_column_index: int = 1
var using_imported_visual: bool = false
var visual_locked: bool = false
var visual_loop_state: StringName = &"idle"


func _ready() -> void:
	visual_sprite.animation_finished.connect(_on_visual_animation_finished)
	visual_sprite.visible = false


func configure(config: Dictionary) -> void:
	unit_id = config.get("unit_id", &"")
	team = config.get("team", &"neutral")
	display_name = config.get("display_name", "Unit")
	base_max_hp = config.get("max_hp", 100)
	base_attack = config.get("attack", 10)
	base_attack_speed = max(config.get("attack_speed", 1.0), 0.1)
	base_move_speed = config.get("move_speed", 80.0)
	base_attack_range = config.get("attack_range", 48.0)
	max_hp = base_max_hp
	current_hp = max_hp
	attack = base_attack
	attack_speed = base_attack_speed
	move_speed = base_move_speed
	attack_range = base_attack_range

	if team == &"hero":
		_apply_hero_visuals()
	else:
		_apply_enemy_visuals()
	_apply_imported_visual_profile()

	name_label.text = display_name
	_update_hp_bar()
	set_state_text("Ready")
	play_idle_animation()


func is_alive() -> bool:
	return alive


func tick_cooldown(delta: float) -> void:
	attack_cooldown_remaining = max(attack_cooldown_remaining - delta, 0.0)


func can_attack() -> bool:
	return alive and attack_cooldown_remaining <= 0.0


func reset_attack_cooldown() -> void:
	attack_cooldown_remaining = 1.0 / attack_speed


func take_damage(amount: float) -> void:
	if not alive:
		return

	current_hp = max(current_hp - amount, 0.0)
	_update_hp_bar()

	if current_hp <= 0.0:
		alive = false
		set_state_text("Down")
		modulate = Color(0.6, 0.6, 0.6, 0.8)
		play_down_animation()
		return

	play_hurt_animation()


func revive() -> void:
	alive = true
	current_hp = max_hp
	attack_cooldown_remaining = 0.0
	modulate = Color.WHITE
	_update_hp_bar()
	set_state_text("Revived")
	play_idle_animation()


func set_state_text(value: String) -> void:
	state_label.text = value


func apply_stat_bonus(stat_bonus: Dictionary) -> void:
	var previous_max_hp: int = maxi(max_hp, 1)
	var hp_ratio: float = clampf(current_hp / float(previous_max_hp), 0.0, 1.0)

	max_hp = base_max_hp + int(stat_bonus.get("hp", 0))
	attack = base_attack + int(stat_bonus.get("attack", 0))
	attack_speed = base_attack_speed
	move_speed = base_move_speed
	attack_range = base_attack_range
	current_hp = max_hp * hp_ratio if alive else current_hp
	_update_hp_bar()
	set_state_text("Equipped")


func play_idle_animation() -> void:
	visual_loop_state = &"idle"
	_play_visual_animation(&"idle")


func play_move_animation() -> void:
	visual_loop_state = &"move"
	_play_visual_animation(&"move")


func play_attack_animation() -> void:
	_play_visual_animation(&"attack", true)


func play_hurt_animation() -> void:
	_play_visual_animation(&"hurt", true)


func play_down_animation() -> void:
	visual_loop_state = &"down"
	_play_visual_animation(&"down", true)


func _apply_hero_visuals() -> void:
	if unit_id == &"hero_apprentice":
		scale = Vector2(0.92, 0.92)
		body.color = Color(0.36, 0.58, 0.92, 1.0)
		back_accent.color = Color(0.15, 0.23, 0.34, 1.0)
		chest_accent.color = Color(0.9, 0.94, 1.0, 0.92)
		weapon.color = Color(0.78, 0.9, 1.0, 1.0)
		aura.color = Color(0.4, 0.7, 1.0, 0.16)
		hp_bar_fill.color = Color(0.42, 0.74, 1.0, 1.0)
		name_label.modulate = Color(0.9, 0.96, 1.0, 1.0)
		return

	scale = Vector2.ONE
	body.color = Color(0.36, 0.8, 0.55, 1.0)
	back_accent.color = Color(0.15, 0.26, 0.2, 1.0)
	chest_accent.color = Color(0.88, 0.98, 0.9, 0.9)
	weapon.color = Color(0.92, 0.84, 0.6, 1.0)
	aura.color = Color(0.35, 0.8, 0.58, 0.14)
	hp_bar_fill.color = Color(0.2, 0.85, 0.25, 1.0)
	name_label.modulate = Color(0.9, 1.0, 0.92, 1.0)


func _apply_enemy_visuals() -> void:
	scale = Vector2.ONE
	if unit_id == &"enemy_slime_king":
		body.color = Color(0.52, 0.2, 0.62, 1.0)
		back_accent.color = Color(0.24, 0.09, 0.28, 1.0)
		chest_accent.color = Color(0.9, 0.72, 1.0, 0.78)
		weapon.color = Color(0.9, 0.54, 0.94, 1.0)
		aura.color = Color(0.78, 0.38, 0.95, 0.2)
		hp_bar_fill.color = Color(0.98, 0.46, 0.82, 1.0)
		name_label.modulate = Color(1.0, 0.9, 1.0, 1.0)
		return
	if unit_id == &"enemy_needle_bat":
		scale = Vector2(0.84, 0.84)
		body.color = Color(0.54, 0.46, 0.9, 1.0)
		back_accent.color = Color(0.18, 0.14, 0.32, 1.0)
		chest_accent.color = Color(0.9, 0.88, 1.0, 0.86)
		weapon.color = Color(0.78, 0.7, 1.0, 1.0)
		aura.color = Color(0.56, 0.52, 1.0, 0.14)
		hp_bar_fill.color = Color(0.74, 0.62, 1.0, 1.0)
		name_label.modulate = Color(0.95, 0.93, 1.0, 1.0)
		return

	body.color = Color(0.86, 0.35, 0.36, 1.0)
	back_accent.color = Color(0.34, 0.12, 0.14, 1.0)
	chest_accent.color = Color(1.0, 0.84, 0.74, 0.82)
	weapon.color = Color(0.95, 0.62, 0.26, 1.0)
	aura.color = Color(0.9, 0.38, 0.32, 0.14)
	hp_bar_fill.color = Color(0.92, 0.48, 0.22, 1.0)
	name_label.modulate = Color(1.0, 0.93, 0.92, 1.0)


func _update_hp_bar() -> void:
	var ratio: float = 0.0 if max_hp <= 0 else current_hp / float(max_hp)
	hp_bar_fill.size.x = 56.0 * ratio
	hp_bar_fill.position.x = -34.0
	hp_bar_background.size.x = 68.0
	hp_bar_background.position.x = -34.0
	shadow.scale.x = 0.82 + (ratio * 0.2)


func _apply_imported_visual_profile() -> void:
	var profile: Dictionary = VISUAL_PROFILES.get(unit_id, {})
	if profile.is_empty():
		using_imported_visual = false
		_set_placeholder_visuals_visible(true)
		visual_sprite.visible = false
		return

	using_imported_visual = true
	visual_sprite.sprite_frames = _sprite_frames_for_profile(unit_id, profile)
	visual_sprite.position = profile.get("offset", Vector2.ZERO)
	visual_sprite.scale = profile.get("scale", Vector2.ONE)
	visual_sprite.visible = true
	_set_placeholder_visuals_visible(false)


func _set_placeholder_visuals_visible(is_visible: bool) -> void:
	back_accent.visible = is_visible
	body.visible = is_visible
	chest_accent.visible = is_visible
	weapon.visible = is_visible


func _play_visual_animation(animation_name: StringName, lock_until_finished: bool = false) -> void:
	if not using_imported_visual:
		return
	if visual_locked and not lock_until_finished:
		return
	if visual_sprite.sprite_frames == null:
		return
	if not visual_sprite.sprite_frames.has_animation(String(animation_name)):
		return
	if visual_sprite.animation == StringName(animation_name) and visual_sprite.is_playing() and not lock_until_finished:
		return

	visual_locked = lock_until_finished
	visual_sprite.play(StringName(animation_name))


func _on_visual_animation_finished() -> void:
	if not using_imported_visual:
		return
	if visual_sprite.animation == &"down":
		visual_sprite.stop()
		return
	visual_locked = false
	if visual_loop_state == &"move":
		_play_visual_animation(&"move")
	else:
		_play_visual_animation(&"idle")


func _sprite_frames_for_profile(profile_id: StringName, profile: Dictionary) -> SpriteFrames:
	if sprite_frames_cache.has(profile_id):
		return sprite_frames_cache[profile_id]

	var sprite_frames := SpriteFrames.new()
	var animation_map: Dictionary = profile.get("animations", {})
	for animation_name in animation_map.keys():
		var folder_name: String = str(animation_map[animation_name])
		var folder_path: String = "%s/%s" % [str(profile.get("base_dir", "")), folder_name]
		var frame_paths: PackedStringArray = _png_paths_in_dir(folder_path)
		if frame_paths.is_empty():
			continue

		sprite_frames.add_animation(String(animation_name))
		sprite_frames.set_animation_loop(String(animation_name), animation_name in [&"idle", &"move"])
		sprite_frames.set_animation_speed(String(animation_name), 12.0)
		for frame_path in frame_paths:
			var texture: Texture2D = load(frame_path) as Texture2D
			if texture != null:
				sprite_frames.add_frame(String(animation_name), texture)

	sprite_frames_cache[profile_id] = sprite_frames
	return sprite_frames


func _png_paths_in_dir(dir_path: String) -> PackedStringArray:
	var paths: PackedStringArray = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return paths

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.to_lower().ends_with(".png"):
			paths.append(dir_path.path_join(file_name))
		file_name = dir.get_next()
	dir.list_dir_end()
	paths.sort()
	return paths
