extends Node2D

onready var player = get_parent()

var eps = 0.01
var max_rotation : float = PI 
var min_rotation : float = -PI
var simple_mode: bool

func calculate_rotation() -> void:
	# Draw arrow towards mouse, limited to players direction +- 90*
	var x_vector = Vector2(1,0)
	var calculated_rotation = x_vector.angle_to(Mouse.global_position - player.global_position)
	if simple_mode:
		if calculated_rotation < min_rotation or calculated_rotation > max_rotation:
			return
		rotation = clamp(calculated_rotation, min_rotation, max_rotation)
	else:
		if calculated_rotation < 0:
			rotation = clamp(calculated_rotation, -PI, min_rotation)
		else:
			rotation = clamp(calculated_rotation, max_rotation, PI)

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