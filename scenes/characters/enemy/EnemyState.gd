extends Label

func _process(_delta):
	self.text = get_parent().get_sm_state()
