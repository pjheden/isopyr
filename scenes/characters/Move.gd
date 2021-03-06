extends State

var target_position = Vector2()
var pixels_to_move = 100
onready var move_timer = $MoveTimer
onready var sprite = get_node("../../Sprite")

func enter(msg := {}) -> void:
	if "target_position" in msg:
		target_position = msg["target_position"]
	else:
		var mx = rand_range(-pixels_to_move, pixels_to_move)
		var my = rand_range(-pixels_to_move, pixels_to_move)
		target_position = owner.global_position + Vector2(mx, my)
	move_timer.start()

func update(delta: float) -> void:
	move_player(delta)
	# Sometimes we cant reach the target so rely on the timer
	if move_timer.is_stopped():
		state_machine.transition_to("Idle")

func move_player(_delta: float) -> void:
	var dir = target_position - owner.global_position

	# add early stop to prevent shaking close to target pos
	if dir.length() < 3:
		state_machine.transition_to("Idle")
		return
	var velocity = dir.normalized()

	var vel = owner.move_and_slide(velocity * owner.speed)

	# Check how to rotate the player
	sprite.flip_h = vel.x < 0
	#play_animation(vel.y > 0)
	var x_vector = Vector2(1,0)
	get_parent().get_parent().set_rotation(x_vector.angle_to(dir))

func body_detected(b: CollisionObject2D) -> void:
	if b == null:
		return
	if b.is_in_group("Player"):
		state_machine.transition_to("Attack", {"target": b})
