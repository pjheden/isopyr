extends Sprite

export(int) var damage = 10

var team: int

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
		if not body.has_method("hit_by_damager"):
			continue
		if body.has_method("get_team") and team == body.team:
			continue
		body.hit_by_damager(damage)

func set_team(new_team: int) -> void:
	team = new_team

func get_team() -> int:
	return team