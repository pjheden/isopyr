extends "res://scenes/objects/projectiles/Projectile.gd"

export var rotation_speed: float = 1.0

func _on_process(delta: float) -> void:
	._on_process(delta)
	rotation += rotation_speed * delta