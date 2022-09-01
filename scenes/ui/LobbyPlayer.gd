extends Control

var owner_id: int

func _ready() -> void:
	#$ItemList.select(0)
	#$Team.text = $ItemList.get_item_text(0)
	_on_team_selected(0)

func update_info(p_id: int, info: Dictionary) -> void:
	$Name.text = info["name"]
	$Color.color = info["color"]
	owner_id = p_id
	if owner_id == get_network_master():
		$OptionButton.disabled = false

func set_icon(texture: Texture) -> void:
	$TextureRect.texture = texture 

func _on_team_selected(team_index: int) -> void:
	var team = $OptionButton.get_item_id(team_index)
	get_parent().get_parent().get_parent().set_team(owner_id, team)
	if get_tree().get_network_unique_id() == owner_id:
		$Team.text = str(team)
