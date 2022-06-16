extends Sprite

export(int) var damage = 10

var team: int
var player_rotation
var bodies_in_range = []
var should_damage: bool

onready var initial_position = global_position

puppet var puppet_position setget puppet_position_set
puppet var puppet_rotation = 0 # direction of projectile

onready var life_span: Timer = $LifeSpan


func _ready() -> void:
	modulate = "7f000000" # set low opacity and color to begin with
	if is_network_master():
		rset("puppet_position", global_position)
		rset("puppet_rotation", rotation)
	else:
		rotation = puppet_rotation


puppet func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	global_position = puppet_position

sync func destroy() -> void:
	queue_free()

func _on_DelayedStart_timeout():
	modulate = "ffffff" # set normal color
	should_damage = true
	life_span.start()

func _on_DamageTick_timeout():
	if not should_damage:
		return
	for body in bodies_in_range:
		if is_instance_valid(body) and body.has_method("hit_by_damager"):
			body.hit_by_damager(damage)

func set_team(new_team: int) -> void:
	assert(new_team in Global.Team.values(), "the function argument is expected to be a Team value")
	team = new_team

func get_team() -> int:
	return team


func _on_LifeSpan_timeout():
	print("lifespan timeout")
	if get_tree().is_network_server():
		rpc("destroy")

func _on_Hitbox_body_entered(body:Node):
	var aoe_team = "team_%s" % team
	if body.is_in_group("uncollideable") or body.is_in_group(aoe_team):
		return
	bodies_in_range.append(body)

func _on_Hitbox_body_exited(body:Node):
	var body_exited_name = body.get_name()
	for b in bodies_in_range:
		if body_exited_name == b.get_name():
			bodies_in_range.erase(b)
			return
