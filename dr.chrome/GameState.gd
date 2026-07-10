extends Node

signal blood_changed(value: bool)
signal analysis_changed(value: bool)
signal report_changed(value: bool)

var ui_blocking_input: bool = false
var blood: bool = false
var analysis: bool = false
var report: bool = false

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
