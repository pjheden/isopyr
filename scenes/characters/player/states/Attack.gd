extends State

onready var player = get_parent().get_parent()

var autoattack: Node2D
var direction_arrow: Node2D

func enter(_msg := {}) -> void:
	# TODO: check cd here?
	player.play_animation(true, "Attack")
	direction_arrow = player.get_node("DirectionArrow")
	direction_arrow.visible = true
	if player.dir.x == 1:
		direction_arrow.min_max_rotation_set(-PI/4, PI/4, player.dir.x)
	else:
		direction_arrow.min_max_rotation_set(-3*PI/4, 3*PI/4, player.dir.x)
	
	autoattack = player.get_node("Autoattack")


func update(_delta: float) -> void:
	# set rotation of autoattack
	autoattack.set_rotation(direction_arrow.rotation)

func exit() -> void:
	pass

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"):
		state_machine.transition_to("Move", {"event": event})
	elif event.is_action_pressed("shift"):
		if player.roll_cooldown.get_time_left() == 0.0:
			state_machine.transition_to("Roll")

func _on_Basicattack_body_entered(body:Node):
	if body.has_method("hit_by_physical_damager"):
		body.hit_by_physical_damager(player.attack_damage)

