extends Label

func process(_delta: float) -> void:
	self.text = get_parent().States.keys()[get_parent().state]
