extends State

onready var player = get_parent().get_parent()

func enter(_msg := {}) -> void:
	player.flip_sprite(player.dir.x < 0)
	player.play_animation(player.get_rotation() > 0, "Idle")
