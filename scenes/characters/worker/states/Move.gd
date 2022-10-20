extends State


var target_position: Vector2

onready var player = get_parent().get_parent()

func enter(msg := {}) -> void:
	if "targetPosition" in msg:
		target_position = msg["targetPosition"]
		player.navigation_agent.set_target_location(target_position)

func update(delta: float) -> void:
	player.velocity = Vector2()

	if not target_position:
		state_machine.transition_to("Idle")
		return

	var done_moving: bool = move_player(delta)
	if done_moving:
		state_machine.transition_to("Idle")

func move_player(_delta: float) -> bool:
	# update player position
	player.dir = player.global_position.direction_to(player.navigation_agent.get_next_location())
	
	# add early stop to prevent shaking close to target pos
	# if player.dir.length() < player.move_distance:
	# 	target_position = Vector2()
	# 	return true

	if player.navigation_agent.is_navigation_finished():
		return true
	
	#player.velocity = player.dir.normalized()	

	var vel = player.dir * player.speed
	player.navigation_agent.set_velocity(vel)
	vel = player.move_and_slide(vel)
	
	# Check how to rotate the player
	player.flip_sprite(vel.x < 0)
	player.play_animation(vel.y > 0, "Move")

	var x_vector = Vector2(1,0)
	player.set_rotation(x_vector.angle_to(player.dir))

	return false
