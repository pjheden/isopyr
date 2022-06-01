extends Sprite

export(int) var damage = 10

puppet var puppet_position setget puppet_position_set

var bodies_in_range = []

func _ready() -> void:
	if is_network_master():
		rset("puppet_position", global_position)

puppet func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	global_position = puppet_position

sync func destroy() -> void:
	queue_free()

func _on_Hitbox_body_entered(body):
	bodies_in_range.append(body)

func _on_Hitbox_body_exited(body):
	var body_exited_name = body.get_name()
	for b in bodies_in_range:
		if body_exited_name == b.get_name():
			bodies_in_range.erase(b)
			return

func _on_DamageTimer_timeout():
	for body in bodies_in_range:
		if body.has_method("hit_by_damager"):
			body.hit_by_damager(damage)
