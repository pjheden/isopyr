extends CanvasLayer

func update_health_bar(hp: float) -> void:
	$HPbar.value = hp

func set_name(name: String) -> void:
	$Name.text = name
