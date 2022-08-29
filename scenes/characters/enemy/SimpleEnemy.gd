extends KinematicBody2D

# constants
export var speed: Vector2 = Vector2(128, 128)
export var hp: float = 100.0
export var team: int = 1

# variables
var player_rotation : float = 0.0

# signals
signal damaged(hp)


# references
onready var hit_timer = $HitTimer

func _ready():
	add_to_group("team_%s" % team)

func get_sm_state() -> String:
	return $StateMachine.state.name

func set_rotation(r: float) -> void:
	player_rotation = r

func get_rotation() -> float:
	return player_rotation

func _on_Hitbox_mouse_entered():
	if team == Global.player_master.get_team():
		Mouse.play_friendly(self)
	else:
		Mouse.play_danger(self)

func _on_Hitbox_mouse_exited():
	Mouse.reset()

func _on_Hitbox_area_entered(area:Area2D):
	if area.is_in_group("Player_damager"):
		var p = area.get_parent()
		if not p.has_method("get_team"):
			return
		if self.team == p.get_team():
			return
		hit_by_damager(p.damage)

func hit_by_damager(damage):
	hp -= damage
	modulate = Color(5, 5, 5, 1)
	hit_timer.start()
	emit_signal("damaged", hp)

	if hp <= 0:
		# if get_tree().is_network_server():
		if true:
			queue_free()
			rpc("destroy")
	
func _on_HitTimer_timeout():
	modulate = Color(1, 1, 1, 1)

sync func destroy() -> void:
	queue_free()
