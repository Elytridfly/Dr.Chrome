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
		return
	ui_instance = ui_scene.instantiate()
	get_tree().current_scene.add_child(ui_instance)
	ui_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	GameState.ui_blocking_input = true

func _unhandled_input(event: InputEvent) -> void:
	super._unhandled_input(event)
	if ui_instance != null and event.is_action_pressed("ui_cancel"):
		_close_ui()
		get_viewport().set_input_as_handled()

func _close_ui() -> void:
	ui_instance.queue_free()
	ui_instance = null
	get_tree().paused = false
	GameState.ui_blocking_input = false
	GameState.report_ready()
