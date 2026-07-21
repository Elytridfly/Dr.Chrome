extends Sprite2D
@onready var boxes: Array[CheckBox] = [$"1", $"2", $"3", $"4", $"5", $"6"]
@onready var submit_button: Button = $submit
const CORRECT: Array[bool] = [false, true, true, false, true, false]

func _ready() -> void:
	submit_button.pressed.connect(_on_submit_pressed)




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
