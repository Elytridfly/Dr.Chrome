extends Sprite2D
@export var guide_node: NodePath
const PIECE_SCENE : PackedScene = preload("res://scenes/Chromosome.tscn")
const PIECE_SCALE := 0.25
var spawn_size := Vector2(300, 400)
var spawned_pieces: Array = []

func _ready():
	get_viewport().physics_object_picking = true
	randomize()
	GameState.patient_changed.connect(_on_patient_changed)
	setup_chromosomes()
	_shuffle_chromosomes()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sort"):
		_sort_chromosomes()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("shuffle"):
		_shuffle_chromosomes()
		get_viewport().set_input_as_handled()

func _on_patient_changed(_new_patient: int) -> void:
	for piece in spawned_pieces:
		if is_instance_valid(piece):
			var parent = piece.get_parent()
			if parent:
				parent.remove_child(piece)
			piece.free()
	spawned_pieces.clear()
	setup_chromosomes()

func _shuffle_chromosomes() -> void:
	var rect = get_spawn_rect()
	var sample_tex: Texture2D = load("res://assets/Chromosomes/1.tres")
	var piece_size: Vector2 = sample_tex.get_size() * PIECE_SCALE
	var inset_rect = Rect2(rect.position + piece_size / 2, rect.size - piece_size)

	for piece in spawned_pieces:
		if not is_instance_valid(piece):
			continue
		var target_pos := Vector2(
			randf_range(inset_rect.position.x, inset_rect.position.x + inset_rect.size.x),
			randf_range(inset_rect.position.y, inset_rect.position.y + inset_rect.size.y)
		)
		var target_rot := randf_range(0, TAU)
		piece.global_position = target_pos
		piece.rotation = target_rot
		var key = "%s_%d" % [piece.chromosome_id, piece.homolog]
		GameState.karyotype_state[key] = {
			"position": target_pos,
			"rotation": target_rot,
			"normalized": _normalize(target_pos, rect)
		}


func get_spawn_rect() -> Rect2:
	var size := spawn_size
	if self.texture:
		size = self.texture.get_size() * self.scale
	var top_left = self.global_position - size / 2
	return Rect2(Vector2(-75,-75), size - Vector2(75,75))

func setup_chromosomes(force_random: bool = false):
	spawned_pieces.clear()
	var rect = get_spawn_rect()
	var sample_tex: Texture2D = load("res://assets/Chromosomes/1.tres")
	var piece_size: Vector2 = sample_tex.get_size() * PIECE_SCALE
	var inset_rect = Rect2(rect.position + piece_size / 2, rect.size - piece_size)

	for i in range(1, 23):
		var id := str(i)
		if i == 8 and GameState.current_patient == 3:
			_spawn_piece(id, 1, inset_rect, force_random)
			_spawn_piece("8-error", 2, inset_rect, force_random)
		else:
			_spawn_piece(id, 1, inset_rect, force_random)
			_spawn_piece(id, 2, inset_rect, force_random)

	if GameState.current_patient == 2:
		_spawn_piece("21", 3, inset_rect, force_random)

	_spawn_piece("X", 1, inset_rect, force_random)
	if GameState.get_current_patient_is_male():
		_spawn_piece("Y", 1, inset_rect, force_random)
	else:
		_spawn_piece("X", 2, inset_rect, force_random)

	call_deferred("_bring_guide_to_front")

func _spawn_piece(id: String, homolog: int, rect: Rect2, force_random: bool = false) -> void:
	var piece = PIECE_SCENE.instantiate()
	piece.chromosome_id = id
	piece.homolog = homolog
	piece.scale = Vector2(PIECE_SCALE, PIECE_SCALE)
	piece.process_mode = Node.PROCESS_MODE_ALWAYS
	spawned_pieces.append(piece)
	var key = "%s_%d" % [id, homolog]
	var target_pos: Vector2
	var target_rot: float
	if not force_random and GameState.karyotype_state.has(key):
		var saved = GameState.karyotype_state[key]
		target_pos = saved["position"]
		target_rot = saved["rotation"]
	else:
		target_pos = Vector2(
			randf_range(rect.position.x, rect.position.x + rect.size.x),
			randf_range(rect.position.y, rect.position.y + rect.size.y)
		)
		target_rot = randf_range(0, TAU)
		GameState.karyotype_state[key] = {
			"position": target_pos,
			"rotation": target_rot,
			"normalized": _normalize(target_pos, rect)
		}
	get_parent().add_child.call_deferred(piece)
	piece.ready.connect(func():
		piece.global_position = target_pos
		piece.rotation = target_rot
	, CONNECT_ONE_SHOT)

func _bring_guide_to_front() -> void:
	if guide_node.is_empty():
		return
	var guide := get_node(guide_node)
	guide.move_to_front()

func _normalize(pos: Vector2, rect: Rect2) -> Vector2:
	return Vector2(
		(pos.x - rect.position.x) / rect.size.x,
		(pos.y - rect.position.y) / rect.size.y
	)

func _sort_chromosomes() -> void:
	var rect = get_spawn_rect()
	var sample_tex: Texture2D = load("res://assets/Chromosomes/1.tres")
	var piece_size: Vector2 = sample_tex.get_size() * PIECE_SCALE
	var within_pair_gap := 2.0      
	var between_pair_gap := 10.0   
	var row_gap := 12.0             
	var pairs_per_row := 8
	var row_height := piece_size.y + row_gap
	var start_pos : Vector2 = rect.position + piece_size / 2

	
	var groups: Array = []
	for piece in spawned_pieces:
		if not is_instance_valid(piece):
			continue
		if piece.homolog == 1 or groups.is_empty():
			groups.append([piece])
		else:
			groups[groups.size() - 1].append(piece)

	for g in groups.size():
		var group: Array = groups[g]
		var row := g / pairs_per_row
		var col := g % pairs_per_row
		var x_cursor := col * (piece_size.x * 2 + between_pair_gap)  
		var y := row * row_height

		for j in group.size():
			var piece = group[j]
			var target_pos := start_pos + Vector2(x_cursor + j * (piece_size.x + within_pair_gap), y)
			piece.global_position = target_pos
			piece.rotation = 0.0
			var key = "%s_%d" % [piece.chromosome_id, piece.homolog]
			GameState.karyotype_state[key] = {
				"position": target_pos,
				"rotation": 0.0,
				"normalized": _normalize(target_pos, rect)
			}
