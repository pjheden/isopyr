extends "res://scenes/characters/states/Idle.gd"

func update(_delta: float) -> void:
	if len(player.spell_queue) > 0:
		state_machine.transition_to("Cast")
		return

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"):
		state_machine.transition_to("Move", {"event": event})
	elif event.is_action_pressed("space"):
		state_machine.transition_to("Attack")
	elif event.is_action_pressed("shift"):
		if player.roll_cooldown.get_time_left() == 0.0:
			state_machine.transition_to("Roll")
