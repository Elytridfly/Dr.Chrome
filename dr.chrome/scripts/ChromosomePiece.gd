extends TextureRect

var dragging := false
var drag_offset:= Vector2.ZERO
const ROTATE_STEP := deg_to_rad(15)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_offset = global_position - get_global_mouse_position()
			else:
				dragging = false
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			rotation -= ROTATE_STEP
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			rotation += ROTATE_STEP

func _process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() + drag_offset
