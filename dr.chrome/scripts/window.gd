extends Sprite2D

const PIECE_SCENE : PackedScene = preload("res://scenes/Chromosome.tscn")
const PIECE_SCALE := 0.25
var spawn_size := Vector2(300, 400)

func _ready():
	get_viewport().physics_object_picking = true
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
	var sample_tex: Texture2D = load("res://assets/Chromosomes/1.tres")
	var piece_size: Vector2 = sample_tex.get_size() * PIECE_SCALE
	var inset_rect = Rect2(rect.position + piece_size / 2, rect.size - piece_size)

	for i in range(1, 23):
		_spawn_piece(str(i), 1, inset_rect)
		_spawn_piece(str(i), 2, inset_rect)
	_spawn_piece("X", 1, inset_rect)
	if GameState.patient_sex == GameState.Sex.MALE:
		_spawn_piece("Y", 1, inset_rect)
	else:
		_spawn_piece("X", 2, inset_rect)

func _spawn_piece(id: String, homolog: int, rect: Rect2) -> void:
	var piece = PIECE_SCENE.instantiate()
	piece.chromosome_id = id
	piece.homolog = homolog
	piece.scale = Vector2(PIECE_SCALE, PIECE_SCALE)
	piece.process_mode = Node.PROCESS_MODE_ALWAYS

	var key = "%s_%d" % [id, homolog]
	var target_pos: Vector2
	var target_rot: float

	if GameState.karyotype_state.has(key):
		var saved = GameState.karyotype_state[key]
		target_pos = saved["position"]
		target_rot = saved["rotation"]
	else:
		target_pos = Vector2(
			randf_range(rect.position.x, rect.position.x + rect.size.x),
			randf_range(rect.position.y, rect.position.y + rect.size.y)
		)
		target_rot = randf_range(0, TAU)
		GameState.karyotype_state[key] = {"position": target_pos, "rotation": target_rot}

	get_parent().add_child.call_deferred(piece)
	piece.ready.connect(func():
		piece.global_position = target_pos
		piece.rotation = target_rot
	, CONNECT_ONE_SHOT)
