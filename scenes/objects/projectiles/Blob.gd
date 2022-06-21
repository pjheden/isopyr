extends "res://scenes/objects/projectiles/Projectile.gd"


func _ready():
	$AnimationPlayer.play("Idle")