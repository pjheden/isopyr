extends Control

onready var team_list = $ItemList

func _ready() -> void:
	team_list.select(0)

func update_info(info: Dictionary) -> void:
	$Name.text = info["name"]
	$Color.color = info["color"]

func set_icon(texture: Texture) -> void:
	$TextureRect.texture = texture 

func set_team(team_index: int) -> void:
	team_list.select(team_index) 
	

func _on_team_selected(team_index: int) -> void:
	get_parent().get_parent().get_parent().set_team(team_index)
