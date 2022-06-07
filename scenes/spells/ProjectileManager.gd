extends "res://scenes/spells/SpellManager.gd"

var projectile_scene: Resource
var projectile_icon_path: String

#var rock_scene = preload("res://scenes/objects/projectiles/Boulder.tscn")
onready var persistant_objects = get_node("/root/PersistantObjects")
onready var player = get_parent()

func set_projectile(scene_path: String, icon_path: String) -> void:
	projectile_scene = load(scene_path)
	projectile_icon_path = icon_path

func activate(params := {}) -> void:
	.activate(params)
	
	# shoot rock
	var projectile_instance = projectile_scene.instance()
	projectile_instance.set_network_master(player.id) # set projectile owner
	var angle = player.get_rotation()
	var direction = Vector2(cos(angle), sin(angle))
	projectile_instance.player_rotation = angle
	projectile_instance.global_position = player.global_position + direction * 30
	projectile_instance.name = "Projectile_" + str(player.id) + "_" +str(Network.networked_object_name_index)
	# set team based on params
	var team: int = Global.Team.NONE 
	if "team" in params:
		team = params["team"]
	projectile_instance.set_team(team)
	Network.networked_object_name_index += 1
	persistant_objects.add_child(projectile_instance)

func deactivate() -> void:
	pass

# func _on_AliveTimer_timeout() -> void:
# 	deactivate()

func icon() -> String:
	"""
	Returns the path to the spell icon for UI usage
	"""
	return projectile_icon_path

