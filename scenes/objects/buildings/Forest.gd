extends "res://scenes/objects/buildings/Building.gd"

export(int) var wood = 4000
export(int) var slots = 3

var contains : int
var spawn_node: Node
var resource_type = Global.Resource.WOOD

func _ready():
	spawn_node = get_node("/root/world/YSort")

func relevant_orders() -> Array:
	return [Global.WorkOrder.FORESTRY]

func available_slot() -> bool:
	return contains < slots

func enter(body: Node, gather_time: float, gather_amount: float) -> void:
	contains += 1
	body.enter_building(self)
	yield(get_tree().create_timer(gather_time), "timeout")
	leave(body, gather_amount)

func leave(body: Node, gather_amount: float) -> void:
	contains -= 1
	# add resource
	body.add_resource(take_resource(gather_amount), resource_type)
	# add to world
	spawn_node.add_child(body)
	body.respawn()

func take_resource(gather_amount: float) -> float:
	if wood < gather_amount:
		var returning_wood = wood
		wood = 0
		return returning_wood
	else:
		wood -= gather_amount
		return gather_amount

# override unused parent variables
func damage(_amount):
	return false

func _on_Hitbox_area_entered(_area):
	pass

func _on_Hitbox_mouse_entered():
	Mouse.play_info(self)

func _on_Hitbox_mouse_exited():
	Mouse.reset()

func _on_Hitbox_body_entered(body:Node):
	if body.is_in_group("worker") and body.wants_to_enter(self):
		enter(body, body.gather_time, body.gather_amount)
