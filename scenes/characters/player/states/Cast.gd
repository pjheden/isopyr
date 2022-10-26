extends State

onready var player = get_parent().get_parent()
onready var cast_timer: Timer = $CastTime

var casting: bool
var casting_key: String

func enter(_msg := {}) -> void:
	pass

func update(_delta: float) -> void:
	if casting:
		player.hud.update_cast_bar(cast_timer.wait_time, cast_timer.time_left)

	if len(player.spell_queue) == 0:
		if not casting:
			state_machine.transition_to("Idle")
		return
	
	casting_key = player.spell_queue[0]
	var spell_manager = player.spell_bindings[casting_key]
	if spell_manager.is_ready():
		var casting_time: float = spell_manager.cast_time
		play_cast_animation(spell_manager.animation_name, casting_time)
		casting = true
		if casting_time == 0.0:
			_on_CastTime_timeout()
		else:
			cast_timer.start(casting_time)
	player.spell_queue.erase(casting_key)

func play_cast_animation(animation_name: String, casting_time: float) -> void:
	if "modulate" in animation_name:
		player.modulate = Color(1,1,cast_timer.time_left / cast_timer.wait_time,1)
	else:
		player.play_animation(true, animation_name, casting_time)


func exit() -> void:
	player.modulate = Color(1,1,1,1)
	# Reset cast timer
	cast_timer.stop()

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("shift"):
		if player.roll_cooldown.get_time_left() == 0.0:
			state_machine.transition_to("Roll")


func _on_CastTime_timeout():
	# consume and cast first spell
	var casted: bool = player.spell_bindings[casting_key].activate({"team": player.get_team()})
	print("casted: %s" % casted)
	if casted:
		player.hud.casted_spell(casting_key)
	casting = false
