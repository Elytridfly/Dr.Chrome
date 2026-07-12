extends Sprite2D

@onready var is_male: CheckBox = $isMale
@onready var is_female: CheckBox = $isFemale

func get_selected_sex() -> int:
	if is_male.button_pressed:
		return GameState.Sex.MALE
	elif is_female.button_pressed:
		return GameState.Sex.FEMALE
	else:
		return -1  
