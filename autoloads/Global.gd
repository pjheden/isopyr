extends Node

var player_master = null
var projectile_scenes = {}
var move_button = "left_click"

# Enums
enum Hero {MAXIMUS, BEDUIN, GOOLOCK}
enum Team {NONE, BROODS, FREMEN}

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
	return txt

sync func instance_projectile(
	id: int,
	projectile_scene: String,
	rotation: float,
	spawn_position: Vector2
	):
	if not projectile_scene in projectile_scenes:
		# TODO: throw error
		pass
	var projectile_instance = projectile_scenes[projectile_scene].instance()
	projectile_instance.set_network_master(id) # set projectile owner
	projectile_instance.player_rotation = rotation
	projectile_instance.global_position = spawn_position
	projectile_instance.name = "Projectile_" + str(id) + "_" +str(Network.networked_object_name_index)
	Network.networked_object_name_index += 1
	get_node("/root/PersistantObjects").add_child(projectile_instance)

func projectile(
	id: int,
	projectile_scene: String,
	rotation: float,
	spawn_position: Vector2
	):
	if is_network_master():
		rpc("instance_projectile", id, projectile_scene, rotation, spawn_position)

func add_projectile_scene(path: String) -> void:
	projectile_scenes[path] = load(path)
