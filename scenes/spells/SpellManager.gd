extends Node

onready var cooldown_timer = $CooldownTimer
onready var cast_timer = $CastTimer
var cooldown: float
var cast_time: float
var ready: bool

func _ready() -> void:
	cooldown = cooldown_timer.wait_time
	cast_time = cast_timer.wait_time
	ready = true

func activate(_params := {}) -> bool:
	if not ready:
		return false
	cooldown_timer.start()
	ready = false
	return true

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

func is_ready() -> bool:
	return ready



func _on_CooldownTimer_timeout():
	ready = true
