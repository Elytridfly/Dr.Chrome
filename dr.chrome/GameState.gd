extends Node

signal blood_changed(value: bool)
signal analysis_changed(value: bool)
signal report_changed(value: bool)
signal patient_changed(new_patient: int)

var ui_blocking_input: bool = false
var blood: bool = false
var analysis: bool = false
var report: bool = false
var have_sex := false

var current_patient: int = 0

var pending_report_patient: int = -1

var patient_scores: Array[int] = [0,0,0]

var karyotype_state := {}
var active_interactable: Node = null
var selected_chromosome: Node = null

enum Sex{MALE, FEMALE}

var patient_sex: int = Sex.MALE

func advance_patient() -> void:
	current_patient += 1
	karyotype_state.clear()
	pending_report_patient = -1
	patient_changed.emit(current_patient)
	

func get_current_patient_is_male() -> bool:
	match current_patient:
		1: return Patient1Data.CORRECT_SEX
		2: return Patient2Data.CORRECT_SEX
		_: return true


func determine_sex() -> void:
	if have_sex:
		return
	patient_sex = Sex.MALE if randi() % 2 == 0 else Sex.FEMALE
	have_sex = true
	return

func pick_up_item() -> void:
	if blood:
		return
	blood = true
	blood_changed.emit(true)

func analyze_blood() -> void:
	if not blood or analysis:
		return
	blood = false
	blood_changed.emit(false)
	analysis = true
	analysis_changed.emit(true)

func report_ready() -> void:
	if not analysis or report:
		return
	analysis = false
	analysis_changed.emit(false)
	report = true
	report_changed.emit(true)
	
	
func complete_treatment() -> void:
	if not report:
		return
	report = false
	report_changed.emit(false)
