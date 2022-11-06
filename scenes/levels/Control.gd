extends Control

onready var base = get_node("/root/world/Resources/Bases/Base")

func _on_Button_pressed():
	base.send_order(0, Global.WorkOrder.FORESTRY)
