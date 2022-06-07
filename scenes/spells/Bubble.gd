extends "res://scenes/spells/Spell.gd"


func activate(params := {}) -> void:
	.activate(params) # call parent / super
	visible = true
	collision_shape.disabled = false

func deactivate() -> void:
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
