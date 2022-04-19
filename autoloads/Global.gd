extends Node

var player_master = null


# Utils methods
func get_hero_icon(hero: String) -> Texture:
	var txt: Texture
	if hero == "Spear":
		txt =  load("res://resources/ui/spear-icon.png")
	txt =  load("res://resources/ui/warrior-icon.png")
	return txt
