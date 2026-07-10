extends Control

@export var chromosome_folder := "res://assets/Chromosomes/"
@export var chromosome_script: Script
@export var piece_display_size := Vector2(24, 24)
@export var bounds_sprite: Sprite2D

func _get_spawn_rect() -> Rect2:
	var tex_size: Vector2 = bounds_sprite.texture.get_size() * bounds_sprite.scale
	var top_left: Vector2 = bounds_sprite.position - tex_size / 2.0  # centered=true default
	return Rect2(top_left, tex_size)

func _ready() -> void:
	if not GameState.have_sex:
		GameState.determine_sex()
	if GameState.karyotype_generated:
		_rebuild_from_saved_layout()
	else:
		_generate_new_layout()
		GameState.karyotype_generated = true

func _generate_new_layout() -> void:
	for i in range(1, 23):
		var tex: Texture2D = load(chromosome_folder + "%d.tres" % i)
		_add_pair(tex)
	var x_tex: Texture2D = load(chromosome_folder + "X.tres")
	if GameState.patient_sex == GameState.Sex.MALE:
		var y_tex: Texture2D = load(chromosome_folder + "Y.tres")
		_add_single(x_tex, false)
		_add_single(y_tex, false)
	else:
		_add_pair(x_tex)

func _add_pair(tex: Texture2D) -> void:
	_add_single(tex, false)
	_add_single(tex, true)

func _add_single(tex: Texture2D, mirrored: bool) -> void:
	var rect := _get_spawn_rect()
	var pos := Vector2(
		rect.position.x + randf() * max(rect.size.x - piece_display_size.x, 0),
		rect.position.y + randf() * max(rect.size.y - piece_display_size.y, 0)
	)
	var entry := {"texture": tex, "position": pos, "rotation": 0.0, "flip_h": mirrored}
	GameState.karyotype_layout.append(entry)
	_spawn_piece(entry)

func _rebuild_from_saved_layout() -> void:
	for entry in GameState.karyotype_layout:
		_spawn_piece(entry)

func _spawn_piece(entry: Dictionary) -> void:
	var piece := TextureRect.new()
	piece.texture = entry["texture"]
	piece.flip_h = entry["flip_h"]
	piece.size = piece_display_size
	piece.pivot_offset = piece_display_size / 2
	piece.position = entry["position"]
	piece.rotation = entry["rotation"]
	piece.set_script(chromosome_script)
	add_child(piece)
