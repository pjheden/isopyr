extends "res://scenes/spells/SpellManager.gd"

#var aoe_scene: Resource
var aoe_scene: String
var aoe_icon_path: String
var animation_name: String

# onready var parent_object = get_node("/root/PersistantObjects")
#onready var parent_object = get_node("/root/world/Traps/")
onready var player = get_parent()

func set_object(scene_path: String, icon_path: String, new_cast_time: float, anim_name: String) -> void:
	#aoe_scene = load(scene_path)
	Global.add_projectile_scene(scene_path)
	aoe_scene = scene_path
	aoe_icon_path = icon_path
	animation_name = anim_name
	cast_time = new_cast_time

func activate(params := {}) -> bool:
	# TODO: check if this calls super twice
	if not .activate(params):
		return false

	# TODO: add network code
	var team: int = Global.Team.NONE 
	if "team" in params:
		team = params["team"]
	Global.projectile(
		Network.my_id,
		aoe_scene,
		0,
		Mouse.global_position,
		team
	)
	
	# spawn aoe
	#var aoe_instance = aoe_scene.instance()
	#aoe_instance.set_network_master(player.id) # set projectile owner
	## var angle = player.get_rotation()
	## aoe_instance.player_rotation = angle
	#aoe_instance.global_position = Mouse.global_position
	#aoe_instance.name = "Aoe_" + str(player.id) + "_" +str(Network.networked_object_name_index)
	# set team based on params
	# var team: int = Global.Team.NONE 
	# if "team" in params:
	# 	team = params["team"]
	# aoe_instance.set_team(team)
	# Network.networked_object_name_index += 1
	# parent_object.add_child(aoe_instance)
	return true

func deactivate() -> void:
	pass

# func _on_AliveTimer_timeout() -> void:
# 	deactivate()

func icon() -> String:
	"""
	Returns the path to the spell icon for UI usage
	"""
	return aoe_icon_path

