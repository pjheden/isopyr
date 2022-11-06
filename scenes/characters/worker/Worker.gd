extends "res://scenes/characters/Character.gd"

#  variables 
var base_index: int # 0-2, its their unique id in base
var active_order # type: Order
var last_entered_building: Node
var resources = []
var gather_time = 5.0
var gather_amount = 50.0

# References
onready var navigation_agent = $NavigationAgent2D

func _ready() -> void:
	add_to_group("worker")
	set_network_master(get_tree().get_network_unique_id())
	state_machine.transition_to("Idle")

func respawn() -> void:
	state_machine.transition_to("Idle")

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

func set_hp(new_value) -> void:
	hp = new_value

# Keeping following methods incase worker breaks with Character methods

# func _on_Hitbox_area_entered(area:Area2D):
# 	# server hit detection
# 	if not get_tree().is_network_server():
# 		return
# 	if area.is_in_group("Player_damager"):
# 		var p = area.get_parent()
# 		if not p.has_method("get_team"):
# 			return
# 		if self.team == p.get_team():
# 			return

# func hit_by_physical_damager(damage):
# 	#rpc("hit_by_damager", damage)
# 	hit_by_damager(damage)