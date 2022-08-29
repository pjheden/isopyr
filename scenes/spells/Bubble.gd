extends "res://scenes/spells/Spell.gd"

var ready: bool
var animation_name: String = "modulate"
var cast_time: float = 0.0


func _ready() -> void:
	name = "bubble_%s" % get_network_master()
	ready = true

func activate(params := {}) -> bool:
	# TODO: check if this calls super twice
	var is_ready = .activate(params) # call parent / super
	if not is_ready:
		return false
	# visible = true
	# collision_shape.disabled = false

	rpc("broadcast_bubble", true)
	return true

func deactivate() -> void:
	# visible = false
	# collision_shape.disabled = true
	rpc("broadcast_bubble", false)

sync func broadcast_bubble(set_active: bool) -> void:
	print("broadcast bubble! ")
	if set_active:
		visible = true
		collision_shape.disabled = false
	else:
		visible = false
		collision_shape.disabled = true


func _on_AliveTimer_timeout() -> void:
	deactivate()

func _on_Spell_area_entered(area:Area2D) -> void:
	if get_tree().is_network_server():
		if area.is_in_group("Player_damager"):
			# destroy bullet on server
			area.get_parent().rpc("destroy")

func icon() -> String:
	return "res://resources/sprites/shield.png"

func is_ready() -> bool:
	return ready
