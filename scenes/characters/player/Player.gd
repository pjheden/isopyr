extends "res://scenes/characters/Character.gd"

# constants

# variables 
var id: int # RPC id
var spell_queue: Array = []
var spell_bindings: Dictionary = {}

# Puppet variables
puppet var puppet_hp = 100 setget puppet_hp_set
puppet var puppet_velocity = Vector2()
puppet var puppet_position = Vector2() setget puppet_position_set
puppet var puppet_flip: bool = false setget puppet_flip_set
puppet var puppet_state: String = "" setget puppet_state_set
puppet var puppet_animation: Dictionary = {} setget puppet_animation_set

# References
var hud: CanvasLayer = null # reference to hud
onready var roll_cooldown = $RollCooldown
onready var tween = $MoveTween

func _ready() -> void:
	if is_network_master():
		Global.player_master = self
		hud = get_parent().get_parent().get_parent().get_node("HUD")
		hud.set_name(Game.players_info[int(name)]["name"])
		hud.update_health_bar(hp)
	# Prepare player spells
	spells(is_network_master())
	add_to_group("player")

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

func flip_sprite(flip: bool) -> void:
	.flip_sprite(flip)
	if is_network_master():
		rset("puppet_flip", flip)

sync func hit_by_damager(damage):
	fct_manager.show_value(damage)
	hp -= damage
	modulate = Color(5, 5, 5, 1)
	hit_timer.start()
	if hud:
		hud.update_health_bar(hp)

	if hp <= 0:
		if get_tree().is_network_server():
			rpc("destroy")
	
sync func destroy() -> void:
	print("destroy is called for player: ", get_tree().get_network_unique_id())
	visible = false
	$CollisionPolygon2D.disabled = true
	$Hitbox/CollisionShape2D.disabled = true
	#dead = true
	Game.dead(get_network_master())
	state_machine.transition_to("Dead")

	if is_network_master():
		Global.player_master = null

	queue_free()

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
