extends State

var target: KinematicBody2D

var damage: int = 10
var distance: int = 20

onready var attack_timer = $AttackCooldown
onready var sprite = get_node("../../Sprite")

func enter(_msg := {}) -> void:
	if not "target" in _msg:
		state_machine.transition_to("Idle")
	target = _msg["target"]

func update(_delta: float) -> void:
	if target.state == target.States.DEAD:
		state_machine.transition_to("Idle")
		return
		
	# Check if target is away
	var dir = target.global_position - owner.global_position
	if dir.length() > distance:
		state_machine.transition_to("Move", {"target_position": target.global_position})
	
	attack_player()

func attack_player() -> void:
	if attack_timer.is_stopped():
		if target.has_method("hit_by_damager"):
			target.hit_by_damager(damage)
			attack_timer.start()
