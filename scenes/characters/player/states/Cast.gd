extends State

onready var player = get_parent().get_parent()
var casting: bool

func enter(_msg := {}) -> void:
	#player.play_animation(player.get_rotation() > 0, "Idle")
	pass

func update(_delta: float) -> void:
	if len(player.spell_queue) == 0 and not casting:
		# TODO: ought to transition to Attack if that was the previous state
		if not casting:
			state_machine.transition_to("Idle")
		return

	# consume and cast first spell
	var spell_key: String = player.spell_queue[0]
	var casted: bool = player.spell_bindings[spell_key].call_func({"team": player.get_team()})
	print("casted: %s" % casted)
	if casted:
		player.hud.casted_spell(spell_key)
	player.spell_queue.erase(spell_key)

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed(Global.move_button):
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
