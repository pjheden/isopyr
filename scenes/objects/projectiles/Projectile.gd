extends Sprite

export(int) var speed = 750
export(int) var damage = 40

var velocity = Vector2(1, 0)
var player_rotation
var should_move: bool = false
var team: int

puppet var puppet_position setget puppet_position_set
puppet var puppet_velocity = Vector2() setget puppet_velocity_set
puppet var puppet_rotation = 0 setget puppet_rotation_set # direction of projectile

onready var delayed_start: Timer = $DelayedStart


func _ready() -> void:
	print("proj is ready for %s, master %s" % [Network.my_id, is_network_master()])
	if is_network_master():
		print("setting values for proj: %s %s" % [velocity, rotation])
		velocity = velocity.rotated(player_rotation)
		rotation = player_rotation
		rset("puppet_position", global_position)
		rset("puppet_velocity", velocity)
		rset("puppet_rotation", rotation)
	delayed_start.start()
		
func _process(delta: float) -> void:
	_on_process(delta)

func _on_process(delta: float) -> void:
	if not should_move:
		return
	if is_network_master():
		global_position += velocity * speed * delta
	else:
		rotation = puppet_rotation
		global_position += puppet_velocity * speed * delta

puppet func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	if not is_network_master():
		global_position = puppet_position

puppet func puppet_velocity_set(new_value) -> void:
	puppet_velocity = new_value

puppet func puppet_rotation_set(new_value) -> void:
	puppet_rotation = new_value

sync func destroy() -> void:
	queue_free()

func _on_Lifespan_timeout():
	if get_tree().is_network_server():
		rpc("destroy")

func _on_Hitbox_body_entered(body):
	# This is never called?

	print("body entered proj: ", body)
	var body_team = "team_%s" % team
	print(body.is_in_group(body_team))
	print(body.get_parent().is_in_group(body_team))
	if body.is_in_group("uncollideable"):
		return
	# rpc destroy caused bugs here, but im not sure what is right
	destroy()
	#if get_tree().is_network_server():
	#	rpc("destroy")

func _on_DelayedStart_timeout():
	should_move = true

func set_team(new_team: int) -> void:
	assert(new_team in Global.Team.values(), "the function argument is expected to be a Team value")
	team = new_team

func get_team() -> int:
	return team
