extends Node2D

class_name BattleManager

signal battle_bootstrapped


func _ready() -> void:
	battle_bootstrapped.emit()
