extends Node2D

# ref to target body
var target_body = null
enum BodyType {DEFAULT, INFO, FRIENDLY, DANGER}
var target_body_type: int = BodyType.DEFAULT

onready var animation_player = $AnimationPlayer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	animation_player.play("Default")

func play_danger(body):
	animation_player.play("Danger")
	target_body = body
	target_body_type = BodyType.DANGER

func play_friendly(body):
	animation_player.play("Friendly")
	target_body = body
	target_body_type = BodyType.FRIENDLY

func play_info(body):
	animation_player.play("Info")
	target_body = body
	target_body_type = BodyType.INFO
	
func is_danger():
	return animation_player.current_animation == "Danger"

func reset():
	animation_player.play("Default")
	target_body = null
	target_body_type = BodyType.DEFAULT

func _process(_delta):
	global_position = get_global_mouse_position()
	#global_position = get_viewport().get_mouse_position()
	#global_position = get_global_transform_with_canvas().origin
