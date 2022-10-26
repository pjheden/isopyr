extends Sprite

var dir = Vector2()
var move_distance = 32
var speed = Vector2(254, 254)
var last_target_position = Vector2()
# Set variables when instancing Dove
var target: Node # Target to deliver to
var message: int # Message to deliver

func _process(delta):
	if not target or not message:
		return

	if target.is_inside_tree():
		last_target_position = target.global_position

	if not last_target_position:
		return

	dir = global_position.direction_to(last_target_position)
	
	# add early stop to prevent shaking close to target pos
	if global_position.distance_squared_to(last_target_position) < move_distance:
		deliver_message()
		return
	
	var velocity = dir * speed
	global_position += velocity * delta

func deliver_message():
	target.change_order(message)
	queue_free()