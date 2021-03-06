extends KinematicBody2D

# Player constants
export var speed = Vector2(128, 128)
export var move_distance = 16
export var attack_distance = 30
export var attack_damage = 10
# Player variables 
var id: int # RPC id
var hp: float = 100.0 setget set_hp
var team: int
var player_rotation : float = 0.0
var velocity: Vector2
var dir: Vector2
var spell_queue: Array = []
var spell_bindings: Dictionary = {}
#var defined_animations: Array = ["IdleDown", "IdleTop", "MoveDown", "MoveTop", "RollFade", "AttackDown"]
var defined_animations: Dictionary = {
	"IdleDown": "IdleDown",
	"IdleTop": "IdleTop",
	"MoveDown": "MoveDown",
	"MoveTop": "MoveTop",
	"RollFade": "RollFade",
	"AttackDown": "AttackDown"
}

# Puppet player variables
puppet var puppet_hp = 100 setget puppet_hp_set
puppet var puppet_velocity = Vector2()
puppet var puppet_position = Vector2() setget puppet_position_set
puppet var puppet_state: String = "" setget puppet_state_set

# References
var hud: CanvasLayer = null # reference to hud
onready var animation_player = $AnimationPlayer 
onready var sprite = $Sprite
onready var roll_cooldown = $RollCooldown
onready var sprite_scale: Vector2 = $Sprite.scale
onready var tween = $MoveTween
onready var state_machine = $StateMachine
onready var hit_timer = $HitTimer

func _ready() -> void:
	print("preparing player: %s %s " % [Network.my_id, is_network_master()])
	if is_network_master():
		Global.player_master = self
		hud = get_parent().get_parent().get_parent().get_node("HUD")
		hud.set_name(Game.player_info[int(name)]["name"])
	# Prepare player spells
	spells(is_network_master())
	add_to_group("team_%s" % team)

func _input(event) -> void:
	if not is_network_master():
		return
	# Check if any spell button is pressed
	for hotkey in spell_bindings:
		if event.is_action_pressed(hotkey):
			spell_queue.append(hotkey)

func spells(_is_master: bool) -> void:
	"""
	Virtual method. setup all the class spells
	"""
	assert(false, "spells is a virtual method and must be implented")

func get_sm_state() -> String:
	return state_machine.state.name

func set_rotation(r: float) -> void:
	player_rotation = r

func get_rotation() -> float:
	return player_rotation

func flip_sprite(flip: bool) -> void:
	sprite.flip_h = flip

func set_team(new_team: int) -> void:
	team = new_team
	add_to_group("team_%s" % new_team)

func get_team() -> int:
	return team

func play_animation(down: bool, type: String = "Move") -> void:
	match type:
		"Idle":
			if down:
				animation_player.play(defined_animations["IdleDown"])
			else:
				animation_player.play(defined_animations["IdleTop"])
		"Move":
			if down:
				animation_player.play(defined_animations["MoveDown"])
				animation_player.animation_set_next(defined_animations["MoveDown"], defined_animations["IdleDown"])
			else:
				animation_player.play(defined_animations["MoveTop"])
				animation_player.animation_set_next(defined_animations["MoveTop"], defined_animations["IdleTop"])
		"Roll":
			animation_player.play(defined_animations["RollFade"])
		"Attack":
			animation_player.play(defined_animations["AttackDown"])

func set_hp(new_value) -> void:
	hp = new_value
	
	if is_network_master():
		rset("puppet_hp", hp)

func _on_Hitbox_mouse_entered():
	if team == Global.player_master.get_team():
		Mouse.play_friendly(self)
	else:
		Mouse.play_danger(self)

func _on_Hitbox_mouse_exited():
	Mouse.reset()

func _on_Hitbox_area_entered(area:Area2D):
	# server hit detection
	if not get_tree().is_network_server():
		return
	if area.is_in_group("Player_damager"):
		var p = area.get_parent()
		if not p.has_method("get_team"):
			return
		if self.team == p.get_team():
			return
		#hit_by_damager(p.damage)
		rpc("hit_by_damager", p.damage)
		


func hit_by_physical_damager(damage):
	rpc("hit_by_damager", damage)

sync func hit_by_damager(damage):
	hp -= damage
	modulate = Color(5, 5, 5, 1)
	hit_timer.start()
	if hud:
		hud.update_health_bar(hp)

	if hp <= 0:
		if get_tree().is_network_server():
			#queue_free()
			rpc("destroy")
	
func _on_HitTimer_timeout():
	modulate = Color(1, 1, 1, 1)

sync func destroy() -> void:
	print("destroy is called for player: ", get_tree().get_network_unique_id())
	visible = false
	$CollisionPolygon2D.disabled = true
	$Hitbox/CollisionShape2D.disabled = true
	#dead = true
	Game.dead(get_network_master())

	if is_network_master():
		Global.player_master = null

func _on_NetworkTickRate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_velocity", velocity)
		rset_unreliable("puppet_state", get_sm_state())

puppet func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	# Check how to rotate the player
	# if state == States.MOVE:
	# 	dir = puppet_position - global_position
	# 	$Sprite.flip_h = dir.x < 0
	# 	play_animation(dir.y > 0)
	
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()

puppet func puppet_hp_set(new_value) -> void:
	puppet_hp = new_value

	if not is_network_master():
		hp = puppet_hp

puppet func puppet_state_set(new_value) -> void:
	puppet_state = new_value

	if not is_network_master():
		state_machine.transition_to(puppet_state)
