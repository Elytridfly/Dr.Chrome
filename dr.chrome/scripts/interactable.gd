# Interactable.gd
class_name Interactable
extends Area2D

signal interacted

@export var interact_action: String = "interact"
var player_in_range := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		_on_player_entered() # override hook, e.g. show prompt icon

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		_on_player_exited()

func _unhandled_input(event: InputEvent) -> void:
	if GameState.ui_blocking_input and GameState.active_interactable != self:
		return
	if player_in_range and event.is_action_pressed(interact_action):
		interacted.emit()
		get_viewport().set_input_as_handled()

func _on_player_entered() -> void: pass
func _on_player_exited() -> void: pass
