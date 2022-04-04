extends Control


func update_info(info) -> void:
	$Name.text = info["name"]
	$Color.color = info["color"]
