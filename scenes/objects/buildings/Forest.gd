extends "res://scenes/objects/buildings/Building.gd"

export(int) var wood = 4000
export(int) var slots = 3

const worker_scene = preload("res://scenes/characters/worker/Worker.tscn")

var contains : int
var spawn_node: Node

func _ready():
	spawn_node = get_node("/root/world/YSort")

func available_slot() -> bool:
	return contains < slots

func enter_forest(unit_data: Dictionary, gather_time: float, gather_amount: float) -> void:
	contains += 1

	yield(get_tree().create_timer(gather_time), "timeout")
	leave_forest(unit_data, gather_amount)

func leave_forest(unit_data: Dictionary, gather_amount: float) -> void:
	contains += 1
	
	# create worker
	var worker = worker_scene.instance()
	worker.load(unit_data)
	# add resource
	worker.add_resource(take_resource(gather_amount), "WOOD")
	# add to world
	spawn_node.add_child(worker)

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
	if body.is_in_group("worker") and body.has_method("data") and not body.has_resources():
		enter_forest(body.data(), body.gather_time, body.gather_amount)
		body.queue_free()
