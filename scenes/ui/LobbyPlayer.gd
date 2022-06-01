extends Control


func update_info(info: Dictionary) -> void:
	print("updating info: ", info)
	$Name.text = info["name"]
	$Color.color = info["color"]

func set_icon(texture: Texture) -> void:
	$TextureRect.texture = texture 
