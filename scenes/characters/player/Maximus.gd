extends "res://scenes/characters/player/Player.gd"

var projectile_manager_scene = preload("res://scenes/spells/ProjectileManager.tscn")
var bubble_scene = preload("res://scenes/spells/Bubble.tscn")

func _ready() -> void:
	#._ready()
	pass

func spells(is_master: bool) -> void:
	var bubble = bubble_scene.instance()
	var spear_manager = projectile_manager_scene.instance()
	spear_manager.set_object(
		"res://scenes/objects/projectiles/Spear.tscn",
		"res://resources/sprites/spear.png",
		1.5,
		"modulate"
	)
	
	# Add spell managers as childs
	add_child(bubble)
	add_child(spear_manager)

	if is_master:
		# Define all spells
		spell_bindings["q"] = bubble
		spell_bindings["w"] = spear_manager

		# Update HUD with spells
		hud.load_spellbar(["q", "w"], [bubble.icon(), spear_manager.icon()], [bubble.cooldown, spear_manager.cooldown])
