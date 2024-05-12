extends Control

@export var UseSteam: bool

var lobbyID := 0

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
	
	if (UseSteam):
		Steam.lobby_match_list.connect(_on_lobby_match_list)
		_open_lobby_list()

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
	if (UseSteam):
		peer = SteamMultiplayerPeer.new()
		peer.lobby_created.connect(_on_lobby_created)
		peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
		#multiplayer.set_multiplayer_peer(peer) #redundant, maybe use =
	else:
		peer = ENetMultiplayerPeer.new()
		var error = peer.create_server(Port)
		if error != OK:
			print("Cannot Host: "+error)
			return
			
		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		
		_hosting()

#steam stuff
func _on_lobby_created(connect: bool, id):
	if connect:
		lobbyID = id
		Steam.setLobbyData(lobbyID, "name", Steam.getPersonaName()+"'s Lobby")
		Steam.setLobbyData(lobbyID, "identify", "GridMons")
		Steam.setLobbyJoinable(lobbyID, true)
		print(lobbyID)
		_hosting()
		
func _hosting():
	multiplayer.set_multiplayer_peer(peer)
	_send_player_information.rpc_id(1, multiplayer.get_unique_id(), "Host", Enums.COLOR.WHITE)
	
	print("Waiting for Players")
	_hide_server_controls()
	_show_start_game_controls()

func _on_join_button_down():
	if UseSteam:
		if $LobbyContainer/Lobbies.get_child_count() > 0:
			for n in $LobbyContainer/Lobbies.get_children():
				n.queue_free()
	else:
		peer = ENetMultiplayerPeer.new()
		peer.create_client(Address, Port)
			
		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		
		multiplayer.set_multiplayer_peer(peer)

func _join_lobby(id: int):
	peer = SteamMultiplayerPeer.new()
	peer.connect_lobby(id)
	lobbyID = id
	multiplayer.set_multiplayer_peer(peer)
	_hide_server_controls()
	
func _open_lobby_list():
	#Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	#Steam.addRequestLobbyListStringFilter("identify", "GridMons", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()
	
func _on_lobby_match_list(lobbies):
	for lobby in lobbies:
		var lobbyName := Steam.getLobbyData(lobby, "name")
		var member_count := Steam.getNumLobbyMembers(lobby)
		
		var lobby_button := Button.new()
		lobby_button.set_text(lobbyName + " | "+str(member_count))
		lobby_button.size = Vector2(100, 5)
		
		lobby_button.connect("pressed", Callable(self, "_join_lobby").bind(lobby))
		
		$LobbyContainer/Lobbies.add_child(lobby_button)

func _hide_server_controls():
	$ServerControl.visible = false
	$LobbyContainer.visible = false

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
