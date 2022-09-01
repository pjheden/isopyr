extends Control

var owner_id: int

var index_team_map: Dictionary = {
	0: Global.Team.NONE,
	1: Global.Team.BROODS,
	2: Global.Team.FREMEN
}
var team_index_map: Dictionary = {
	Global.Team.NONE: 0,
	Global.Team.BROODS: 1,
	Global.Team.FREMEN: 2
}

func _ready() -> void:
	#$ItemList.select(0)
	#$Team.text = $ItemList.get_item_text(0)
	pass

func update_info(p_id: int, info: Dictionary) -> void:
	$Name.text = info["name"]
	$Color.color = info["color"]
	owner_id = p_id

func set_icon(texture: Texture) -> void:
	$TextureRect.texture = texture 

func set_team(team_index: int) -> void:
	$ItemList.select(team_index_map[team_index])
	$Team.text = $ItemList.get_item_text(team_index_map[team_index])

func _on_team_selected(list_index: int) -> void:
	get_parent().get_parent().get_parent().set_team(owner_id, index_team_map[list_index])
	if get_tree().get_network_unique_id() == owner_id:
		$Team.text = $ItemList.get_item_text(list_index)
