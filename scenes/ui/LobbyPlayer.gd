extends Control

var owner_id: int

func _ready() -> void:
	#$ItemList.select(0)
	#$Team.text = $ItemList.get_item_text(0)
	_on_team_selected(0)

# update_info updates the UI with player information
# c_id - the id of the client
# p_id - the id of the player
# info - the information to update ui with
func update_info(c_id: int, p_id: int, info: Dictionary) -> void:
	$Name.text = info["name"]
	$Color.color = info["color"]
	owner_id = p_id
	if c_id == p_id:
		$OptionButton.disabled = false
		$Name.modulate = Color.green

func set_icon(texture: Texture) -> void:
	$TextureRect.texture = texture 

func set_team(team: int) -> void:
	for i in range($OptionButton.get_item_count()):
		var item_id = $OptionButton.get_item_id(i)
		if item_id == team:
			$OptionButton.select(i)
			break
	$Team.text = "Team: " + str(team)

func _on_team_selected(team_index: int) -> void:
	var team = $OptionButton.get_item_id(team_index)
	if get_tree().get_network_unique_id() == owner_id:
		get_parent().get_parent().get_parent().set_team(owner_id, team)
		$Team.text = "Team: " + str(team)
