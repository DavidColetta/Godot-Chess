extends Control

@export var Address = "127.0.0.1"
@export var Port = 8910

var peer

# Called when the node enters the scene tree for the first time.
func _ready():
	_hide_start_game_controls()
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)

#this gets called on the server and clients, when anyone connects
func _player_connected(id: int):
	print("Player "+str(id)+ " connected")

#this gets called on the server and clients, when anyone disconnects
func _player_disconnected(id: int):
	print("Player "+str(id)+ " disconnected")

#this gets called only on the client
func _connected_to_server():
	print("Connected to server")
	_send_player_information.rpc_id(1, multiplayer.get_unique_id(), "Name", Enums.COLOR.BLACK)
	_hide_server_controls()

#this gets called only on the client
func _connection_failed():
	print("Connection failed")

@rpc("any_peer", "call_local", "reliable")
func _send_player_information(id: int, username: String, color: Enums.COLOR):
	for i in PlayerManager.Players:#send all previous players data to new player
		PlayerManager.AddPlayer.rpc_id(id, i, PlayerManager.Players[i].username, PlayerManager.Players[i].color)
	
	PlayerManager.AddPlayer.rpc(id, username, color)#send new player data to all players

func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(Port)
	if error != OK:
		print("Cannot Host: "+error)
		return
		
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	
	_send_player_information.rpc_id(1, multiplayer.get_unique_id(), "Host", Enums.COLOR.WHITE)
	print("Waiting for Players")
	_hide_server_controls()
	_show_start_game_controls()


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, Port)
		
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)

func _hide_server_controls():
	$ServerControl.visible = false

func _show_start_game_controls():
	$"Start Game".visible = true
	
func _hide_start_game_controls():
	$"Start Game".visible = false

func _on_start_game_button_down():
	_hide_start_game_controls()
	_start_game.rpc()
	
@rpc("call_local", "reliable")
func _start_game():
	for i in PlayerManager.Players:
		PlayerManager.SpawnPlayerCharacter(i)
	
	$"../ChessBoardView".start_game()
