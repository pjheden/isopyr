extends State

onready var player = get_parent().get_parent()

func enter(_msg := {}) -> void:
	player.play_animation(player.get_rotation() > 0, "Idle")

func update(_delta: float) -> void:
	if player.active_order:
		handle_order(player.active_order)

func handle_order(order) -> void:
	if order == player.Order.FORESTRY:
		forestry()
	else:
		push_error("Invalid order %s" % order)

func forestry() -> void:
	# find the most suited foresst
	var forests = get_node("/root/world/Resources/Forest").get_children()
	if forests.size() == 0:
		return

	var closest_dist = player.global_position.distance_to(forests[0].global_position)
	var closest_idx = 0
	var i = 0
	for forest in forests:
		var current_dist = player.global_position.distance_to(forest.global_position)
		if current_dist < closest_dist:
			closest_idx = i
		i += 1

	# transition with relevant data
	player.state_machine.transition_to(
		"Move",
		{
			"targetPosition": forests[closest_idx].global_position,
		}
	)
