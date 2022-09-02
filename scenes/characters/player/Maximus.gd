extends "res://scenes/characters/player/Player.gd"

var projectile_manager_scene = preload("res://scenes/spells/ProjectileManager.tscn")
var bubble_scene = preload("res://scenes/spells/Bubble.tscn")

func _ready() -> void:
	#._ready()
	defined_animations["SpellW"] = "SpellW"

func spells(is_master: bool) -> void:
	var bubble = bubble_scene.instance()
	var sword_manager = projectile_manager_scene.instance()
	sword_manager.set_object(
		"res://scenes/objects/projectiles/Sword.tscn",
		"res://resources/sprites/sword.png",
		1.0,
		"SpellW"
	)
	
	# Add spell managers as childs
	add_child(bubble)
	add_child(sword_manager)

	if is_master:
		# Define all spells
		spell_bindings["q"] = bubble
		spell_bindings["w"] = sword_manager

		# Update HUD with spells
		hud.load_spellbar(["q", "w"], [bubble.icon(), sword_manager.icon()], [bubble.cooldown, sword_manager.cooldown])
