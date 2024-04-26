{ lib, ... }:

let
  inherit (lib) mkOption types;
in
{
  options.hyprworld = {
    wallpaper = mkOption {
      type = types.str;
      description = "path to wallpaper";
    };
  };
}