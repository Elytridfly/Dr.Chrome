extends Area2D

@export var chromosome_id : String = "1"
@export var homolog : int = 1
var dragging := false
var drag_offset := Vector2.ZERO
const ROTATE_STEP := deg_to_rad(15)

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("chromosome")
	var tex: Texture2D = load("res://assets/Chromosomes/%s.tres" % chromosome_id)
	sprite.texture = tex

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = global_position - get_global_mouse_position()
				get_viewport().set_input_as_handled()
			else:
				dragging = false
		elif dragging and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			rotation -= ROTATE_STEP
		elif dragging and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			rotation += ROTATE_STEP

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position() + drag_offset
