extends Sprite

onready var timer = $Timer
onready var collision_shape = $Area2D/CollisionPolygon2D

func activate() -> void:
	visible = true
	collision_shape.disabled = false
	timer.start()

func deactivate() -> void:
	visible = false
	collision_shape.disabled = true


func _on_Area2D_area_entered(area):
	if get_tree().is_network_server():
		if area.is_in_group("Player_damager"):
			# destroy bullet on server
			area.get_parent().rpc("destroy")
