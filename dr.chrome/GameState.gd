# autoload: GameState.gd
extends Node
signal item_picked_up


var ui_blocking_input: bool = false
var blood: bool = false


func pick_up_item() -> void:
	if blood:
		return
	blood = true
	item_picked_up.emit()
