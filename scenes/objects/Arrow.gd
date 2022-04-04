extends Area2D

const SPEED = 200
const DAMAGE = 10

func _process(delta):
	# TODO: set speed depending on player
	var speed_x = 1
	var speed_y = 0
	
	var motion = Vector2(speed_x, speed_y) * SPEED
	global_position += motion * delta

func _on_Arrow_area_entered(area):
	print("area", area)
	if area.get_parent().has_method("damage"):
		area.get_parent().damage(DAMAGE)
		queue_free()
