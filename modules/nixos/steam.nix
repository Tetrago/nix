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
    enable = mkEnableOption "enable Steam and its necessary modules";

    users = mkOption {
      type = with types; listOf str;
      description = "list of users who will use Steam";
      default = [ ];
    };
  };

  config =
    with config.tetrago.steam;
    mkIf enable {
      programs = {
        gamemode.enable = true;
        steam.enable = true;
      };

      users.users = mkMerge (map (name: { "${name}".extraGroups = [ "gamemode" ]; }) users);
    };
}
