extends Node


export(int) var PORT = 8080

# info on players
var players_info = {}
# info on current player
var my_id
# var my_info = {}
# keep track of players who finished loading
var players_done = []

# Reference to lobby UI
var lobby

var networked_object_name_index = 0 setget networked_object_name_index_set
puppet var puppet_networked_object_name_index = 0 setget puppet_networked_object_name_index_set

func _ready():
	randomize()
	
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_ok")
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")


func create_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT)
	get_tree().network_peer = peer
	
	#my_info["name"] = Save.save_data["playerName"]
	my_id = 1
	
	players_info[my_id] = create_player_info()
	
	# Add server player lobby UI here
	lobby.add_player(0, players_info[my_id])

func create_client(address):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(address, PORT)
	get_tree().network_peer = peer
	
	my_id = get_tree().get_network_unique_id()
	
	players_info[my_id] = create_player_info()

func create_player_info():
	var d = {}
	d["name"] = Save.save_data["playerName"]
	var colors = [Color8(0,0,0), Color8(255,255,255), Color8(255,0,0), Color8(0,255,0), Color8(0,0,255)]
	d["color"] = colors[randi() % colors.size()]
	d["hero"] = "Sword"
	d["team"] = 0
	return d

func _player_connected(id):
	print("player connected: ", id)
	# send only to server
	rpc_id(id, "register_player", players_info[my_id])
		
func _player_disconnected(id):
	print("player disconnected: ", id)
	players_info.erase(id)
	# TODO: de-instance player?
	
func _connected_ok():
	print("_connected: ", players_info)
	
func _server_disconnected():
	pass # Server kicked us; show error and abort.

func _connected_fail():
	pass # Could not even connect to server; abort.

remote func set_players_info(pi):
	print("setting player_info: ", pi)
	players_info = pi
	lobby.redraw(players_info[my_id], players_info)

func share_players_info(id):
	# Tell the new player who is in the lobby already
	var pi = players_info.duplicate()
	#pi[get_tree().get_network_unique_id()] = my_info
	rpc_id(id, "set_player_info", pi)

remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	if get_tree().is_network_server():
		share_players_info(id)
	# Store the info
	players_info[id] = info
	
	# Add new player lobby UI here
	lobby.add_player(players_info.size(), info)

remote func pre_configure_game(spawn_points):
	# Load world
	var world = Game.load_world()
	
	# set players
	var pi = players_info.duplicate()
	#pi[get_tree().get_network_unique_id()] = my_info 
	Game.set_players(pi)
	
	# Spawn players
	Game.spawn_players(world, spawn_points)

	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	# The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
	print("players registered ", players_info, players_info.size())
	if not get_tree().is_network_server():
		rpc_id(1, "done_preconfiguring")
	# special case when only host is playing
	if players_info.size() == 0:
		get_tree().set_pause(false)
	

remote func done_preconfiguring():
	print("call done_preconfiguring")
	var who = get_tree().get_rpc_sender_id()
	# Here are some checks you can do, for example
	assert(get_tree().is_network_server())
	assert(who in players_info) # Exists
	assert(not who in players_done) # Was not added yet

	players_done.append(who)
	
	print("players_done: ", players_done)
	if players_done.size() == players_info.size():
		rpc("post_configure_game")
		post_configure_game()

remote func post_configure_game():
	print("call post_configure_game: ", get_tree().get_rpc_sender_id())
	# Only the server is allowed to tell a client to unpause
	if 1 == get_tree().get_rpc_sender_id():
		get_tree().set_pause(false)
		# Game starts now!

func begin_game():
	assert(get_tree().is_network_server())
	
	# create dict determining each players spawn point
	# player_id: spawn point index
	var spawn_points = {}
	spawn_points[1] = 0 # server
	var spawn_points_index = 1
	for p in players_info:
		spawn_points[p] = spawn_points_index
		spawn_points_index += 1
	# Call to pre-start game with the spawn points.
	# TODO: try rpc instead to broadcst to everyone at once?
	for p in players_info:
		if p == my_id:
			continue
		rpc_id(p, "pre_configure_game", spawn_points)
	
	players_done = []
	pre_configure_game(spawn_points)

func broadcast_hero_change(p_id: int, hero: int) -> void:
	print("broadcasting hero change")
	rpc("change_hero", get_tree().get_network_unique_id(), hero)
	
## change_hero changes the selected hero to {hero} for player {p_id}
remotesync func change_hero(p_id: int, hero: int) -> void:
	players_info[p_id]["hero"] = hero
	var name = "LobbyPlayer-" + players_info[p_id]["name"]
	var pu = get_node("/root/Server_browser/Lobby/Players/" + name)
	var txt = Global.get_hero_icon(players_info[p_id]["hero"])
	pu.set_icon(txt)

func broadcast_team_change(p_id: int, team: int) -> void:
	print("broadcasting team change %s" % team)
	rpc("change_team", get_tree().get_network_unique_id(), team)
	
## change_team changes the selected team to {team} for player {p_id}
remotesync func change_team(p_id: int, team: int) -> void:
	players_info[p_id]["team"] = team
	var name = "LobbyPlayer-" + players_info[p_id]["name"]
	var pu = get_node("/root/Server_browser/Lobby/Players/" + name)
	pu.set_team(team)

func puppet_networked_object_name_index_set(new_value):
	networked_object_name_index = new_value

func networked_object_name_index_set(new_value):
	networked_object_name_index = new_value
	
	if get_tree().is_network_server():
		rset("puppet_networked_object_name_index", networked_object_name_index)
