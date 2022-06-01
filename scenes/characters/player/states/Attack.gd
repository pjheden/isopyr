extends State

var target_body
var target_body_type

onready var player = get_parent().get_parent()
onready var attack_timer = $AttackCooldown

func enter(msg := {}) -> void:
	player.play_animation(true, "Attack")
	
	if "targetBody" in msg:
		target_body = msg["targetBody"]
	if "targetBodyType" in msg:
		target_body_type = msg["targetBodyType"]

func update(_delta: float) -> void:
	if target_dead():
		state_machine.transition_to("Idle")
		return
	
	# Check if target is too far away
	var dir = target_body.global_position - player.global_position
	if dir.length() > player.attack_distance:
		state_machine.transition_to(
			"Move",
			{
				"targetPosition": target_body.global_position,
				"targetBody": target_body,
				"targetBodyType": target_body_type,
			}
		)
	
	attack_player()

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		state_machine.transition_to(
			"Move",
			{
				"targetPosition": Mouse.global_position,
				"targetBody": Mouse.target_body,
				"targetBodyType": Mouse.target_body_type,
			}
		)
	elif event.is_action_pressed("shift"):
		if player.roll_cooldown.get_time_left() == 0.0:
			state_machine.transition_to("Roll")
	
func target_dead() -> bool:
	# check if body is freed
	if not is_instance_valid(target_body):
		return true

	if not target_body:
		return true
	
	#TODO: call method to check if body is dead
	return false

func attack_player() -> void:
	if attack_timer.is_stopped():
		if target_body.has_method("hit_by_damager"):
			target_body.hit_by_damager(player.attack_damage)
			attack_timer.start()
