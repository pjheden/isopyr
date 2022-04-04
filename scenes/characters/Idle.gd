extends State

onready var idle_timer = $IdleCooldown

func enter(_msg := {}) -> void:
	idle_timer.wait_time = rand_range(3,15)
	idle_timer.start()

func update(delta: float) -> void:
	if idle_timer.is_stopped():
		state_machine.transition_to("Move")
