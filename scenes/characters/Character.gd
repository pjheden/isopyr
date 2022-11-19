extends KinematicBody2D

# constants
export var speed = Vector2(128, 128)
export var move_distance = 16
export var attack_distance = 30
export var attack_damage = 10

# variables 
var hp: float = 100.0 setget set_hp
var team: int
var character_rotation : float = 0.0
var velocity: Vector2
var dir: Vector2

var defined_animations: Dictionary = {
	"IdleDown": "IdleDown",
	"IdleTop": "IdleTop",
	"MoveDown": "MoveDown",
	"MoveTop": "MoveTop",
	"RollFade": "RollFade",
	"AttackDown": "AttackDown"
}

# References
onready var animation_player = $AnimationPlayer 
onready var sprite = $Sprite
onready var sprite_scale: Vector2 = $Sprite.scale
onready var state_machine = $StateMachine
onready var hit_timer = $HitTimer
onready var fct_manager = $FCTManager

func _ready() -> void:
	add_to_group("team_%s" % team)

func set_rotation(r: float) -> void:
	character_rotation = r

func get_rotation() -> float:
	return character_rotation

func flip_sprite(flip: bool) -> void:
	# if is_network_master():
	# 	rset("puppet_flip", flip)
	sprite.flip_h = flip

func set_team(new_team: int) -> void:
	if is_in_group("team_%s" % team):
		remove_from_group("team_%s" % team)
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
		rpc("hit_by_damager", p.damage)
		
func hit_by_physical_damager(damage):
	rpc("hit_by_damager", damage)

sync func hit_by_damager(damage):
	fct_manager.show_value(damage)
	hp -= damage
	modulate = Color(5, 5, 5, 1)
	hit_timer.start()

	if hp <= 0:
		queue_free()
	
func _on_HitTimer_timeout():
	modulate = Color(1, 1, 1, 1)

func _on_StateMachine_transitioned(state_name:String):
	if is_network_master():
		rset("puppet_state", state_name)
