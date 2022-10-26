extends "res://scenes/objects/buildings/Building.gd"

export var respawn_time: float = 10.0 # seconds

const worker_scene = preload("res://scenes/characters/worker/Worker.tscn")
const dove_scene = preload("res://scenes/objects/projectiles/Dove.tscn")
onready var player_spawns = $Spawns
var resources: Dictionary = {}
# ui variables
onready var menu = $Menu
onready var wood_count = $Menu/WoodCount
onready var item_list = $Menu/ItemList
var item_list_worker_index: int
# worker variables
var worker_spawn_node: Node
var workers = [null, null, null] # set one null for the amount of workers the base should control


# Called when the node enters the scene tree for the first time.
func _ready():
	# Create buildings 3 workers
	init_workers()
	update_resource_ui()
	worker_spawn_node = get_node("/root/world/YSort")
	var connected = Game.connect("dead_player", self, "start_spawning_player")
	if not connected:
		push_error("Could not connect to signal dead_player")

func init_workers():
	# create workers
	for i in range(workers.size()):
		var worker = worker_scene.instance()
		worker.team = team
		worker.global_position = get_random_spawn().global_position
		worker.active_order = Global.WorkOrder.NONE
		worker.last_entered_building = self
		workers[i] = worker


# Player methods

func get_random_spawn() -> Node:
	return player_spawns.get_child(randi() % player_spawns.get_child_count())

func start_spawning_player(id: int) -> void:
	print("start_spawning_player id: %d" % id)
	# ignore players not belonging to this base
	if not team == Game.players_info[id].team:
		return
	yield(get_tree().create_timer(respawn_time), "timeout")
	var spawn = get_random_spawn()
	var world = get_node("/root/world")
	Game.spawn_player(world, id, spawn.global_position)

# Worker methods

#TODO: update menu icons based on worker status

func enter(worker: Node, enter_time: float) -> void:
	# Remove worker from world
	worker.enter_building(self)
	if worker.active_order != Global.WorkOrder.NONE: 
		yield(get_tree().create_timer(enter_time), "timeout")
		leave(worker)

func leave(worker: Node) -> void:
	# load base with all the workers resources
	for resource in worker.resources:
		if resource.type in resources:
			resources[resource.type] += resource.amount
		else:
			resources[resource.type] = resource.amount
	worker.resources = []
	update_resource_ui()
	# add to world
	worker_spawn_node.add_child(worker)
	worker.respawn()
	worker.global_position = get_random_spawn().global_position

func _on_Hitbox_body_entered(body:Node):
	if body.is_in_group("worker") and body.wants_to_enter(self):
		enter(body, 3.0)

func _on_Menubox_body_exited(body:Node):
	if body.is_in_group("player") and body.is_in_group("team_%s" % team):
		# hide menu
		menu.hide()

func _on_Menubox_body_entered(body:Node):
	if body.is_in_group("player") and body.is_in_group("team_%s" % team):
		# show menu
		menu.show()

func _on_Worker0_pressed():
	var worker_index = 0
	show_item_list(relevant_worker_items(worker_index), worker_index)

func _on_Worker1_pressed():
	var worker_index = 1
	show_item_list(relevant_worker_items(worker_index), worker_index)
		
func _on_Worker2_pressed():
	var worker_index = 2
	show_item_list(relevant_worker_items(worker_index), worker_index)

func relevant_worker_items(worker_index: int) -> Array:
	var worker = workers[worker_index]
	if worker.active_order == Global.WorkOrder.NONE:
		return ["Wood"]
	elif worker.active_order == Global.WorkOrder.FORESTRY:
		return ["Home"]
	elif worker.active_order == Global.WorkOrder.HOME:
		return ["Wood"]
	return ["Home", "Wood"]

func show_item_list(items: Array, worker_index: int) -> void:
	# Change and show item menu to select work activity
	# Options: Forestry, Home, (later: rock)
	# Update items
	item_list.clear()
	# TODO: change to icons
	for item in items:
		item_list.add_item(item)
	item_list_worker_index = worker_index

	# Toggle visibility
	if item_list.visible:
		item_list.hide()
	else:
		item_list.show()

func _on_ItemList_item_selected(index:int) -> void:
	# Here we need to handle any item selected
	# which can be a lot since we use the same list for
	# different types of units / bases
	item_list.hide()
	var selected_text: String = item_list.get_item_text(index)
	match (selected_text):
		"Home":
			send_order(item_list_worker_index, Global.WorkOrder.HOME)
		"Wood":
			send_order(item_list_worker_index, Global.WorkOrder.FORESTRY)
		_: # default
			push_error("No such selection %s" % selected_text)

func send_order(worker_index: int, order:int) -> void:
	# Send order to worker
	# if the worker is in base easy
	# else send a bird with the order
	var worker: Node = workers[worker_index]
	print("send order wi: %s o: %s wo: %s" % [worker_index, order, worker.active_order])
	if worker.active_order == Global.WorkOrder.NONE:
		worker.change_order(order)
		leave(worker)
	else:
		# Tween a dove between worker and base
		# on tween finish, change active order for worker
		# let worker handle transition of a new active order
		var dove = dove_scene.instance()
		dove.global_position = global_position
		dove.target = worker
		dove.message = order
		worker_spawn_node.add_child(dove)
		print("spawned dove", dove)

func update_resource_ui() -> void:
	var wood = 0
	if Global.Resource.WOOD in resources:
		wood = resources[Global.Resource.WOOD]
	wood_count.text = str(wood)
