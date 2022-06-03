extends "res://scenes/characters/player/BasePlayer.gd"
export(int) var damage = 40

var bubble_scene = preload("res://scenes/spells/Bubble.tscn")

func _ready() -> void:
	var bubble = bubble_scene.instance()
	# Add bubble as shield
	add_child(bubble)
	# Define all spells
	spell_bindings["q"] = funcref(bubble, "activate")

	# Update HUD with spells
	hud.load_spellbar([bubble.icon()], [bubble.cooldown])

func attack_animation_finished():
	state = States.IDLE
	$AttackCooldown.start()

# Duplicate of method in BasePlayer
# was needed to get timer callback to work correctly
func roll_animation_finished():
	state = States.IDLE

func _on_Area2D_area_entered(area):
	var parent = area.get_parent()
	if parent.has_method("hit_by_physical_damager"):
		parent.hit_by_physical_damager(damage)

func _process(_delta:float) -> void:
	# consume spell queue from parent
	for sq in spell_queue:
		if not sq in spell_bindings:
			continue
		spell_bindings[sq].call_func()
		hud.casted_spell(spell_key)
		spell_queue.erase(sq)
	# TODO: spell cast CD etc
