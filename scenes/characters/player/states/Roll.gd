extends State

onready var player = get_parent().get_parent()

onready var fade_scene = preload("res://scenes/characters/FadingPlayer.tscn")

func enter(_msg := {}) -> void:
	player.roll_cooldown.start()

func update(_delta: float) -> void:
	if is_network_master():
		player.velocity = player.dir.normalized()
		var _vel = player.move_and_slide(player.velocity * 3 * player.move_speed)

	player.play_animation(player.dir.y > 0, "Roll")

func roll_finished() -> void:
	state_machine.transition_to("Idle")

func spawn_fade() -> void:
	var f = fade_scene.instance()
	# set size
	f.scale = player.sprite_scale
	# set position
	f.global_position = player.global_position
	f.rotation = player.rotation
	get_node("/root/PersistantObjects").add_child(f)