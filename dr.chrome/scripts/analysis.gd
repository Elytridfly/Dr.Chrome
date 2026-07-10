extends Sprite2D

func _ready() -> void:
	visible = GameState.analysis
	GameState.analysis_changed.connect(func(v): visible = v)
