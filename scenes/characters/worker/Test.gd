extends Node


const worker_scene = preload("res://scenes/characters/worker/Worker.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(8080)
	get_tree().network_peer = peer

	var worker = worker_scene.instance()
	var _connected = $Control/Forestry.connect("pressed", worker, "add_order", [worker.Order.FORESTRY])
	add_child(worker)
