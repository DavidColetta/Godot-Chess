extends Node

var playerScene = preload("res://Scenes/player.tscn")
var playerCharacterScene = preload("res://Scenes/PlayerCharacter.tscn")

var Players: Dictionary = {}

@rpc("call_local", "reliable")
func AddPlayer(id: int, username: String, color: Enums.COLOR):
	#print("add player "+str(id)+" name: "+username)
	var newPlayer = playerScene.instantiate() as Player
	newPlayer.username = username
	newPlayer.color = color
	newPlayer.name = username
	add_child(newPlayer)
	Players[id] = newPlayer

func SpawnPlayerCharacter(id: int):
	#var player = Players[id] as Player
	var playerCharacter = playerCharacterScene.instantiate() as PlayerMovement
	playerCharacter.playerID = id
	playerCharacter.name = str(id)
	if id == multiplayer.get_unique_id():
		(playerCharacter.get_node("Neck").get_node("Camera3D") as Camera3D).make_current()
	if id != 1:
		playerCharacter.position = Vector3(-11, 40, 21)
	get_node("/root/Main").add_child(playerCharacter)

func GetLocalPlayer() -> Player:
	return Players[multiplayer.get_unique_id()]
