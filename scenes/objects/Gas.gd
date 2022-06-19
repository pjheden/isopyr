extends "res://scenes/objects/Trap.gd"

func _on_AliveTimer_timeout() -> void:
	if get_tree().is_network_server():
		rpc("destroy")

sync func destroy() -> void:
	queue_free()
	
