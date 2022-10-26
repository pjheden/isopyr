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
		"AttackDown": "AttackDown",
		"SpellQ": "SpellQ",
		"SpellW": "SpellW"
	}

func spells(is_master: bool) -> void:
	var bubble_manager = projectile_manager_scene.instance()
	bubble_manager.set_object(
		"res://scenes/objects/projectiles/Blob.tscn",
		"res://resources/sprites/plague_blob.png",
		1.4,
		"SpellQ"
	)
	var rabbit = projectile_manager_scene.instance()
	rabbit.set_object(
		"res://scenes/objects/projectiles/Rabbit.tscn",
		"res://resources/sprites/rabbit.png",
		0.5,
		"SpellW"
	)
	# Add spell managers as childs
	add_child(bubble_manager)
	add_child(rabbit)

	if is_master:
		# Define all spells
		spell_bindings[Global.spell1_button] = bubble_manager
		spell_bindings[Global.spell2_button] = rabbit
		
		# Update HUD with spells
		hud.load_spellbar(
			[Global.spell1_button, Global.spell2_button],
			[bubble_manager.icon(), rabbit.icon()],
			[bubble_manager.cooldown, rabbit.cooldown]
		)
