extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(8080)
	get_tree().network_peer = peer
