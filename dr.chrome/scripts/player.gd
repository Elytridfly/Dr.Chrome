extends CharacterBody2D

const SPEED = 90.0
var last_dir: Vector2 = Vector2.DOWN

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("interact"):
		interact()
	
	process_movement()
	process_anim()
	move_and_slide()




# Interaction Stuffs

func interact() -> void:
	return 




# Movement and Anim Stuffs

func process_movement() -> void:
	if GameState.ui_blocking_input:
		velocity = Vector2.ZERO
		return
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_dir = direction
	else:
		velocity = Vector2.ZERO


func process_anim() -> void:
	if velocity != Vector2.ZERO:
		play_anim("walking", last_dir)
	else:
		play_anim("idle", last_dir)
	


func play_anim(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		anim.flip_h = dir.x<0
		anim.play(prefix + "90")
	elif dir.y < 0:
		anim.play(prefix + "180")
	elif dir.y > 0:
		anim.play(prefix + "0")	
