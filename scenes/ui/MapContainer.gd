extends Control

signal map_selected(map_name)
onready var map_list: ItemList = $ItemList

func _ready():
	map_list.select(0)
	_on_ItemList_item_selected(0)

func _on_ItemList_item_selected(index:int):
	var map_name = map_list.get_item_text(index)
	emit_signal("map_selected", map_name)

func select_item(text: String) -> void:
	for i in range(map_list.get_item_count()):
		var item_text = map_list.get_item_text(i)
		if text == item_text:
			map_list.select(i)
			break
