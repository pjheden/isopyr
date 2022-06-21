extends "res://scenes/objects/projectiles/Projectile.gd"


var target_body: PhysicsBody2D = null

enum states {WAITING, MOVE, ATTACK}
var state: int = states.WAITING

var gas_scene = preload("res://scenes/objects/aoes/Gas.tscn")


func _ready():
	$AnimationPlayer.play("Idle")

func closest_body(bodies: Array) -> Dictionary:
	var closest_b = bodies[0]
	var closest_d: float = 9999.0
	for body in bodies:
		var d = global_position.distance_to(body.global_position)
		if d < closest_d:
			closest_b = body
			closest_d = d
	return {"body": closest_b, "distance": closest_d}


func _on_process(delta: float) -> void:
	match state:
		states.WAITING:
			# iterate over all enemy players go towards closest one
			var players = Global.get_players(team)
			if len(players) > 0:
				target_body = closest_body(players).body
			if target_body != null:
				state = states.MOVE
		states.MOVE:
			var dir = target_body.global_position - global_position

			if dir.length() < 3:
				state = states.ATTACK
				return

			velocity = dir.normalized()
			global_position += velocity * speed * delta
			# Check how to rotate the player
			flip_h = dir.x < 0
			#play_animation(vel.y > 0)
			var x_vector = Vector2(1,0)
			set_rotation(x_vector.angle_to(dir))
		states.ATTACK:
			if get_tree().is_network_server():
				rpc("destroy")
	
sync func destroy() -> void:
	var master_id = get_network_master()
	var gas = gas_scene.instance()
	gas.global_position = global_position
	gas.set_network_master(master_id)
	gas.name = "Gas" + str(master_id) + "_" +str(Network.networked_object_name_index)
	gas.set_team(team)
	Network.networked_object_name_index += 1
	get_node("/root/world/Traps").add_child(gas)
	queue_free()
