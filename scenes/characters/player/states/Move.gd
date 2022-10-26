extends State

onready var player = get_parent().get_parent()
var done_moving: bool

# TMP OVERRIDE FOR EASY TESTING
#func is_network_master():
#	return true

func enter(msg := {}) -> void:
	done_moving = false
	# Need to handle the event that caused the transition to not get input lag
	if "event" in msg:
		handle_input(msg["event"])

func update(delta: float) -> void:
	if len(player.spell_queue) > 0:
		state_machine.transition_to("Cast")
		return
	if is_network_master():
		move_player(delta)
		if want_and_can_attack():
			state_machine.transition_to("Attack")
		elif done_moving:
			state_machine.transition_to("Idle")
	# for none network master players we rely on puppet_position_set to move players
	else:
		# if we haven't got a network packet in a while, update player pos
		# based on last recieved velocity
		if not player.tween.is_active():
			var _vel = player.move_and_slide(player.puppet_velocity * player.speed)

func handle_input(event: InputEvent) -> void:
	done_moving = true
	player.velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		player.velocity.x += 1
		done_moving = false
	if Input.is_action_pressed("ui_left"):
		player.velocity.x -= 1
		done_moving = false
	if Input.is_action_pressed("ui_down"):
		player.velocity.y += 1
		done_moving = false
	if Input.is_action_pressed("ui_up"):
		player.velocity.y -= 1
		done_moving = false
	if event.is_action_pressed("shift"):
		if player.roll_cooldown.get_time_left() == 0.0:
			state_machine.transition_to("Roll")

func want_and_can_attack() -> bool:
	return false

func move_player(_delta: float) -> void:
	var vel = player.move_and_slide(player.velocity.normalized() * player.speed)
	
	# Check how to rotate the player
	player.flip_sprite(vel.x < 0)
	player.play_animation(vel.y > 0, "Move")

	#var x_vector = Vector2(1,0)
	#player.set_rotation(x_vector.angle_to(player.dir))
