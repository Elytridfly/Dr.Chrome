extends Sprite2D

@onready var restart_button: Button = $restart
@onready var quit_button: Button = $quit

var stars: Array[AnimatedSprite2D] = []

const HIDDEN_POS := Vector2(-100, 900)
const SHOWN_POS := Vector2(-100, -75)

func _ready():
	position = HIDDEN_POS
	visible = false

	for i in range(1, 13):
		stars.append(get_node("star%d" % i))

	for star in stars:
		star.play("default")

	restart_button.pressed.connect(_restart)
	quit_button.pressed.connect(_quit)


func show_summary():
	visible = true

	position = HIDDEN_POS

	for star in stars:
		star.play("default")

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", SHOWN_POS, 0.8)

	await tween.finished

	_award_stars()


func _award_stars():
	var tween = create_tween()

	for patient in range(3):
		var score = GameState.patient_scores[patient]

		for i in range(score):
			tween.tween_callback(
				stars[patient * 3 + i].play.bind("earned")
			)
			tween.tween_interval(0.15)

		if score == 3:
			tween.tween_callback(
				stars[9 + patient].play.bind("earned")
			)
			tween.tween_interval(0.25)


func _restart():

	GameState.ui_blocking_input = false
	GameState.blood = false
	GameState.analysis = false
	GameState.report = false
	GameState.have_sex = false

	GameState.current_patient = 1
	GameState.pending_report_patient = -1
	GameState.patient_scores = [0, 0, 0]

	GameState.karyotype_state.clear()
	GameState.active_interactable = null
	GameState.selected_chromosome = null

	GameState.patient_sex = GameState.Sex.MALE

	GameState.blood_changed.emit(false)
	GameState.analysis_changed.emit(false)
	GameState.report_changed.emit(false)
	GameState.patient_changed.emit(0)

	get_tree().reload_current_scene()


func _quit():
	get_tree().quit()
