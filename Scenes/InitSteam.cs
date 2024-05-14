using Godot;
using System;

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
      // Steam.steamInitEx()
    }
  }

  public override void _Process(double delta){
    base._Process(delta);
    if (UseSteam) {
      //Steam.run_callbacks();
    }
  }

    
}
