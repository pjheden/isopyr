extends Node

var player_info = {}

func _process(delta) -> void:
	if len(player_info) == 0:
		return
	# Have server check if all players are dead
	if get_tree().is_network_server():
		var all_dead = all_dead()
		if all_dead:
			rpc("lobby")

func all_dead() -> bool:
	var ad = true
	for p in player_info:
		if player_info[p]["alive"]:
			ad = false
			break
	return ad

func dead(id: int) -> void:
	"""
	dead registers if a player is dead
	"""
	print("setting game dead for id ", id)
	player_info[id]["alive"] = false
	
func set_players(p_i) -> void:
	"""
	set_players keeps info on all players related to gameplay
	"""
	for id in p_i:
		player_info[id] = {}
		player_info[id]["name"] = p_i[id]["name"]
		player_info[id]["color"] = p_i[id]["color"]
		player_info[id]["alive"] = true

sync func lobby() -> void:
	# remove world
	var world = get_node("/root/world")
	if world:
		world.get_parent().remove_child(world)
	# reset player info
	player_info = {}
	# show lobby
	Network.lobby.hide_server_browser(get_tree().get_network_unique_id() == 1)

func load_world() -> Node:
	# Load world
	var world = load("res://scenes/levels/level2_tiles.tscn").instance()
	world.name = "world"
	get_node("/root").add_child(world)
	
	return world
	
func spawn_players(world, spawn_points) -> void:
	# Get spawns
	var player_scene = load("res://scenes/characters/player/SwordPlayer.tscn")
	var spawns_node = world.get_node("Spawns")
	for p_id in spawn_points:
		var spawn_pos = spawns_node.get_child(spawn_points[p_id]).global_position
		var player = player_scene.instance()
		player.set_name(str(p_id))
		player.set_network_master(p_id)
		player.global_position = spawn_pos
		world.get_node("YSort/Players").add_child(player)
