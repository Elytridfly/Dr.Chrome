extends Control
@onready var clipboard1: Sprite2D = $Clipboard
@onready var clipboard2: Sprite2D = $Clipboard2
@onready var guide: Sprite2D = $Guide
@onready var window: Sprite2D = $window

func _ready() -> void:
	GameState.patient_changed.connect(_on_patient_changed)
	_refresh_clipboard_visibility()

func _on_patient_changed(_new_patient: int) -> void:
	_refresh_clipboard_visibility()

func _refresh_clipboard_visibility() -> void:
	var use_clipboard2 := GameState.current_patient >= 3
	clipboard1.visible = not use_clipboard2
	window.visible = not use_clipboard2
	clipboard2.visible = use_clipboard2
	if use_clipboard2:
		clipboard2.move_to_front()
		guide.move_to_front()
