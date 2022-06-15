extends Area2D

onready var alive_timer = $AliveTimer
onready var cd_timer = $CooldownTimer
onready var collision_shape = $CollisionShape2D
var cooldown: float

func _ready() -> void:
	cooldown = cd_timer.wait_time

func activate(_params := {}) -> bool:
	if cd_timer.is_stopped():
		cd_timer.start()
		alive_timer.start()
		return true
	return false

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

