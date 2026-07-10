extends Interactable

@onready var sprite: Sprite2D = $Sprite2D
@export var default_texture: Texture2D
@export var touched_texture: Texture2D

func _on_player_entered() -> void:
	sprite.texture = touched_texture

func _on_player_exited() -> void:
	sprite.texture = default_texture
