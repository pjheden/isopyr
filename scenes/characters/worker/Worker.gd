extends KinematicBody2D

# Player constants
export var speed = Vector2(128, 128)
export var move_distance = 16
export var attack_distance = 30
export var attack_damage = 10

# Player variables 
var hp: float = 100.0 setget set_hp
var team: int
var player_rotation : float = 0.0
var velocity: Vector2
var dir: Vector2
var base_index: int # 0-2, its their unique id in base

var defined_animations: Dictionary = {
	"IdleDown": "IdleDown",
	"IdleTop": "IdleTop",
	"MoveDown": "MoveDown",
	"MoveTop": "MoveTop"
}
var active_order # type: Order
var last_entered_building: Node
var resources = []
var gather_time = 5.0
var gather_amount = 50.0

# References
onready var animation_player = $AnimationPlayer 
onready var sprite = $Sprite
onready var sprite_scale: Vector2 = $Sprite.scale
onready var state_machine = $StateMachine
onready var hit_timer = $HitTimer
onready var fct_manager = $FCTManager
onready var navigation_agent = $NavigationAgent2D

func _ready() -> void:
	# Prepare player spells
	add_to_group("team_%s" % team)
	add_to_group("worker")
	set_network_master(get_tree().get_network_unique_id())
	state_machine.transition_to("Idle")

func respawn() -> void:
	state_machine.transition_to("Idle")

# func load(data: Dictionary) -> void:
# 	team = data["team"]	
# 	resources = data["resources"]
# 	hp = data["hp"]
# 	active_order = data["active_order"]
# 	global_position = data["global_position"]
# 	base_index = data["base_index"]
	
# func data() -> Dictionary:
# 	return {
# 		"team": team,
# 		"resources": resources,
# 		"hp": hp,
# 		"active_order": active_order,
# 		"global_position": global_position,
# 		"base_index": base_index,
# 	}

func change_order(new_order: int) -> void:
	if not active_order == Global.WorkOrder.NONE:
		last_entered_building = null
	active_order = new_order
	if state_machine:
		state_machine.transition_to("Idle")

func enter_building(building: Node) -> void:
	if active_order == Global.WorkOrder.HOME:
		active_order = Global.WorkOrder.NONE
	last_entered_building = building
	get_parent().remove_child(self)

func wants_to_enter(building: Node) -> bool:
	var wants = false
	wants = building != last_entered_building # check that its not the building we just left
	if building.has_method("relevant_orders"):
		wants = wants and active_order in building.relevant_orders()
	return wants

func add_resource(amount: float, type: int) -> void:
	resources.append({"amount": amount, "type": type})

func has_resources() -> bool:
	return resources.size() > 0

func set_rotation(r: float) -> void:
	player_rotation = r

func get_rotation() -> float:
	return player_rotation

func flip_sprite(flip: bool) -> void:
	sprite.flip_h = flip

func set_team(new_team: int) -> void:
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
	return #TODO: temp
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

func hit_by_physical_damager(damage):
	#rpc("hit_by_damager", damage)
	hit_by_damager(damage)

func hit_by_damager(damage):
	fct_manager.show_value(damage)
	hp -= damage
	modulate = Color(5, 5, 5, 1)
	hit_timer.start()

	if hp <= 0:
		queue_free()
		# TODO: need to signal the base that the worker is dead
	
func _on_HitTimer_timeout():
	modulate = Color(1, 1, 1, 1)
