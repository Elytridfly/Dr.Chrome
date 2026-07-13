# clipboard.gd
extends Sprite2D

@onready var is_male: CheckBox = $isMale
@onready var is_female: CheckBox = $isFemale
@onready var toggle_area: Area2D = $Toggle
@onready var submit_button: Button = $submit
@onready var date_value: Label = $dateValue
@onready var patient_sprite: AnimatedSprite2D = $patientSprite
@onready var count_value: LineEdit = $countValue
@onready var abnormality_id: LineEdit = $abnormalityId

@export var hover_offset: Vector2 = Vector2(10, 0)   
@export var open_offset: Vector2 = Vector2(-300, 0)  
@export var slide_duration: float = 0.25

var base_position: Vector2
var is_open := false
var is_hovering := false
var tween: Tween

func _ready() -> void:
	base_position = position
	toggle_area.mouse_entered.connect(_on_mouse_entered)
	toggle_area.mouse_exited.connect(_on_mouse_exited)
	toggle_area.input_event.connect(_on_toggle_input_event)
	submit_button.pressed.connect(_on_submit_pressed)
	_set_current_date()
	_setup_patient_sprite()
	call_deferred("move_to_front")

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

func get_selected_sex() -> int:
	if is_male.button_pressed:
		return GameState.Sex.MALE
	elif is_female.button_pressed:
		return GameState.Sex.FEMALE
	else:
		return -1

func _setup_patient_sprite() -> void:
	var patient_scene: PackedScene = load("res://scenes/patient%d.tscn" % GameState.current_patient)
	if patient_scene == null:
		push_warning("Clipboard: no patient scene found for patient %d" % GameState.current_patient)
		return
	var patient_instance := patient_scene.instantiate()
	var patient_anim: AnimatedSprite2D = patient_instance.get_node("AnimatedSprite2D")
	if patient_anim == null:
		push_warning("Clipboard: Patient scene has no AnimatedSprite2D at that path.")
		patient_instance.free()
		return
	patient_sprite.sprite_frames = patient_anim.sprite_frames
	patient_sprite.play("idle0")
	patient_instance.free()

func _on_submit_pressed() -> void:
	var patient_data = _get_patient_data(GameState.current_patient)
	if patient_data == null:
		push_warning("Clipboard: no patient data class for patient %d" % GameState.current_patient)
		return
	patient_data.answerSex = is_male.button_pressed
	patient_data.answerCount = int(count_value.text)
	patient_data.answerAbnormality = int(abnormality_id.text)
	var result :int = patient_data.score()
	print("Score for patient %d: %d/3" % [GameState.current_patient, result])  # TODO: do something with result besides print
	GameState.report_ready()
	if GameState.active_interactable:
		GameState.active_interactable._close_ui()

func _get_patient_data(patient_num: int):
	match patient_num:
		1: return Patient1Data.new()
		#2: return Patient2Data.new()  # TODO: create once you've built this file
		#3: return Patient3Data.new()  # TODO: create once you've built this file
		_: return null

func _set_current_date() -> void:
	var d := Time.get_date_dict_from_system()
	date_value.text = "%02d/%02d/%04d" % [d.day, d.month, d.year]
