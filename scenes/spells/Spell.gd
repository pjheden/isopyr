extends Area2D

onready var alive_timer = $AliveTimer
onready var collision_shape = $CollisionShape2D
var cooldown: float = 3.0

func activate(_params := {}) -> void:
	alive_timer.start()

func deactivate() -> void:
	pass

func _on_AliveTimer_timeout() -> void:
	deactivate()

func _on_Spell_area_entered(area:Area2D) -> void:
	pass

func icon() -> String:
	"""
	Virtual method. Returns the path to the spell icon for UI usage
	"""
	assert(false)
	return ""

