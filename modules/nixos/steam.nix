{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkMerge types mkEnableOption mkOption;
in
{
  options.steam = {
    enable = mkEnableOption "enable Steam and its necessary modules";
    users = mkOption {
      type = with types; listOf str;
      description = "list of users who will use Steam";
      default = [];
    };
  };

  config = mkIf config.steam.enable {
    programs = {
      gamemode.enable = true;
      steam.enable = true;
    };

    usrs = mkMerge (map (name: {
      "${name}".groups = [ "gamemode" ];
    }) config.steam.users);
  };
}