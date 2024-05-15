using Godot;
using System;
using GodotSteam;

public partial class InitSteam : Node
{
  [Export]
  public bool UseSteam = false;
  [Export]
  private string AppID = "480";
  
  public override void _Ready() {
		if (UseSteam) {
			OS.SetEnvironment("SteamAppID", AppID);
			OS.SetEnvironment("SteamGameID", AppID);
			Steam.SteamInitEx(false);
		}
  }

  public override void _Process(double delta){
		base._Process(delta);
		if (UseSteam) {
			Steam.RunCallbacks();
		}
  }

	
}
