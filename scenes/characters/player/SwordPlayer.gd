extends "res://scenes/characters/player/BasePlayer.gd"
export(int) var damage = 40

func attack_animation_finished():
	state = States.IDLE
	$AttackCooldown.start()

# Duplicate of method in BasePlayer
# was needed to get timer callback to work correctly
func roll_animation_finished():
	state = States.IDLE

func _on_Area2D_area_entered(area):
	if area.get_parent().has_method("hit_by_damager"):
			area.get_parent().hit_by_damager(damage)
