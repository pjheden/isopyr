extends Label

func _process(delta):
	self.text = get_parent().get_sm_state()
