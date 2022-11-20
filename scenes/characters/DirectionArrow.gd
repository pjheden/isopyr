extends Node2D

onready var player = get_parent()

var eps = 0.01
var max_rotation : float = PI 
var min_rotation : float = -PI
var simple_mode: bool

func calculate_rotation() -> void:
	# Draw arrow towards mouse, limited to players direction +- 90*
	var x_vector = Vector2(1,0)
	var calc_rot = x_vector.angle_to(Mouse.global_position - player.global_position)
	if simple_mode:
		rotation = clamp(calc_rot, min_rotation, max_rotation)
	else:
		if calc_rot < 0:
			rotation = clamp(calc_rot, -PI, min_rotation)
		else:
			rotation = clamp(calc_rot, max_rotation, PI)

func _process(_delta):
	if not visible or not player:
		return
	calculate_rotation()


func min_max_rotation_set(new_min_rotation: float, new_max_rotation: float, new_dir_x: int) -> void:
	simple_mode = true
	if new_dir_x < 0:
		simple_mode = false

	min_rotation = clamp(new_min_rotation, -PI, PI)
	max_rotation = clamp(new_max_rotation, -PI, PI)
	calculate_rotation()