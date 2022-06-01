extends KinematicBody2D

# Player constants
export var speed = Vector2(128, 128)
export var move_distance = 16
export var attack_distance = 20
export var attack_damage = 10
# Player variables 
var id: int # RPC id
var player_rotation : float = 0.0
var velocity: Vector2
var dir: Vector2
var spell_queue: Array = []
var spell_bindings: Dictionary = {}

# Puppet player variables
puppet var puppet_velocity = Vector2()

# References
var hud: CanvasLayer = null # reference to hud
onready var animation_player = $AnimationPlayer 
onready var sprite = $Sprite
onready var roll_cooldown = $RollCooldown
onready var sprite_scale: Vector2 = $Sprite.scale

func _ready() -> void:
	Global.player_master = self # TMP TEST

	hud = get_parent().get_parent().get_parent().get_node("HUD")
	# Prepare player spells
	spells()

# func _process(_delta: float) -> void:
# 	for sq in spell_queue:
# 		spell_bindings[sq].call_func()
# 		hud.casted_spell(0) #TODO: point to right spell
# 		spell_queue.erase(sq)

func _input(event) -> void:
	# Check if any spell button is pressed
	for hotkey in spell_bindings:
		if event.is_action_pressed(hotkey):
			spell_queue.append(hotkey)

func spells() -> void:
	"""
	Virtual method. setup all the class spells
	"""
	assert(false)

func get_sm_state() -> String:
	return $StateMachine.state.name

func set_rotation(r: float) -> void:
	player_rotation = r

func get_rotation() -> float:
	return player_rotation

func flip_sprite(flip: bool) -> void:
	sprite.flip_h = flip

func play_animation(down: bool, type: String = "Move") -> void:
	match type:
		"Idle":
			if down:
				animation_player.play("IdleDown")
			else:
				animation_player.play("IdleTop")
		"Move":
			if down:
				animation_player.play("MoveDown")
				animation_player.animation_set_next("MoveDown", "IdleDown")
			else:
				animation_player.play("MoveTop")
				animation_player.animation_set_next("MoveTop", "IdleTop")
		"Roll":
			animation_player.play("RollFade")
		"Attack":
			animation_player.play("AttackDown")
