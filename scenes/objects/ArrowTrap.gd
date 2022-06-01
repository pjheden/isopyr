extends StaticBody2D

const projectile_scene = "res://scenes/objects/Rock.tscn"
onready var shoot_timer = $Timer 

func _ready():
	shoot_timer.start()
	Global.add_projectile_scene(projectile_scene)

func shoot():
	Global.projectile(
		1,
		projectile_scene,
		rotation,
		global_position
	)

func _on_Timer_timeout():
	shoot()
