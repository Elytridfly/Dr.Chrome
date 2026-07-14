extends CharacterBody2D
const SPEED = 100.0
@export var target_marker: NodePath
@export var target_marker_2: NodePath
@export var patient_number: int = 1
var target_y: float
var target_y_2: float
var arrived := false
var walking_to_second := false
var second_arrived := false
var player_in_area := false
var blood_taken := false
var is_active := false
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var pickup_area: Area2D = $Area2D

func _ready() -> void:
	target_y = get_node(target_marker).global_position.y
	pickup_area.body_entered.connect(_on_body_entered)
	pickup_area.body_exited.connect(_on_body_exited)
	_refresh_active_state()

func _physics_process(_delta: float) -> void:
	_refresh_active_state()
	if not is_active:
		return
	if walking_to_second:
		_process_walk_to_second()
		return
	if arrived:
		return
	var diff = target_y - global_position.y
	if abs(diff) < 2.0:
		velocity = Vector2.ZERO
		arrived = true
		_play_idle_state()
		move_and_slide()
		return
	var dir = 1 if diff > 0 else -1
	velocity = Vector2(0, dir * SPEED)
	move_and_slide()
	anim.play("walking0" if dir > 0 else "walking180")

func _refresh_active_state() -> void:
	var should_be_active := patient_number == GameState.current_patient and not second_arrived
	if should_be_active == is_active:
		return
	is_active = should_be_active
	visible = is_active
	pickup_area.set_deferred("monitoring", is_active)

func _process_walk_to_second() -> void:
	var diff = target_y_2 - global_position.y
	if abs(diff) < 2.0:
		velocity = Vector2.ZERO
		walking_to_second = false
		second_arrived = true
		_play_idle_state()
		move_and_slide()
		visible = false
		set_physics_process(false)
		pickup_area.set_deferred("monitoring", false)
		GameState.advance_patient()
		return
	velocity = Vector2(0, -SPEED)
	move_and_slide()
	anim.play("walking180")

func _play_idle_state() -> void:
	anim.play("interact0" if player_in_area else "idle0")

func _on_body_entered(body: Node2D) -> void:
	if not is_active or not body.is_in_group("player"):
		return
	player_in_area = true
	if arrived and not walking_to_second:
		anim.play("interact0")
	if not arrived:
		return
	if not blood_taken:
		blood_taken = true
		GameState.pick_up_item()
	elif GameState.report and not walking_to_second and not second_arrived:
		GameState.complete_treatment()
		target_y_2 = get_node(target_marker_2).global_position.y
		walking_to_second = true

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	player_in_area = false
	if arrived and not walking_to_second and not second_arrived:
		anim.play("idle0")
