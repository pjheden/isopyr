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
		player_info[id]["team"] = p_i[id]["team"]
		player_info[id]["alive"] = true

## lobby cleans up the level, players and such and return the visuals to the lobby
sync func lobby() -> void:
	# remove world
	var world = get_node("/root/world")
	if world:
		world.get_parent().remove_child(world)
	# reset player info
	#player_info = {}
	# show lobby
	Network.lobby.show()
	Network.lobby.hide_server_browser(get_tree().get_network_unique_id() == 1)

func load_world() -> Node:
	# Load world
	var world = load(Network.get_map()).instance()
	world.name = "world"
	var root = get_node("/root")
	root.add_child(world)
	root.move_child(world, 0)	

	return world
	
func spawn_players(world, spawn_points) -> void:
	# Get spawns
	var none_spawns_node = world.get_node("Spawns/0")
	var brood_spawns_node = world.get_node("Spawns/1")
	var fremen_spawns_node = world.get_node("Spawns/2")
	for p_id in spawn_points:
		var spawn_pos
		if player_info[p_id]["team"] == Global.Team.BROODS:
			spawn_pos = brood_spawns_node.get_child(spawn_points[p_id]).global_position
		elif player_info[p_id]["team"] == Global.Team.FREMEN:
			spawn_pos = fremen_spawns_node.get_child(spawn_points[p_id]).global_position
			spawn_pos = brood_spawns_node.get_child(spawn_points[p_id]).global_position
		elif player_info[p_id]["team"] == Global.Team.NONE:
			spawn_pos = none_spawns_node.get_child(spawn_points[p_id]).global_position
		else:
			push_error("invalid spawn setup, player had team %s" % player_info[p_id]["team"])
		var player = character_scene(player_info[p_id]["hero"]).instance()
		player.set_name(str(p_id))
		player.set_team(player_info[p_id]["team"])
		player.id = p_id
		print("setting network master %s" % p_id)
		player.set_network_master(p_id)
		player.global_position = spawn_pos
		world.get_node("YSort/Players").add_child(player)

func character_scene(hero: int):
	match hero:
		Global.Hero.MAXIMUS:
			return load("res://scenes/characters/player/Maximus.tscn")
		Global.Hero.BEDUIN:
			return load("res://scenes/characters/player/Beduin.tscn")
		Global.Hero.GOOLOCK:
			return load("res://scenes/characters/player/Goolock.tscn")
		Global.Hero.PLAGUEDOCTOR:
			return load("res://scenes/characters/player/PlagueDoctor.tscn")
	assert(true, "Could not match hero with value %s " % hero)
