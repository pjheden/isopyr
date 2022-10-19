extends StaticBody2D

export(int) var max_hitpoints = 100
export(int) var death_projectiles = 4
export(Global.Team) var team = Global.Team.NONE

var hitpoints: int
const projectile_scene = preload("res://scenes/objects/projectiles/Boulder.tscn")

onready var fct_manager = $FCTManager

func _ready():
	$HPbar.visible = false
	$HPbar.max_value = max_hitpoints
	hitpoints = max_hitpoints

sync func destroy() -> void:
	$HPbar.value = 0
	#Mouse.reset()
	# Spawn projectiles in 8 dirs
	if is_network_master():
		rpc("instance_projectiles", 1)
	queue_free() #TODO: its cooler if it gets broken and is repairable

sync func instance_projectiles(id):
	# Create projectiles firing out of each direction of the pillar
	var angle: float = global_rotation
	var angle_increment = 2*PI / death_projectiles
	var persistant_objects = get_node("/root/PersistantObjects")
	for i in range(death_projectiles):
		var projectile_instance = projectile_scene.instance()
		projectile_instance.set_network_master(id) # set projectile owner
		projectile_instance.player_rotation = angle
		projectile_instance.global_position = global_position
		projectile_instance.name = "BuildingProjectile_" + self.name + "_" +str(i)
		
		
		persistant_objects.call_deferred("add_child", projectile_instance)
		angle  += angle_increment

func damage(amount):
	fct_manager.show_value(amount)
	hitpoints -= amount
	if hitpoints <= 0:
		if get_tree().is_network_server():
			rpc("destroy")
		return true
	$HPbar.value = hitpoints
	
	if hitpoints == max_hitpoints:
		$HPbar.visible = false
	else:
		$HPbar.visible = true
	
	return false

func hit_by_damager(damage):
	damage(damage)

func hit_by_physical_damager(damage):
	damage(damage)

func _on_Hitbox_area_entered(area):
	if area.is_in_group("Object_damager"):
		var p = area.get_parent()
		if self.team == p.get_team():
			return
		damage(area.get_parent().damage)

func _on_Hitbox_mouse_entered():
	if team == Global.Team.NONE:
		Mouse.play_info(self)
	elif Global.player_master and team == Global.player_master.get_team():
		Mouse.play_friendly(self)
	else:
		Mouse.play_danger(self)
	

func _on_Hitbox_mouse_exited():
	Mouse.reset()
