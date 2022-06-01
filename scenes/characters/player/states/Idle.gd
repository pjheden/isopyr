extends State

onready var player = get_parent().get_parent()

func enter(_msg := {}) -> void:
	player.play_animation(player.get_rotation() > 0, "Idle")

func update(_delta: float) -> void:
	if len(player.spell_queue) > 0:
		state_machine.transition_to("Cast")

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