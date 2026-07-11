extends Control

func _ready():
	$AnimationPlayer.play("RESET")
	$PanelContainer.visible = false
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not GameState.ui_blocking_input:
		if get_tree().paused:
			resume()
		else:
			pause()

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	await $AnimationPlayer.animation_finished
	$PanelContainer.visible = false

func pause():
	get_tree().paused = true
	$PanelContainer.visible = true
	$AnimationPlayer.play("blur")

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
