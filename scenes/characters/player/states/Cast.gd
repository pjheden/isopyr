extends State

onready var player = get_parent().get_parent()
onready var cast_timer: Timer = $CastTime

var casting: bool
var casting_key: String

func enter(_msg := {}) -> void:
	#player.play_animation(player.get_rotation() > 0, "Idle")
	pass

func update(_delta: float) -> void:
	if len(player.spell_queue) == 0:
		# TODO: ought to transition to Attack if that was the previous state
		if not casting:
			state_machine.transition_to("Idle")
		return
	
	casting_key = player.spell_queue[0]
	var spell_manager = player.spell_bindings[casting_key]
	if spell_manager.is_ready():
		var casting_time: float = spell_manager.cast_time
		casting = true
		cast_timer.start(casting_time)
	player.spell_queue.erase(casting_key)

func exit() -> void:
	# Reset cast timer
	cast_timer.stop()

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


func _on_CastTime_timeout():
	# consume and cast first spell
	# var casted: bool = player.spell_bindings[casting_key].call_func({"team": player.get_team()})
	# TODO: change initialization of spells for all heroes
	var casted: bool = player.spell_bindings[casting_key].activate({"team": player.get_team()})
	print("casted: %s" % casted)
	if casted:
		player.hud.casted_spell(casting_key)
	casting = false
