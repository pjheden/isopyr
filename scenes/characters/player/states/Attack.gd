extends State

onready var player = get_parent().get_parent()

func enter(_msg := {}) -> void:
	# TODO: check cd here?
	player.play_animation(true, "Attack")

func update(_delta: float) -> void:
	# attack_player() # called at the end of animation instead
	pass

func exit() -> void:
	# If the attack animation is exited early the attack hitbox might still be enabled
	# ensure the attack hitbox is turned off
	player.get_node("Sprite/Basicattack/CollisionPolygon2D").disabled = true

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"):
		state_machine.transition_to("Move", {"event": event})
	elif event.is_action_pressed("shift"):
		if player.roll_cooldown.get_time_left() == 0.0:
			state_machine.transition_to("Roll")

func _on_Basicattack_body_entered(body:Node):
	if body.has_method("hit_by_physical_damager"):
		body.hit_by_physical_damager(player.attack_damage)

