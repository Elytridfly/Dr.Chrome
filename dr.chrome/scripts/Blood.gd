extends Sprite2D

func _ready() -> void:
	visible = GameState.blood
	GameState.item_picked_up.connect(func(): visible = true)
