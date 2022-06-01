extends "res://scenes/characters/player/Player.gd"

var bubble_scene = preload("res://scenes/spells/Bubble.tscn")
var projectile_scene = preload("res://scenes/spells/ProjectileManager.tscn")

func spells() -> void:

	var bubble = bubble_scene.instance()
	var projectile = projectile_scene.instance()
	# Add bubble as shield
	add_child(bubble)
	add_child(projectile)
	# Define all spells
	spell_bindings["q"] = funcref(bubble, "activate")
	spell_bindings["w"] = funcref(projectile, "activate")

	# Update HUD with spells
	hud.load_spellbar([bubble.icon(), projectile.icon()], [bubble.cooldown, projectile.cooldown])
