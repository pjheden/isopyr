extends State

onready var player = get_parent().get_parent()

func enter(_msg := {}) -> void:
	player.play_animation(player.get_rotation() > 0, "Idle")

func update(_delta: float) -> void:
	if player.active_order:
		handle_order(player.active_order)

func handle_order(order) -> void:
	match (order):
		Global.WorkOrder.HOME:
			move_to_nearest("/root/world/Resources/Bases")
		Global.WorkOrder.FORESTRY:
			if player.has_resources():
				move_to_nearest("/root/world/Resources/Bases")
			else:
				move_to_nearest("/root/world/Resources/Forests")
		Global.WorkOrder.NONE:
			return
		_:
			push_error("Invalid order %s" % order)

func move_to_nearest(node_path: String) -> void:
	var found_nodes = get_node(node_path).get_children()
	if found_nodes.size() == 0:
		return

	var closest_dist = player.global_position.distance_to(found_nodes[0].global_position)
	var closest_idx = 0
	var i = 0
	for found_node in found_nodes:
		var current_dist = player.global_position.distance_to(found_node.global_position)
		if current_dist < closest_dist:
			closest_idx = i
		i += 1

	# transition with relevant data
	player.state_machine.transition_to(
		"Move",
		{
			"targetPosition": found_nodes[closest_idx].global_position,
		}
	)
