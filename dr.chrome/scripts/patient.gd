extends CharacterBody2D

const SPEED = 60.0

@export var target_marker: NodePath
var target_y: float
var arrived := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var pickup_area: Area2D = $Area2D

func _ready() -> void:
	target_y = get_node(target_marker).global_position.y
	pickup_area.body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	if arrived:
		return

	var diff = target_y - global_position.y
	if abs(diff) < 2.0:
		velocity = Vector2.ZERO
		arrived = true
		anim.play("idle0")
		move_and_slide()
		return

	var dir = 1 if diff > 0 else -1
	velocity = Vector2(0, dir * SPEED)
	move_and_slide()
	anim.play("walking0" if dir > 0 else "walking180")
	
	
func _on_body_entered(body: Node2D) -> void:
	if not arrived:
		return  
	if body.is_in_group("player") and not GameState.blood:
		GameState.pick_up_item()
