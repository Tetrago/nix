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

    time = {
      lock = mkOption {
        type = types.ints.unsigned;
        description = "minutes of inactivity until the screen locks, or zero to disable";
        default = 5;
      };

      screen = mkOption {
        type = types.ints.unsigned;
        description = "minutes of inactivity until the screen turns off, or zero to disable";
        default = 10;
      };

      sleep = mkOption {
        type = types.ints.unsigned;
        description = "minutes of inactivity until the system suspend, or zero to disable";
        default = 15;
      };
    };
  };
}