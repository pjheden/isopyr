extends Control

onready var team_list = $ItemList

var index_team_map: Dictionary = {
	0: Global.Team.BROODS,
	1: Global.Team.FREMEN
}
var team_index_map: Dictionary = {
	Global.Team.BROODS: 0,
	Global.Team.FREMEN: 1
}

func _ready() -> void:
	team_list.select(0)

func update_info(info: Dictionary) -> void:
	$Name.text = info["name"]
	$Color.color = info["color"]

func set_icon(texture: Texture) -> void:
	$TextureRect.texture = texture 

func set_team(team_index: int) -> void:
	team_list.select(team_index_map[team_index]) 
	

func _on_team_selected(list_index: int) -> void:
	get_parent().get_parent().get_parent().set_team(index_team_map[list_index])
