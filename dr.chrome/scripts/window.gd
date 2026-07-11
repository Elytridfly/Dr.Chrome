extends Sprite2D

const PIECE_SCENE := preload("res://scenes/chromosome.tscn")
var spawn_size := Vector2(300, 400)

func _ready():
	randomize()
	if not GameState.have_sex:
		GameState.determine_sex()
	setup_chromosomes()

func get_spawn_rect() -> Rect2:
	var size := spawn_size
	if self.texture:
		size = self.texture.get_size() * self.scale
	var top_left = self.global_position - size / 2
	return Rect2(top_left, size)

func setup_chromosomes():
	var rect = get_spawn_rect()

	for i in range(1, 23):
		_spawn_piece(str(i), 1, rect)
		_spawn_piece(str(i), 2, rect)

	_spawn_piece("X", 1, rect)

	if GameState.patient_sex == GameState.Sex.MALE:
		_spawn_piece("Y", 1, rect)
	else:
		_spawn_piece("X", 2, rect)

func _spawn_piece(id: String, homolog: int, rect: Rect2) -> void:
	var piece = PIECE_SCENE.instantiate()
	piece.chromosome_id = id
	piece.homolog = homolog

	var target_pos = Vector2(
		randf_range(rect.position.x, rect.position.x + rect.size.x),
		randf_range(rect.position.y, rect.position.y + rect.size.y)
	)
	var target_rot = randf_range(0, TAU)

	get_parent().add_child.call_deferred(piece)
	piece.ready.connect(func():
		piece.global_position = target_pos
		piece.rotation = target_rot
	, CONNECT_ONE_SHOT)
