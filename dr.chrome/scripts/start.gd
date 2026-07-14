extends Node2D

@onready var play_button: Button = $Play

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	GameState.current_patient = 1
	GameState.patient_changed.emit(1)

	visible = false
