extends KinematicBody2D

const speed = Vector2(128, 128)


func get_sm_state() -> String:
	return $StateMachine.state.name
