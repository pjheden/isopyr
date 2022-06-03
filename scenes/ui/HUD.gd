extends CanvasLayer

var shortcut_map: Dictionary = {}

onready var shortcuts_path: String = "SkillBar/TextureRect/HBoxContainer/"
onready var shortcut_nodes = get_tree().get_nodes_in_group("Shortcuts")

func _ready() -> void:
	# for shortcut in get_tree().get_nodes_in_group("Shortcuts"):
	# 	shortcut.connect("pressed", self, "select_shortcut", [shortcut.get_parent().get_name()])
	pass

func select_shortcut() -> void:
	pass

func load_spellbar(hotkeys: Array, spell_icons: Array, spell_cooldowns: Array) -> void:
	var num_shortcuts = shortcut_nodes.size()
	var num_spells = spell_icons.size()
	assert(num_spells <= num_shortcuts, "Too many spells defined, %s spell(s) %s shortcut(s)" % [num_spells, num_shortcuts])

	for i in num_spells:
		var spell_icon = load(spell_icons[i])
		shortcut_nodes[i].set_texture(spell_icon)
		shortcut_nodes[i].get_node("CD").init(spell_cooldowns[i])
		shortcut_map[hotkeys[i]] = i

func casted_spell(shortkey: String) -> void:
	shortcut_nodes[shortcut_map[shortkey]].get_node("CD").start()

func update_health_bar(hp: float) -> void:
	$HPbar.value = hp

func set_name(name: String) -> void:
	$Name.text = name
