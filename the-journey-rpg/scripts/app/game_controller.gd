extends Node

class_name GameController

const SessionStateScript := preload("res://scripts/state/session_state.gd")

var session_state: SessionState


func _ready() -> void:
	session_state = SessionStateScript.new()
	session_state.bootstrap_defaults()
