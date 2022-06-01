extends Sprite

export(int) var speed = 750
export(int) var damage = 40

var velocity = Vector2(1, 0)
var player_rotation
var should_move: bool = false
onready var initial_position = global_position

puppet var puppet_position setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0 # direction of projectile

onready var delayed_start: Timer = $DelayedStart


func _ready() -> void:
	if is_network_master():
		velocity = velocity.rotated(player_rotation)
		rotation = player_rotation
		rset("puppet_position", global_position)
		rset("puppet_velocity", velocity)
		rset("puppet_rotation", rotation)
		delayed_start.start()
		
func _process(delta) -> void:
	if not should_move:
		return
	if is_network_master():
		global_position += velocity * speed * delta
	else:
		rotation = puppet_rotation
		global_position += puppet_velocity * speed * delta

puppet func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	global_position = puppet_position

sync func destroy() -> void:
	queue_free()

func _on_Lifespan_timeout():
	if get_tree().is_network_server():
		rpc("destroy")

func _on_Hitbox_body_entered(body):
	print("body entered proj: ", body)
	if body.is_in_group("uncollideable"):
		return
	# rpc destroy caused bugs here, but im not sure what is right
	destroy()
	#if get_tree().is_network_server():
	#	rpc("destroy")


func _on_DelayedStart_timeout():
	should_move = true
