extends "res://scenes/characters/player/Player.gd"

var projectile_manager_scene = preload("res://scenes/spells/ProjectileManager.tscn")
var aoe_manager_scene = preload("res://scenes/spells/AoeManager.tscn")

func _ready() -> void:
	#._ready() # calls parent ready per default
	defined_animations = {
		"IdleDown": "IdleDown",
		"IdleTop": "IdleDown",
		"MoveDown": "MoveDown",
		"MoveTop": "MoveDown",
		"RollFade": "RollFade",
		"AttackDown": "IdleDown"
	}

func spells(is_master: bool) -> void:
	var aoe_manager = aoe_manager_scene.instance()
	aoe_manager.set_object(
		"res://scenes/objects/aoes/Chtul.tscn",
		"res://resources/sprites/aoe.png",
		2.0
	)
	var whip_manager = projectile_manager_scene.instance()
	whip_manager.set_object(
		"res://scenes/objects/projectiles/Whip.tscn",
		"res://resources/sprites/whip.png",
		0.75
	)
	# Add spell managers as childs
	add_child(aoe_manager)
	add_child(whip_manager)

	if is_master:
		# Define all spells
		spell_bindings["q"] = aoe_manager
		spell_bindings["w"] = whip_manager

		# Update HUD with spells
		hud.load_spellbar(
			["q", "w"],
			[aoe_manager.icon(), whip_manager.icon()],
			[aoe_manager.cooldown, whip_manager.cooldown]
		)
