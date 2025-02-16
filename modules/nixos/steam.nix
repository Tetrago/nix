{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
    types
    mkEnableOption
    mkOption
    ;
in
{
  options.tetrago.steam = {
    enable = mkEnableOption "Steam and its necessary modules.";

    users = mkOption {
      type = with types; listOf str;
      description = "List of users who will use Steam.";
      default = [ ];
    };
  };

  config =
    let
      cfg = config.tetrago.steam;
    in
    mkIf cfg.enable {
      programs = {
        gamemode.enable = true;
        steam.enable = true;
      };

      users.users = mkMerge (map (name: { "${name}".extraGroups = [ "gamemode" ]; }) cfg.users);
    };
}
