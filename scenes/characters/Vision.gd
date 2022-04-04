extends Line2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation = get_parent().player_rotation
