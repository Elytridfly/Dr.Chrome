extends Sprite2D

func _ready() -> void:
	visible = GameState.report
	GameState.report_changed.connect(func(v): visible = v)
