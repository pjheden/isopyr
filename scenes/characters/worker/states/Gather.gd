extends State

onready var player = get_parent().get_parent()
var gather_time = 5.0
var gather_amount = 50.0

func enter(_msg := {}) -> void:
	player.play_animation(player.get_rotation() > 0, "Gather")
	yield(get_tree().create_timer(gather_time), "timeout")
	gather()
	base()

func gather() -> void:
	# TODO: make enum
	player.add_resource(50.0, "LUMBER")

func base() -> void:
	# find the most suited foresst
	var bases = get_node("/root/world/Resources/Base").get_children()
	if bases.size() == 0:
		return

	var closest_dist = player.global_position.distance_to(bases[0].global_position)
	var closest_idx = 0
	var i = 0
	for base in bases:
		var current_dist = player.global_position.distance_to(base.global_position)
		if current_dist < closest_dist:
			closest_idx = i
		i += 1

	# transition with relevant data
	player.state_machine.transition_to(
		"Move",
		{
			"targetPosition": bases[closest_idx].global_position,
		}
	)
