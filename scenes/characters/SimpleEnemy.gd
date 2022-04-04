extends KinematicBody2D

const speed = Vector2(128, 128)
#const projectile_scene = preload("res://scenes/objects/Projectile.tscn")
#
#var hp = 100 setget set_hp
#var dead = false
#var velocity = Vector2()
#var dir = Vector2()
#var player_rotation = 0
#var target_position = Vector2()
#
## define states
#enum States {DEAD, IDLE, MOVE, ROLL, ATTACK}
#var state : int = States.IDLE
#
#onready var hit_timer = $HitTimer
#
#func _process(delta) -> void:
#	# TODO: decide state
#
#	match state:
#		States.DEAD:
#			pass
#		States.IDLE:
#			idle_state(delta)
#		States.MOVE:
#			move_state(delta)
#		States.ROLL:
#			roll_state(delta)
#		States.ATTACK:
#			attack_state(delta)
#
#
#
#	if dead:
#		return	
#	if hp <= 0:
#		die()
#
#func idle_state(delta):
#	idle_timer
#
#func move_state(delta):
#	velocity = Vector2()
#	move_player(delta)
#
#func roll_state(delta):
#	velocity = dir.normalized()
#	move_and_slide(velocity * 3 * speed)
#	play_animation(dir.y > 0, "Roll")
#
#func attack_state(delta):
#	# TODO: find attack direction
#	# rotate player towards mouse
#	#dir = Mouse.global_position - global_position
#	var x_vector = Vector2(1,0)
#	player_rotation = x_vector.angle_to(dir)
#
#func attack_animation_finished():
#	#instance_projectile(-99) #TODO
#	state = States.IDLE
#	$AttackCooldown.start()
#
#func play_animation(down: bool, type: String = "Move") -> void:
#	match type:
#		"Move":
#			if down:
#				$AnimationPlayer.play("MoveDown")
#				$AnimationPlayer.animation_set_next("MoveDown", "IdleDown")
#			else:
#				$AnimationPlayer.play("MoveTop")
#				$AnimationPlayer.animation_set_next("MoveTop", "IdleTop")
#		"Roll":
#			if down:
#				$AnimationPlayer.play("RollDown")
#			else:
#				$AnimationPlayer.play("RollTop")
#
#func move_player(delta):
#	# update player position
#		dir = last_mouse_pos - global_position
#
#	# add early stop to prevent shaking close to target pos
#	if dir.length() < 3:
#		last_mouse_pos = null
#		state = States.IDLE
#		return
#	velocity = dir.normalized()
#
#	var vel = move_and_slide(velocity * speed)
#
#	# Check how to rotate the player
#	$Sprite.flip_h = vel.x < 0
#	play_animation(vel.y > 0)
#
#	var x_vector = Vector2(1,0)
#	player_rotation = x_vector.angle_to(dir)
#
#sync func instance_projectile(id):
#	var projectile_instance = projectile_scene.instance()
#	projectile_instance.set_network_master(id) # set projectile owner
#	projectile_instance.player_rotation = player_rotation
#	if abs(player_rotation) > PI / 2:
#		projectile_instance.global_position = $ShootPointLeft.global_position
#	else:
#		projectile_instance.global_position = $ShootPointRight.global_position
#	projectile_instance.name = "Projectile_" + str(id) + "_" +str(Network.networked_object_name_index)
#	Network.networked_object_name_index += 1
#	get_node("/root/PersistantObjects").add_child(projectile_instance)
#
##sync func update_position(pos):
##	global_position = pos
##	puppet_position = pos 
#
#func set_hp(new_value) -> void:
#	hp = new_value
#
#	if is_network_master():
#		rset("puppet_hp", hp)
#
#puppet func puppet_hp_set(new_value) -> void:
#	puppet_hp = new_value
#
#	if not is_network_master():
#		hp = puppet_hp
#
#func _on_HitTimer_timeout():
#	modulate = Color(1, 1, 1, 1)
#
#func _on_Hitbox_area_entered(area):
#	if get_tree().is_network_server():
#		if area.is_in_group("Player_damager"):
#			rpc("hit_by_damager", area.get_parent().damage)
#
#			# destroy bullet on server
#			area.get_parent().rpc("destroy")
#
#sync func hit_by_damager(damage):
#	hp -= damage
#	modulate = Color(5, 5, 5, 1)
#	hit_timer.start()
#
#	if is_network_master():
#		hud.update_health_bar(hp)
#
#func die() -> void:
#	queue_free()
#
#func _exit_tree() -> void:
#	if is_network_master():
#		Global.player_master = null
#
#func roll_animation_finished():
#	state = States.IDLE
