extends KinematicBody2D

export(int) var hitpoints = 100

# const projectile_scene = preload("res://scenes/objects/Projectile.tscn")

func _process(delta):
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("Shoot")
#		var projectile_instance = projectile_scene.instance()
#		projectile_instance.set_network_master(1) # set projectile owner
#		projectile_instance.global_position = global_position + Vector2(40,0)
#		projectile_instance.rotation = 0
#		get_parent().add_child(projectile_instance)
	
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
