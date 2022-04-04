extends "res://scenes/characters/player/BasePlayer.gd"

const projectile_scene = preload("res://scenes/objects/Spear.tscn")

sync func instance_projectile(id):
	var projectile_instance = projectile_scene.instance()
	projectile_instance.set_network_master(id) # set projectile owner
	projectile_instance.player_rotation = player_rotation
	if abs(player_rotation) > PI / 2:
		projectile_instance.global_position = $ShootPointLeft.global_position
	else:
		projectile_instance.global_position = $ShootPointRight.global_position
	projectile_instance.name = "Projectile_" + str(id) + "_" +str(Network.networked_object_name_index)
	Network.networked_object_name_index += 1
	get_node("/root/PersistantObjects").add_child(projectile_instance)


func attack_animation_finished():
	if is_network_master():
		rpc("instance_projectile", get_tree().get_network_unique_id())
	state = States.IDLE
	$AttackCooldown.start()
