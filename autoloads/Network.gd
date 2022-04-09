extends Node


export(int) var PORT = 8080

# info on players
var player_info = {}
# info on current player
var my_info = {}
# keep track of players who finished loading
var players_done = []

# Reference to lobby UI
var lobby

var networked_object_name_index = 0 setget networked_object_name_index_set
puppet var puppet_networked_object_name_index = 0 setget puppet_networked_object_name_index_set

func _ready():
	randomize()
	#var names = ["Roshack", "Ragnar", "Rez", "Ruba", "Rio"]
	#my_info["name"] = names[randi() % names.size()]
	#my_info["name"] = Save.save_data["playerName"]
	
	var colors = [Color8(0,0,0), Color8(255,255,255), Color8(255,0,0), Color8(0,255,0), Color8(0,0,255)]
	my_info["color"] = colors[randi() % colors.size()]
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	

func create_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(PORT)
	get_tree().network_peer = peer
	
	my_info["name"] = Save.save_data["playerName"]
	
	# Add server player lobby UI here
	lobby.add_player(0, my_info)

func create_client(address):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(address, PORT)
	get_tree().network_peer = peer
	
	my_info["name"] = Save.save_data["playerName"]

func _player_connected(id):
	print("player connected: ", id)
	# send only to server
	rpc_id(id, "register_player", my_info)
		
func _player_disconnected(id):
	print("player disconnected: ", id)
	player_info.erase(id)
	# TODO: de-instance player?
	
func _connected_ok():
	print("_connected: ", player_info)
	
func _server_disconnected():
	pass # Server kicked us; show error and abort.

func _connected_fail():
	pass # Could not even connect to server; abort.

remote func set_player_info(pi):
	print("setting player_info: ", pi)
	player_info = pi
	lobby.redraw(my_info, player_info)

func share_player_info(id):
	# Tell the new player who is in the lobby already
	var pi = player_info.duplicate()
	pi[get_tree().get_network_unique_id()] = my_info
	rpc_id(id, "set_player_info", pi)

remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	if get_tree().is_network_server():
		share_player_info(id)
	# Store the info
	player_info[id] = info
	
	# Add new player lobby UI here
	lobby.add_player(player_info.size(), info)

remote func pre_configure_game(spawn_points):
	# Load world
	var world = Game.load_world()
	
	# set players
	var pi = player_info.duplicate()
	pi[get_tree().get_network_unique_id()] = my_info 
	Game.set_players(pi)
	
	# Spawn players
	Game.spawn_players(world, spawn_points)

	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	# The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
	print("players registered ", player_info, player_info.size())
	if not get_tree().is_network_server():
		rpc_id(1, "done_preconfiguring")
	# special case when only host is playing
	if player_info.size() == 0:
		get_tree().set_pause(false)
	

remote func done_preconfiguring():
	print("call done_preconfiguring")
	var who = get_tree().get_rpc_sender_id()
	# Here are some checks you can do, for example
	assert(get_tree().is_network_server())
	assert(who in player_info) # Exists
	assert(not who in players_done) # Was not added yet

	players_done.append(who)
	
	print("players_done: ", players_done)
	if players_done.size() == player_info.size():
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
	for p in player_info:
		spawn_points[p] = spawn_points_index
		spawn_points_index += 1
	# Call to pre-start game with the spawn points.
	for p in player_info:
		rpc_id(p, "pre_configure_game", spawn_points)
	
	players_done = []
	pre_configure_game(spawn_points)

func puppet_networked_object_name_index_set(new_value):
	networked_object_name_index = new_value

func networked_object_name_index_set(new_value):
	networked_object_name_index = new_value
	
	if get_tree().is_network_server():
		rset("puppet_networked_object_name_index", networked_object_name_index)