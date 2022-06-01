extends Node

onready var cooldown_timer = $CooldownTimer
onready var cast_timer = $CastTimer
var cooldown: float = 3.0

func activate() -> void:
	cooldown_timer.start()

func deactivate() -> void:
	pass

func _on_AliveTimer_timeout() -> void:
	deactivate()

func icon() -> String:
	"""
	Virtual method. Returns the path to the spell icon for UI usage
	"""
	assert(false)
	return ""

