extends Sprite2D
@onready var is_male: CheckBox = $isMale
@onready var is_female: CheckBox = $isFemale
@onready var toggle_area: Area2D = $Toggle
@onready var submit_button: Button = $submit
@onready var date_value: Label = $dateValue
@onready var patient_sprite: AnimatedSprite2D = $patientSprite
@onready var count_value: LineEdit = $countValue
@onready var abnormality_id: LineEdit = $abnormalityId
@onready var reports: Array[Sprite2D] = [$report1, $report2, $report3]
@export var hover_offset: Vector2 = Vector2(10, 0)
@export var open_offset: Vector2 = Vector2(-300, 0)
@export var slide_duration: float = 0.25
@export var report_slide_distance: float = 500.0   # TODO: tune — must clear the checklist fully off-screen below
var base_position: Vector2
var report_base_positions: Array[Vector2] = []
var is_open := false
var is_hovering := false
var tween: Tween
var report_tween: Tween

func _ready() -> void:
	base_position = position
	for r in reports:
		report_base_positions.append(r.position)
	toggle_area.mouse_entered.connect(_on_mouse_entered)
	toggle_area.mouse_exited.connect(_on_mouse_exited)
	toggle_area.input_event.connect(_on_toggle_input_event)
	submit_button.pressed.connect(_on_submit_pressed)
	GameState.patient_changed.connect(_on_patient_changed)
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
			if GameState.pending_report_patient == GameState.current_patient:
				_show_report(GameState.current_patient, false)  # reopening — snap, don't re-slide
			else:
				_refresh_for_current_patient()
		else:
			_slide_to(base_position + (hover_offset if is_hovering else Vector2.ZERO))
		get_viewport().set_input_as_handled()

func _refresh_for_current_patient() -> void:
	for r in reports:
		r.visible = false
	_set_current_date()
	_setup_patient_sprite()
	is_male.button_pressed = false
	is_female.button_pressed = false
	count_value.text = ""
	abnormality_id.text = ""

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
	var patient_num : int = GameState.current_patient
	var patient_data = _get_patient_data(patient_num)
	if patient_data == null:
		push_warning("Clipboard: no patient data class for patient %d" % patient_num)
		return
	patient_data.answerSex = is_male.button_pressed
	patient_data.answerCount = int(count_value.text)
	patient_data.answerAbnormality = int(abnormality_id.text)
	var result: int = patient_data.score()
	GameState.patient_scores[patient_num - 1] = result
	GameState.report_ready()
	GameState.pending_report_patient = patient_num
	_show_report(patient_num, true)

func _show_report(patient_num: int, animate: bool) -> void:
	for i in reports.size():
		reports[i].visible = (i == patient_num - 1)
	var report_node := reports[patient_num - 1]
	var rest_pos := report_base_positions[patient_num - 1]
	if not animate:
		report_node.position = rest_pos
		return
	report_node.position = rest_pos + Vector2(0, report_slide_distance)
	if report_tween:
		report_tween.kill()
	report_tween = create_tween()
	report_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	report_tween.tween_property(report_node, "position", rest_pos, slide_duration)

func _on_patient_changed(_new_patient: int) -> void:
	for r in reports:
		r.visible = false

func _get_patient_data(patient_num: int):
	match patient_num:
		1: return Patient1Data.new()
		2: return Patient2Data.new()
		3: return Patient3Data.new()
		_: return null

func _set_current_date() -> void:
	var d := Time.get_date_dict_from_system()
	date_value.text = "%02d/%02d/%04d" % [d.day, d.month, d.year]
