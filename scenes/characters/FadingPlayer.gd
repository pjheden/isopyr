extends Sprite

export var fade_speed: float = 0.1

func _ready():
	modulate.a = 1.0

func _process(delta):
	modulate.a -= fade_speed * delta
	
	if modulate.a <= 0.0:
		queue_free()
