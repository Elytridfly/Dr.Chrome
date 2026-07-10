extends Sprite2D

func _ready() -> void:
	visible = GameState.blood
	GameState.blood_changed.connect(func(v): visible = v)
