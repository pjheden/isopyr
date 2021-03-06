extends "res://scenes/characters/player/Player.gd"

var projectile_manager_scene = preload("res://scenes/spells/ProjectileManager.tscn")


func _ready() -> void:
	#._ready()
	defined_animations = {
		"IdleDown": "IdleDown",
		"IdleTop": "IdleDown",
		"MoveDown": "MoveDown",
		"MoveTop": "MoveDown",
		"RollFade": "RollFade",
		"AttackDown": "AttackDown"
	}

func spells(is_master: bool) -> void:
	var boulder_manager = projectile_manager_scene.instance()
	boulder_manager.set_object(
		"res://scenes/objects/projectiles/Boulder.tscn",
		"res://resources/sprites/rockpng.png"
	)
	var slice_manager = projectile_manager_scene.instance()
	slice_manager.set_object(
		"res://scenes/objects/projectiles/Slice.tscn",
		"res://resources/sprites/slice.png"
	)
	# Add spell managers as childs
	add_child(boulder_manager)
	add_child(slice_manager)

	if is_master:
		# Define all spells
		spell_bindings["q"] = funcref(slice_manager, "activate")
		spell_bindings["w"] = funcref(boulder_manager, "activate")

		# Update HUD with spells
		hud.load_spellbar(
			["q", "w"],
			[slice_manager.icon(), boulder_manager.icon()],
			[slice_manager.cooldown, boulder_manager.cooldown]
		)
