extends Interactable

@onready var sprite: Sprite2D = $Sprite2D
@export var default_texture: Texture2D
@export var touched_texture: Texture2D
@export var ui_scene: PackedScene

var ui_instance: Control = null

func _ready() -> void:
	super._ready()
	interacted.connect(_on_interacted)

func _on_player_entered() -> void:
	sprite.texture = touched_texture

func _on_player_exited() -> void:
	sprite.texture = default_texture

func _on_interacted() -> void:
	if ui_instance != null:
		_close_ui()
	else:
		_open_ui()

func _open_ui() -> void:
	ui_instance = ui_scene.instantiate()
	get_tree().current_scene.add_child(ui_instance)
	GameState.ui_blocking_input = true
	GameState.active_interactable = self
	

func _close_ui() -> void:
	ui_instance.queue_free()
	ui_instance = null
	GameState.ui_blocking_input = false
	GameState.active_interactable = null


func _unhandled_input(event: InputEvent) -> void:
	super._unhandled_input(event)
	if ui_instance != null and event.is_action_pressed("ui_cancel"):
		_close_ui()
		get_viewport().set_input_as_handled()
