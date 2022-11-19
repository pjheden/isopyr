extends Node2D


onready var collision_node = get_node("Sprite/Basicattack/CollisionPolygon2D")
onready var animation_player = $AnimationPlayer

var new_rotation: float

func _ready():
	pass

func set_rotation(new_rot: float) -> void:
	# set new rotation to be applied on next animation
	new_rotation = new_rot
	# if no animation is playing we instantly apply
	if not animation_player.is_playing():
		rotation = new_rot

func attack() -> void:
	# play animation
	animation_player.play("Autoattack")
	# Ensure the collision is off after animation
	var duration = animation_player.get_animation("Autoattack").length
	yield(get_tree().create_timer(duration), "timeout")
	collision_node.disabled = true
	rotation = new_rotation
