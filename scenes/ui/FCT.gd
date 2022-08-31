extends Label

func show_value(value, travel, duration, spread, crit=false):
	# Set Label text
	text = value

	# Define tween movement
	var movement = travel.rotated(rand_range(-spread/2, spread/2))
	$Tween.interpolate_property(self, "rect_position",
			rect_position, rect_position + movement,
			duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "modulate:a",
			1.0, 0.0, duration,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			
	# Handle crit
	if crit:
		modulate = Color(1, 0, 0)
		$Tween.interpolate_property(self, "rect_scale",
			rect_scale*2, rect_scale,
			0.4, Tween.TRANS_BACK, Tween.EASE_IN)
	
	# Start tween and free on completion
	$Tween.start()
	yield($Tween, "tween_all_completed")
	queue_free()
