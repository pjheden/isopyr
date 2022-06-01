extends Label

func _on_StateMachine_transitioned(state_name:String):
	self.text = state_name
