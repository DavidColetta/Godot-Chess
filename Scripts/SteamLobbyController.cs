using Godot;
using System;

public partial class SteamLobbyController : Control
{
	private bool UseSteam = true;
	private int lobbyID = 0;

	[Export]
	private string Address = "127.0.0.1";
	[Export]
	private int Port = 8910;

	MultiplayerPeer peer;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		//peer = new Steam
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
