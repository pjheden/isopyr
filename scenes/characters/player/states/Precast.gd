extends State

onready var player = get_parent().get_parent()

var casting: bool
var casting_key: String

func enter(_msg := {}) -> void:
	pass

func update(_delta: float) -> void:

	if len(player.spell_queue) == 0:
		if not casting:
			state_machine.transition_to("Idle")
		return
	
	casting_key = player.spell_queue[0]
	var spell_manager = player.spell_bindings[casting_key]
	if spell_manager.is_ready():
		# check type of spell, poc: assume its projectile directional
		pass

	#player.spell_queue.erase(casting_key)


func exit() -> void:
	pass

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("shift"):
		if player.roll_cooldown.get_time_left() == 0.0:
			state_machine.transition_to("Roll")