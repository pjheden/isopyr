extends State

onready var idle_timer = $IdleCooldown

func enter(_msg := {}) -> void:
	idle_timer.wait_time = rand_range(3,15)
	idle_timer.start()

func update(_delta: float) -> void:
	if idle_timer.is_stopped():
		state_machine.transition_to("Move")

func body_detected(b: KinematicBody2D) -> void:
	if b.is_in_group("Player"):
		state_machine.transition_to("Attack", {"target": b})
