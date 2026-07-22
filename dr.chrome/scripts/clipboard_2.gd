extends Sprite2D
@onready var boxes: Array[CheckBox] = [$"1", $"2", $"3", $"4", $"5", $"6"]
@onready var submit_button: Button = $submit
@onready var report: Sprite2D = $Report3
@export var report_slide_distance: float = 500.0
var base_position: Vector2
var report_base_position: Vector2
var report_tween: Tween
const SLIDE_DURATION: float = 0.25
const CORRECT: Array[bool] = [false, true, true, false, true, false]

func _ready() -> void:
	base_position = position
	report_base_position = report.position
	report.visible = false
	submit_button.pressed.connect(_on_submit_pressed)

func _show_report(animate: bool) -> void:
	var report_node := report
	report_node.visible = true
	var rest_pos := report_base_position
	if not animate:
		report_node.position = rest_pos
		return
	report_node.position = rest_pos + Vector2(0, report_slide_distance)
	if report_tween:
		report_tween.kill()
	report_tween = create_tween()
	report_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	report_tween.tween_property(report_node, "position", rest_pos, SLIDE_DURATION)

func _on_submit_pressed() -> void:
	var points := 0
	if boxes[0].button_pressed == CORRECT[0] \
	and boxes[1].button_pressed == CORRECT[1]:
		points += 1
	if boxes[2].button_pressed == CORRECT[2] \
	and boxes[3].button_pressed == CORRECT[3]:
		points += 1
	if boxes[4].button_pressed == CORRECT[4] \
	and boxes[5].button_pressed == CORRECT[5]:
		points += 1
	GameState.patient_scores[2] = points
	GameState.report_ready()
	GameState.pending_report_patient = 3
	_show_report(true)
