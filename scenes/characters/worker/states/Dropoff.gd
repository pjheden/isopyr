extends State

onready var player = get_parent().get_parent()
var dropoff_time = 5.0

func enter(_msg := {}) -> void:
	player.play_animation(player.get_rotation() > 0, "Dropoff")
	yield(get_tree().create_timer(dropoff_time), "timeout")
	drop()
	state_machine.transition_to("Idle")

func drop() -> void:
	# TODO: give resources to base
	player.resources = []
