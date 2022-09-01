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
puppet var puppet_flip: bool = false setget puppet_flip_set
puppet var puppet_state: String = "" setget puppet_state_set
puppet var puppet_animation: Dictionary = {} setget puppet_animation_set

# References
var hud: CanvasLayer = null # reference to hud
onready var animation_player = $AnimationPlayer 
onready var sprite = $Sprite
onready var roll_cooldown = $RollCooldown
onready var sprite_scale: Vector2 = $Sprite.scale
onready var tween = $MoveTween
onready var state_machine = $StateMachine
onready var hit_timer = $HitTimer
onready var fct_manager = $FCTManager

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

func set_rotation(r: float) -> void:
	player_rotation = r

func get_rotation() -> float:
	return player_rotation

func flip_sprite(flip: bool) -> void:
	if is_network_master():
		rset("puppet_flip", flip)
	sprite.flip_h = flip


func set_team(new_team: int) -> void:
	team = new_team
	add_to_group("team_%s" % new_team)

func get_team() -> int:
	return team

func calculate_animation_custom_speed(type: String, target_time: float) -> float:
	if target_time == 0.0:
		return 1.0

	match type:
		"Attack":
			var animation_time: float = animation_player.get_animation(defined_animations["AttackDown"]).length
			return animation_time / target_time
		"SpellQ":
			var animation_time: float = animation_player.get_animation(defined_animations["SpellQ"]).length

			return animation_time / target_time
		"SpellW":
			var animation_time: float = animation_player.get_animation(defined_animations["SpellW"]).length
			return animation_time / target_time
	
	return 1.0

func play_animation(down: bool, type: String = "Move", target_time: float = 0.0) -> void:
	if is_network_master():
		# Announce animation to puppets
		rset("puppet_animation", {"down": down, "type": type, "target_time": target_time})

	var custom_speed: float = calculate_animation_custom_speed(type, target_time)

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
			animation_player.play(defined_animations["AttackDown"], -1, custom_speed)
		"SpellQ":
			animation_player.play(defined_animations["SpellQ"], -1, custom_speed)
		"SpellW":
			animation_player.play(defined_animations["SpellW"], -1, custom_speed)

func set_hp(new_value) -> void:
	hp = new_value
	
	if is_network_master():
		rset("puppet_hp", hp)

func _on_Hitbox_mouse_entered():
	if is_network_master() or (team != Global.Team.NONE and team == Global.player_master.get_team()):
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
		if self.team != Global.Team.NONE and self.team == p.get_team():
			return
		# If the player and area are have same network master we ignore (no self-harm)
		if get_network_master() == area.get_network_master():
			return
		#hit_by_damager(p.damage)
		rpc("hit_by_damager", p.damage)
		


func hit_by_physical_damager(damage):
	rpc("hit_by_damager", damage)

sync func hit_by_damager(damage):
	fct_manager.show_value(damage)
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

puppet func puppet_animation_set(new_value: Dictionary) -> void:
	puppet_animation = new_value

	if not is_network_master():
		play_animation(puppet_animation.down, puppet_animation.type, puppet_animation.target_time)

puppet func puppet_flip_set(new_value: bool) -> void:
	puppet_flip = new_value

	if not is_network_master():
		flip_sprite(puppet_flip)

func _on_StateMachine_transitioned(state_name:String):
	if is_network_master():
		rset("puppet_state", state_name)
