extends Node2D

@export var spawn_area : Sprite2D

var spawn_size := Vector2(300,400)


func _ready():

	randomize()

	if !GameState.have_sex:
		GameState.determine_sex()

	setup_chromosomes()


func setup_chromosomes():

	var rect = get_spawn_rect()

	var chromosomes = get_tree().get_nodes_in_group("chromosome")

	# Hide everything first
	for c in chromosomes:

		c.visible = false

		c.global_position = Vector2(
			randf_range(rect.position.x, rect.position.x + rect.size.x),
			randf_range(rect.position.y, rect.position.y + rect.size.y)
		)

		c.rotation = randf_range(0, TAU)

	# Show autosomes
	for c in chromosomes:

		if c.chromosome_id != "X" and c.chromosome_id != "Y":
			c.visible = true

	# Always show first X
	for c in chromosomes:

		if c.chromosome_id == "X" and c.homolog == 1:
			c.visible = true

	# Show second sex chromosome
	if GameState.patient_sex == GameState.Sex.MALE:

		for c in chromosomes:

			if c.chromosome_id == "Y":
				c.visible = true

	else:

		for c in chromosomes:

			if c.chromosome_id == "X" and c.homolog == 2:
				c.visible = true


func get_spawn_rect() -> Rect2:

	var size = spawn_size

	if spawn_area.texture:
		size = spawn_area.texture.get_size() * spawn_area.scale

	var top_left = spawn_area.global_position - size / 2

	return Rect2(top_left,size)
