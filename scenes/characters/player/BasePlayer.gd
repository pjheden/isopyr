extends KinematicBody2D

const speed = Vector2(128, 128)
var hud = null # reference to hud

var last_mouse_pos = null
var hp = 100 setget set_hp
var dead = false
var velocity = Vector2()
var dir = Vector2()
var player_rotation = 0

# define states
enum States {DEAD, IDLE, MOVE, ROLL, ATTACK}
var state : int = States.IDLE

puppet var puppet_hp = 100 setget puppet_hp_set
puppet var puppet_position = Vector2() setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_state = state setget puppet_state_set

onready var tween = $MoveTween
onready var hit_timer = $HitTimer
onready var dodge_animation = $Sprite/DodgeAnimation
onready var finish_timer = $FinishDodge 
onready var sprite_scale: Vector2 = $Sprite.scale
var fade_scene = preload("res://scenes/characters/FadingPlayer.tscn")

func _ready():
	if is_network_master():
		Global.player_master = self
		hud = get_parent().get_parent().get_parent().get_node("HUD")
		hud.set_name(Network.players_info[Network.my_id]["name"])

func _input(event) -> void:
	if dead:
		state = States.DEAD
		return
	if not is_network_master():
		# set state to puppet state
		return
	# while we roll we can't do anything else
	if state == States.ROLL:
		return
		
	if event.is_action_pressed("right_click"):
		last_mouse_pos = Mouse.global_position
		state = States.MOVE
	elif event.is_action_pressed("left_click"):
		if $AttackCooldown.get_time_left() == 0.0:
			# play attack animation
			$AnimationPlayer.play("AttackDown")
			state = States.ATTACK
	elif event.is_action_pressed("stop"):
		last_mouse_pos = global_position
		state = States.IDLE
	elif event.is_action_pressed("shift"):
		if $RollCooldown.get_time_left() == 0.0:
			state = States.ROLL
			$RollCooldown.start()

func _process(delta) -> void:
	match state:
		States.DEAD:
			pass
		States.IDLE:
			pass
		States.MOVE:
			move_state(delta)
		States.ROLL:
			roll_state(delta)
		States.ATTACK:
			attack_state(delta)

	if dead:
		return
	if hp <= 0:
		if get_tree().is_network_server():
			rpc("destroy")

func move_state(delta):
	velocity = Vector2()
	# for none network master players we rely on puppet_position_set to move players
	if is_network_master():
		# read player input
		if last_mouse_pos:
			move_player(delta)
	else:
		# if we haven't got a network packet in a while, update player pos
		# based on last recieved velocity
		if not tween.is_active():
			var _vel = move_and_slide(puppet_velocity * speed)
			
func roll_state(_delta: float) -> void:
	if is_network_master():
		velocity = dir.normalized()
		var _vel = move_and_slide(velocity * 3 * speed)

	play_animation(dir.y > 0, "Roll")

func attack_state(_delta: float) -> void:
	# rotate player towards mouse
	dir = Mouse.global_position - global_position
	var x_vector = Vector2(1,0)
	player_rotation = x_vector.angle_to(dir)

func attack_animation_finished() -> void:
	print("base class attack animation finished")
	if is_network_master():
		#rpc("instance_projectile", get_tree().get_network_unique_id())
		# TODO: add attack method depending on subclass?
		pass
	state = States.IDLE
	$AttackCooldown.start()


puppet func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	# Check how to rotate the player
	if state == States.MOVE:
		dir = puppet_position - global_position
		$Sprite.flip_h = dir.x < 0
		play_animation(dir.y > 0)
	
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()

puppet func puppet_state_set(new_value) -> void:
	puppet_state = new_value
	
	if not is_network_master():
		state = puppet_state

func _on_NetworkTickRate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_velocity", velocity)
		rset_unreliable("puppet_state", state)

func play_animation(down: bool, type: String = "Move") -> void:
	match type:
		"Move":
			if down:
				$AnimationPlayer.play("MoveDown")
				$AnimationPlayer.animation_set_next("MoveDown", "IdleDown")
			else:
				$AnimationPlayer.play("MoveTop")
				$AnimationPlayer.animation_set_next("MoveTop", "IdleTop")
		"Roll":
			$AnimationPlayer.play("RollFade")

func move_player(_delta: float) -> void:
	# update player position
	dir = last_mouse_pos - global_position
	
	# add early stop to prevent shaking close to target pos
	if dir.length() < 3:
		last_mouse_pos = null
		state = States.IDLE
		return
	velocity = dir.normalized()
	
	var vel = move_and_slide(velocity * speed)
	
	# Check how to rotate the player
	$Sprite.flip_h = vel.x < 0
	play_animation(vel.y > 0)

	var x_vector = Vector2(1,0)
	player_rotation = x_vector.angle_to(dir)

func set_hp(new_value) -> void:
	hp = new_value
	
	if is_network_master():
		rset("puppet_hp", hp)

puppet func puppet_hp_set(new_value) -> void:
	puppet_hp = new_value
	
	if not is_network_master():
		hp = puppet_hp

func _on_HitTimer_timeout():
	modulate = Color(1, 1, 1, 1)

func _on_Hitbox_area_entered(area):
	if get_tree().is_network_server():
		if area.is_in_group("Player_damager"):
			rpc("hit_by_damager", area.get_parent().damage)
			
			# destroy bullet on server
			area.get_parent().rpc("destroy")

sync func hit_by_damager(damage):
	hp -= damage
	modulate = Color(5, 5, 5, 1)
	hit_timer.start()
	
	if is_network_master():
		hud.update_health_bar(hp)

sync func destroy() -> void:
	print("destroy is called for player: ", get_tree().get_network_unique_id())
	visible = false
	$CollisionPolygon2D.disabled = true
	$Hitbox/CollisionShape2D.disabled = true
	dead = true
	Game.dead(get_network_master())

	if is_network_master():
		Global.player_master = null

func _exit_tree() -> void:
	if is_network_master():
		Global.player_master = null

func roll_animation_finished():
	state = States.IDLE

func spawn_fade() -> void:
	var f = fade_scene.instance()
	# set size
	f.scale = sprite_scale
	# set position
	f.global_position = global_position
	f.rotation = rotation
	get_node("/root/PersistantObjects").add_child(f)
