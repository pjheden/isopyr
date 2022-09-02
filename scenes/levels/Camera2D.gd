extends Camera2D

func _process(_delta: float) -> void:
	if Global.player_master != null:
		global_position = Global.player_master.global_position
