extends Node2D

var is_attacking = false

func play_attack():
	if is_attacking:
		return
	is_attacking = true
	
	rotate(PI/2)
	yield(get_tree().create_timer(0.5), "timeout")
	rotate(-PI/2)
	
	is_attacking = false

func play_spin_attack():
	if is_attacking:
		return
	is_attacking = true
	for i in range(0, 2*PI):
		rotate(i)
	yield(get_tree().create_timer(0.1), "timeout")
	is_attacking = false
	
