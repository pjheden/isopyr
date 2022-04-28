extends State

var target: KinematicBody2D

enum States {CHASE, ATTACK}
var state: int = States.CHASE
var damage: int = 10
var distance: int = 20

onready var attack_timer = $AttackCooldown


func enter(_msg := {}) -> void:
	if not "target" in _msg:
		state_machine.transition_to("Idle")
	target = _msg["target"]
	state = States.CHASE

func update(delta: float) -> void:
	if target.state == target.States.DEAD:
		state_machine.transition_to("Idle")
		return

	match state:
		States.CHASE:
			move_player(delta)
		States.ATTACK:
			attack_player()

func move_player(_delta: float) -> void:
	var dir = target.global_position - owner.global_position

	# add early stop to prevent shaking close to target pos
	if dir.length() < distance:
		state = States.ATTACK
		return
	var velocity = dir.normalized()
	var _vel = owner.move_and_slide(velocity * owner.speed)

func attack_player() -> void:
	var dir = target.global_position - owner.global_position
	if dir.length() > distance:
		state = States.CHASE
		return

	if attack_timer.is_stopped():
		if target.has_method("hit_by_damager"):
			target.hit_by_damager(damage)
			attack_timer.start()
