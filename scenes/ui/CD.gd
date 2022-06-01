extends Control

onready var timer: Timer = $Timer
onready var label: Label = $Label


func init(cd: float) -> void:
	timer.wait_time = cd

func start() -> void:
	label.text = String(timer.wait_time)
	visible = true
	timer.start()

func _process(_delta: float) -> void:
	if timer.is_stopped():
		visible = false
		return

	label.text = String(stepify(timer.time_left, 0.1))
