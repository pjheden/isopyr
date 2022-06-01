extends Node

var player_info = {}

func _process(_delta: float) -> void:
	if len(player_info) == 0:
		return
	# Have server check if all players are dead
	if get_tree().is_network_server():
		var all_dead = all_dead()
		if all_dead:
			rpc("lobby")

func all_dead() -> bool:
	for p in player_info:
		if player_info[p]["alive"]:
			return false
	return true

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
		player_info[id]["hero"] = p_i[id]["hero"]
		player_info[id]["alive"] = true

## lobby cleans up the level, players and such and return the visuals to the lobby
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
	var world = load("res://scenes/levels/level3.tscn").instance()
	world.name = "world"
	get_node("/root").add_child(world)
	
	return world
	
func spawn_players(world, spawn_points) -> void:
	# Get spawns
	var spawns_node = world.get_node("Spawns")
	for p_id in spawn_points:
		var spawn_pos = spawns_node.get_child(spawn_points[p_id]).global_position
		var player = character_scene(player_info[p_id]["hero"]).instance()
		player.set_name(str(p_id))
		player.id = p_id
		player.set_network_master(p_id)
		player.global_position = spawn_pos
		world.get_node("YSort/Players").add_child(player)

func character_scene(_name: String):
	# match name:
	# 	"Sword":
	# 		return load("res://scenes/characters/player/SwordPlayer.tscn")
	# 	"Spear":
	# 		return load("res://scenes/characters/player/SpearPlayer.tscn")
	return load("res://scenes/characters/player/Caster.tscn")
