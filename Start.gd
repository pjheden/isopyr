extends Control

const player_ui_scene = preload("res://scenes/ui/LobbyPlayer.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Network.lobby = self
	$Background_panel/PlayerName.text = Save.save_data["playerName"]

	#TMP auto start game for smoother tests
	Network.create_server()
	yield(get_tree().create_timer(1.0), "timeout")
	Network.begin_game()
	
	var args = OS.get_cmdline_args()
	if args.size() > 0:
		var client_type_arg = args[0]
		if client_type_arg == "listen":
			# run server
			Network.create_server()
			yield(get_tree().create_timer(1.0), "timeout")
			Network.begin_game()
		elif client_type_arg == "join":
			# run client
			Network.create_client("localhost")
		else:
			# do nothing
			push_warning("Argument %s is not supported" % client_type_arg)

func _on_Create_server_pressed():
	var player_name: String = $Background_panel/PlayerName.text
	if player_name == "":
		return
	Save.save_data["playerName"] = player_name
	Save.save_game()
	
	Network.create_server()
	hide_server_browser(true)

func hide_server_browser(is_host) -> void:
	$Background_panel.hide()
	$Lobby.show()
	$Lobby/Start_server.disabled = not is_host

func _on_Join_server_pressed():
	var server_ip: String = $Background_panel/Server_ip.text
	var player_name: String = $Background_panel/PlayerName.text
	# Ensure we have both fields filled
	if player_name == "" or server_ip == "":
		return

	Save.save_data["playerName"] = player_name
	Save.save_game()

	hide_server_browser(false)
	Network.create_client(server_ip)

func _on_Start_server_pressed():
	$Lobby.hide()
	Network.begin_game()

func redraw(my_info, player_info) -> void: 
	# Remove existing
	for n in $Lobby/Players.get_children():
		$Lobby/Players.remove_child(n)
		n.queue_free()
	# Add my info
	add_player(0, my_info)
	# add player_info
	var i: int = 1
	for k in player_info:
		add_player(i, player_info[k])
		i += 1

## add_player adds a a player (info) to the loby screen
func add_player(index, info) -> void:
	var pu = player_ui_scene.instance()
	pu.update_info(info)
	# TODO: write this better
	# load right textures
	var txt = Global.get_hero_icon(info["hero"])
	pu.set_icon(txt)
	var height = $Lobby/Players.rect_size.y
	pu.set_position(Vector2(0,index * (height / 8)))
	pu.set_global_position(Vector2(0, index * (height / 8)))
	pu.name = "LobbyPlayer-" + info["name"]
	$Lobby/Players.add_child(pu)


func _on_SwordButton_pressed():
	Network.broadcast_hero_change(get_tree().get_network_unique_id(), Hero.SWORD)


func _on_SpearButton_pressed():
	Network.broadcast_hero_change(get_tree().get_network_unique_id(), Hero.SPEAR)
