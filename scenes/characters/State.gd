extends Label

func _process(delta):
	self.text = get_parent().States.keys()[get_parent().state]
