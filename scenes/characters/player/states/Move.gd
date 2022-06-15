extends State


var target_position: Vector2
var target_body
var target_body_type

onready var tween = $MoveTween
onready var player = get_parent().get_parent()

# TMP OVERRIDE FOR EASY TESTING
func is_network_master():
	return true

func enter(msg := {}) -> void:
	target_position = msg["targetPosition"]
	if "targetBody" in msg:
		target_body = msg["targetBody"]
	if "targetBodyType" in msg:
		target_body_type = msg["targetBodyType"]
	print("Move got msg: ", msg)

func update(delta: float) -> void:
	if len(player.spell_queue) > 0:
		state_machine.transition_to("Cast")
		return
	
	player.velocity = Vector2()
	# for none network master players we rely on puppet_position_set to move players
	if is_network_master():
		if not target_position:
			return
		
		if target_body:
			if not is_instance_valid(target_body):
				target_body = null
				target_body_type = 0
				return
			target_position = target_body.global_position

		var done_moving: bool = move_player(delta)
		if want_and_can_attack():
			state_machine.transition_to(
				"Attack",
				{
					"targetBody": target_body,
					"targetBodyType": target_body_type,
				}
			)
		if done_moving:
			state_machine.transition_to("Idle")
	else:
		# if we haven't got a network packet in a while, update player pos
		# based on last recieved velocity
		if not tween.is_active():
			var _vel = player.move_and_slide(player.puppet_velocity * player.speed)

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed(Global.move_button):
		target_position = Mouse.global_position
		target_body = Mouse.target_body
		target_body_type = Mouse.target_body_type
	elif event.is_action_pressed("shift"):
		if player.roll_cooldown.get_time_left() == 0.0:
			state_machine.transition_to("Roll")

func want_and_can_attack() -> bool:
	if target_body_type != Mouse.BodyType.DANGER:
		return false

	var target_vector = target_position - player.global_position
	if target_vector.length() < player.attack_distance:
		return true

	return false

func move_player(_delta: float) -> bool:
	# update player position
	player.dir = target_position - player.global_position
	
	# add early stop to prevent shaking close to target pos
	if player.dir.length() < player.move_distance:
		target_position = Vector2()
		return true
	player.velocity = player.dir.normalized()
	
	var vel = player.move_and_slide(player.velocity * player.speed)
	
	# Check how to rotate the player
	player.flip_sprite(vel.x < 0)
	player.play_animation(vel.y > 0, "Move")

	var x_vector = Vector2(1,0)
	player.set_rotation(x_vector.angle_to(player.dir))

	return false
