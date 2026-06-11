extends Node

class_name ProgressionManager

signal progression_changed


func grant_exp(_amount: int) -> void:
	progression_changed.emit()
