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
		"AttackDown": "AttackDown",
		"SpellQ": "SpellQ",
		"SpellW": "SpellW"
	}

func spells(is_master: bool) -> void:
	var boulder_manager = projectile_manager_scene.instance()
	boulder_manager.set_object(
		"res://scenes/objects/projectiles/Boulder.tscn",
		"res://resources/sprites/boulder_icon.png",
		1.6,
		"SpellQ"
	)
	var slice_manager = projectile_manager_scene.instance()
	slice_manager.set_object(
		"res://scenes/objects/projectiles/Slice.tscn",
		"res://resources/sprites/slice.png",
		0.3,
		"SpellW"
	)
	# Add spell managers as childs
	add_child(boulder_manager)
	add_child(slice_manager)

	if is_master:
		# Define all spells
		spell_bindings[Global.spell1_button] = slice_manager
		spell_bindings[Global.spell2_button] = boulder_manager

		# Update HUD with spells
		hud.load_spellbar(
			[Global.spell1_button, Global.spell2_button],
			[slice_manager.icon(), boulder_manager.icon()],
			[slice_manager.cooldown, boulder_manager.cooldown]
		)
