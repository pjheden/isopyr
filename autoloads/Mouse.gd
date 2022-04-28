extends Node2D

# ref to target body
var target_body = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$AnimationPlayer.play("Default")

func play_danger(body):
	$AnimationPlayer.play("Danger")
	target_body = body

func play_friendly(body):
	$AnimationPlayer.play("Friendly")
	target_body = body

func play_info(body):
	$AnimationPlayer.play("Info")
	target_body = body
	
func is_danger():
	return $AnimationPlayer.current_animation == "Danger"

func reset():
	$AnimationPlayer.play("Default")
	target_body = null

func _process(_delta):
	global_position = get_global_mouse_position()
	#global_position = get_viewport().get_mouse_position()
	#global_position = get_global_transform_with_canvas().origin
