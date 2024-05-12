extends Node

var AppID = "480"

func _ready() -> void:
	OS.set_environment("SteamAppID", AppID)
	OS.set_environment("SteamGameID", AppID)
	Steam.steamInitEx()

func _process(delta: float) -> void:
	Steam.run_callbacks()
