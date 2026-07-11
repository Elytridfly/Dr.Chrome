extends Sprite2D

var dragging = false
var current_tween: Tween

func _process(delta):
	if dragging:
		if current_tween:
			current_tween.kill()

		current_tween = create_tween()
		current_tween.tween_property(
			self,
			"global_position",
			get_global_mouse_position(),
			0.1
		)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print(to_local(event.position))
			print(get_rect())
			if get_rect().has_point(to_local(event.position)):
				dragging = !dragging

				if !dragging and current_tween:
					current_tween.kill()
