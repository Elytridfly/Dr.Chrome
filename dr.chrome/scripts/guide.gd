extends Sprite2D

@export var hover_offset: Vector2 = Vector2(-10, 0)
@export var open_offset: Vector2 = Vector2(300, 0)
@export var slide_duration: float = 0.25

@onready var toggle_area: Area2D = $Toggle

var base_position: Vector2
var is_open := false
var is_hovering := false
var tween: Tween

func _ready() -> void:
	base_position = position
	toggle_area.mouse_entered.connect(_on_mouse_entered)
	toggle_area.mouse_exited.connect(_on_mouse_exited)
	toggle_area.input_event.connect(_on_toggle_input_event)

func _on_mouse_entered() -> void:
	is_hovering = true
	if not is_open:
		_slide_to(base_position + hover_offset)

func _on_mouse_exited() -> void:
	is_hovering = false
	if not is_open:
		_slide_to(base_position)

func _on_toggle_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_open = not is_open
		if is_open:
			_slide_to(base_position + open_offset)
		else:
			_slide_to(base_position + (hover_offset if is_hovering else Vector2.ZERO))
		get_viewport().set_input_as_handled()

func _slide_to(target: Vector2) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target, slide_duration)
