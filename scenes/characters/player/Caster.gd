extends "res://scenes/characters/player/Player.gd"

var bubble_scene = preload("res://scenes/spells/Bubble.tscn")
var projectile_manager_scene = preload("res://scenes/spells/ProjectileManager.tscn")

func spells() -> void:
	var bubble = bubble_scene.instance()
	var projectile_manager = projectile_manager_scene.instance()
	# Add bubble as shield
	add_child(bubble)
	add_child(projectile_manager)
	# Define all spells
	spell_bindings["q"] = funcref(bubble, "activate")
	spell_bindings["w"] = funcref(projectile_manager, "activate")

	# Update HUD with spells
	hud.load_spellbar(
		["q", "w"],
		[bubble.icon(), projectile_manager.icon()],
		[bubble.cooldown, projectile_manager.cooldown]
	)
