extends Node

var player_master = null
var projectile_scenes = {}
var spell1_button = "Spell1"
var spell2_button = "Spell2"

# Enums
enum Hero {MAXIMUS, BEDUIN, GOOLOCK, PLAGUEDOCTOR}
enum Team {NONE, TEAM1, TEAM2, TEAM3, TEAM4, TEAM5, TEAM6, TEAM7, TEAM8, TEAM9}
enum GameMode {SIEGE, TDM, FFA}
enum WorkOrder {NONE, HOME, FORESTRY}
enum Resource {UNDEFINED, WOOD}

# Utils methods
func get_hero_icon(hero: int) -> Texture:
	var txt: Texture
	match hero:
		Hero.MAXIMUS:
			txt = load("res://resources/ui/warrior-icon.png");
		Hero.BEDUIN:
			txt = load("res://resources/ui/beduin-icon.png");
		Hero.GOOLOCK:
			txt = load("res://resources/ui/goolock-icon.png");
		Hero.PLAGUEDOCTOR:
			txt = load("res://resources/ui/plaguedoctor-icon.png");
	return txt

sync func instance_projectile(
	id: int,
	projectile_scene: String,
	rotation: float,
	spawn_position: Vector2,
	team: int
	):
	print("%s got instance_projectile call" % Network.my_id)
	if not projectile_scene in projectile_scenes:
		assert(false, "projectile scene  %s is not registered in %s" % [projectile_scene, projectile_scenes])
	var projectile_instance = projectile_scenes[projectile_scene].instance()
	projectile_instance.set_network_master(id) # set projectile owner
	projectile_instance.player_rotation = rotation
	projectile_instance.global_position = spawn_position
	projectile_instance.name = "Projectile_" + str(id) + "_" +str(Network.networked_object_name_index)
	projectile_instance.set_team(team)
	Network.networked_object_name_index += 1
	get_node("/root/world/Traps").add_child(projectile_instance)

func projectile(
	id: int,
	projectile_scene: String,
	rotation: float,
	spawn_position: Vector2,
	team: int
	):
	#if get_tree().is_network_server():
	rpc("instance_projectile", id, projectile_scene, rotation, spawn_position, team)

func add_projectile_scene(path: String) -> void:
	#projectile_scenes[path] = load(path)
	rpc("share_new_projectile_scene", path)

sync func share_new_projectile_scene(path: String) -> void:
	projectile_scenes[path] = load(path)

func get_players(skip_team: int) -> Array:
	var players = get_node("/root/world/YSort/Players").get_children()
	var players_on_other_team = []

	for player in players:
		if not "team" in player:
			players_on_other_team.push_back(player)
		elif player.team != skip_team:
			players_on_other_team.push_back(player)

	# if there are no players, get closest wall / statue
	if players_on_other_team.empty():
		players = get_node("/root/world/YSort/Walls").get_children()
		for player in players:
			if not "team" in player:
				players_on_other_team.push_back(player)
			elif player.team != skip_team:
				players_on_other_team.push_back(player)

	return players_on_other_team
