extends Area2D

@export var chromosome_id : String = "1"
@export var homolog : int = 1
var dragging := false
var drag_offset := Vector2.ZERO
const ROTATE_STEP := deg_to_rad(15)

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
var state_key: String

func _ready() -> void:
	add_to_group("chromosome")
	state_key = "%s_%d" % [chromosome_id, homolog]

	var tex: Texture2D = load("res://assets/Chromosomes/%s.tres" % chromosome_id)
	sprite.texture = tex

	var new_shape := RectangleShape2D.new()
	new_shape.size = tex.get_size()
	collision.shape = new_shape

	input_event.connect(_on_input_event)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = global_position - get_global_mouse_position()
				get_viewport().set_input_as_handled()
			else:
				dragging = false
				_save_state()
		elif dragging and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			rotation -= ROTATE_STEP
			_save_state()
		elif dragging and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			rotation += ROTATE_STEP
			_save_state()

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position() + drag_offset

func _save_state() -> void:
	GameState.karyotype_state[state_key] = {
		"position": global_position,
		"rotation": rotation
	}
