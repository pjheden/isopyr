extends "res://scenes/characters/player/Player.gd"

var projectile_manager_scene = preload("res://scenes/spells/ProjectileManager.tscn")
var aoe_manager_scene = preload("res://scenes/spells/AoeManager.tscn")

func _ready() -> void:
	._ready()
	defined_animations = {
		"IdleDown": "IdleDown",
		"IdleTop": "IdleDown",
		"MoveDown": "IdleDown",
		"MoveTop": "IdleDown",
		"RollFade": "RollFade",
		"AttackDown": "IdleDown"
	}

func spells() -> void:
	var aoe_manager = aoe_manager_scene.instance()
	aoe_manager.set_object(
		"res://scenes/objects/aoes/Chtul.tscn",
		"res://resources/sprites/aoe.png"
	)
	var whip_manager = projectile_manager_scene.instance()
	whip_manager.set_object(
		"res://scenes/objects/projectiles/Whip.tscn",
		"res://resources/sprites/whip.png"
	)
	# Add spell managers as childs
	add_child(aoe_manager)
	add_child(whip_manager)
	# Define all spells
	spell_bindings["q"] = funcref(aoe_manager, "activate")
	spell_bindings["w"] = funcref(whip_manager, "activate")

	# Update HUD with spells
	hud.load_spellbar(
		["q", "w"],
		[aoe_manager.icon(), whip_manager.icon()],
		[aoe_manager.cooldown, whip_manager.cooldown]
	)
