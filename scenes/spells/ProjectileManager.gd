extends "res://scenes/spells/SpellManager.gd"

var rock_scene = preload("res://scenes/objects/projectiles/Boulder.tscn")
onready var persistant_objects = get_node("/root/PersistantObjects")
onready var player = get_parent()

func activate() -> void:
	.activate()
	
	# shoot rock
	var projectile_instance = rock_scene.instance()
	projectile_instance.set_network_master(player.id) # set projectile owner
	var angle = player.get_rotation()
	var direction = Vector2(cos(angle), sin(angle))
	print("player angle: ", angle)
	print("player direction: ", direction)
	projectile_instance.player_rotation = angle
	projectile_instance.global_position = player.global_position + direction * 30
	# TODO: change starting position to be a bit outside of the player
	projectile_instance.name = "Projectile_" + str(player.id) + "_" +str(Network.networked_object_name_index)
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
	return "res://resources/sprites/rockpng.png"

