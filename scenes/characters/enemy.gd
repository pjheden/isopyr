extends KinematicBody2D

export(int) var hitpoints = 100

func _on_Area2D_mouse_entered():
	Mouse.play_danger(self)

func _on_Area2D_mouse_exited():
	Mouse.reset()

func damage(amount):
	hitpoints -= amount
	print("took damage ", amount, " got left ", hitpoints)
	if hitpoints <= 0:
		$HPbar.value = 0
		Mouse.reset()
		queue_free()
		return true
	$HPbar.value = hitpoints
	return false
