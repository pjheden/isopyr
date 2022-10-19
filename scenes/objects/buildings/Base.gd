extends "res://scenes/objects/buildings/Building.gd"

export var respawn_time: float = 10.0 # seconds

onready var spawns = get_node("Spawns")

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
	var spawn = spawns.get_child(randi() % spawns.get_child_count())
	var world = get_node("/root/world")
	Game.spawn_player(world, id, spawn.global_position)
