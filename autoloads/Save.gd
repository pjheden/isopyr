extends Node

const SAVEGAME = "user://Savegame.json"

var save_data = {}

func _ready() -> void:
	save_data = get_data()

func get_data():
	var f = File.new()
	
	if not f.file_exists(SAVEGAME):
		var names = ["Roshack", "Ragnar", "Rez", "Ruba", "Rio"]
		save_data = {"playerName": names[randi() % names.size()]}
		save_game()
	f.open(SAVEGAME, File.READ)
	var content = f.get_as_text()
	var data = parse_json(content)
	f.close()
	return data

func save_game():
	var f = File.new()
	f.open(SAVEGAME, File.WRITE)
	f.store_line(to_json(save_data))
	f.close()
