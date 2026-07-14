extends Area2D

@onready var machine: Sprite2D = $machine
@onready var highlight: Sprite2D = $highlight

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	GameState.blood_changed.connect(_on_blood_changed)

	_on_blood_changed(GameState.blood)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.analyze_blood()

func _on_blood_changed(value: bool) -> void:
	machine.visible = !value
	highlight.visible = value
