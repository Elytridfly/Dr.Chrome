extends Control


@export var spritesheet: Texture2D
@export var chromosome_script: Script
@export var source_chrom_size := Vector2(32,32)
@export var grid_colums:= 23
@export var grid_rows := 2
@export var piece_display_size := Vector2(24,24)

func _ready() -> void:
	if GameState.karyotype_generated:
		_rebuild_from_saved_layout()
	else:
		_generate_new_layout()
		GameState.karyotype_generated = true

func _generate_new_layout() -> void:
	
