extends "res://scenes/characters/player/Player.gd"

var projectile_manager_scene = preload("res://scenes/spells/ProjectileManager.tscn")

func _ready() -> void:
	#._ready() # calls parent ready per default
	defined_animations = {
		"IdleDown": "IdleDown",
		"IdleTop": "IdleDown",
		"MoveDown": "MoveDown",
		"MoveTop": "MoveDown",
		"RollFade": "RollFade",
		"AttackDown": "AttackDown"
	}

func spells(is_master: bool) -> void:
	var bubble_manager = projectile_manager_scene.instance()
	bubble_manager.set_object(
		"res://scenes/objects/projectiles/Blob.tscn",
		"res://resources/sprites/plague_blob.png",
		2.0,
		"modulate"
	)
	var rabbit = projectile_manager_scene.instance()
	rabbit.set_object(
		"res://scenes/objects/projectiles/Rabbit.tscn",
		"res://resources/sprites/rabbit.png",
		0.0,
		"modulate"
	)
	# Add spell managers as childs
	add_child(bubble_manager)
	add_child(rabbit)

	if is_master:
		# Define all spells
		spell_bindings["q"] = bubble_manager
		spell_bindings["w"] = rabbit
		
		# Update HUD with spells
		hud.load_spellbar(
			["q", "w"],
			[bubble_manager.icon(), rabbit.icon()],
			[bubble_manager.cooldown, rabbit.cooldown]
		)
