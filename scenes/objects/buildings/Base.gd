extends "res://scenes/objects/buildings/Building.gd"

export var respawn_time: float = 10.0 # seconds

const worker_scene = preload("res://scenes/characters/worker/Worker.tscn")
onready var player_spawns = get_node("Spawns")
onready var worker_node = get_node("/root/world/YSort")

# Called when the node enters the scene tree for the first time.
func _ready():
	var connected = Game.connect("dead_player", self, "start_spawning_player")
	if not connected:
		push_error("Could not connect to signal dead_player")

func start_spawning_player(id: int) -> void:
	print("start_spawning_player id: %d" % id)
	# ignore players not belonging to this base
	if not team == Game.players_info[id].team:
		return
	yield(get_tree().create_timer(respawn_time), "timeout")
	var spawn = player_spawns.get_child(randi() % player_spawns.get_child_count())
	var world = get_node("/root/world")
	Game.spawn_player(world, id, spawn.global_position)

func enter(unit_data: Dictionary, enter_time: float) -> void:
	yield(get_tree().create_timer(enter_time), "timeout")
	leave(unit_data)

func leave(unit_data: Dictionary) -> void:
	# create worker
	var worker = worker_scene.instance()
	worker.load(unit_data)
	# load base with all the workers resources
	worker.resources = [] # TODO: load into base
	# add to world
	worker_node.add_child(worker)

func _on_Hitbox_body_entered(body:Node):
	if body.is_in_group("worker") and body.has_method("data") and body.has_resources():
		enter(body.data(), 3.0)
		body.queue_free()