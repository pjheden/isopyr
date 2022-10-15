extends Node

var game_info = {
	"current_map": ""
}
var players_info = {}

func _process(_delta: float) -> void:
	if len(players_info) == 0:
		return
	# Have server check if all players are dead
	if get_tree().is_network_server():
		var all_dead = all_dead()
		if all_dead:
			rpc("lobby")

func all_dead() -> bool:
	for p in players_info:
		if players_info[p]["alive"]:
			return false
	return true

func dead(id: int) -> void:
	"""
	dead registers if a player is dead
	"""
	print("setting game dead for id ", id)
	players_info[id]["alive"] = false
	
# func set_players(p_i) -> void:
# 	"""
# 	set_players keeps info on all players related to gameplay
# 	"""
# 	for id in p_i:
# 		players_info[id] = {}
# 		players_info[id]["name"] = p_i[id]["name"]
# 		players_info[id]["color"] = p_i[id]["color"]
# 		players_info[id]["hero"] = p_i[id]["hero"]
# 		players_info[id]["team"] = p_i[id]["team"]
# 		players_info[id]["alive"] = true

## lobby cleans up the level, players and such and return the visuals to the lobby
sync func lobby() -> void:
	# remove world
	var world = get_node("/root/world")
	if world:
		world.get_parent().remove_child(world)
	# reset player info
	# players_info = {}
	# show lobby
	Network.lobby.show()
	Network.lobby.hide_server_browser(get_tree().get_network_unique_id() == 1)

func load_world() -> Node:
	# Load world
	var world = load(game_info.current_map).instance()
	world.name = "world"
	get_node("/root").add_child(world)

	return world
	
func spawn_players(world: Node, spawn_points: Dictionary) -> void:
	# Get spawns
	var spawns_node = world.get_node("Spawns")
	
	for p_id in spawn_points:
		var spawn_pos = spawns_node.get_child(spawn_points[p_id]).global_position
		var player = character_scene(players_info[p_id]["hero"]).instance()
		player.set_name(str(p_id))
		player.set_team(players_info[p_id]["team"])
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

func create_player_info():
	var d = {}
	d["name"] = Save.save_data["playerName"]
	var colors = [Color8(0,0,0), Color8(255,255,255), Color8(255,0,0), Color8(0,255,0), Color8(0,0,255)]
	d["color"] = colors[randi() % colors.size()]
	d["hero"] = Global.Hero.PLAGUEDOCTOR
	d["team"] = Global.Team.TEAM1
	d["alive"] = true

	# TMP for easier debugging
	if get_tree().get_network_unique_id() != 1:
		d["hero"] = Global.Hero.BEDUIN
		d["team"] = Global.Team.TEAM2
	return d