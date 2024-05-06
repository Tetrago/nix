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

    extraVolumeKeys = mkOption {
      type = types.bool;
      description = "binds F10, F11, and F12 to mute, increase volume, and decrease volume respectively";
      default = false;
    };
  };
}