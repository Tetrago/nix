{ lib, ... }:

let
  inherit (lib) mkOption types;

  resolutionType = types.submodule {
    options = {
      width = mkOption { type = types.ints.positive; };

      height = mkOption { type = types.ints.positive; };

      refreshRate = mkOption {
        type = with types; nullOr ints.positive;
        default = null;
      };
    };
  };

  positionType = types.submodule {
    options = {
      x = mkOption {
        type = types.int;
        default = 0;
      };

      y = mkOption {
        type = types.int;
        default = 0;
      };
    };
  };

  monitorType = types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };

      name = mkOption {
        type = types.str;
        example = "DP-1";
      };

      resolution = mkOption {
        type = types.nullOr resolutionType;
        default = null;
      };

      position = mkOption {
        type = types.nullOr positionType;
        default = null;
      };

      scale = mkOption {
        type = with types; nullOr numbers.positive;
        default = null;
      };

      workspace = mkOption {
        type = with types; nullOr ints.unsigned;
        description = "default workspace to assign";
        default = null;
      };
    };
  };
in
{
  options.hyprworld = {
    bluetooth = mkOption {
      type = types.bool;
      description = "add bluetooth components to startup";
      default = false;
    };

    wallpaper = mkOption {
      type = types.str;
      description = "path to wallpaper";
    };

    lockscreen = mkOption {
      type = with types; nullOr str;
      description = "path to lockscreen background or null for screenshot";
      default = null;
    };

    extraVolumeKeys = mkOption {
      type = types.bool;
      description = "binds F10, F11, and F12 to mute, increase volume, and decrease volume respectively";
      default = false;
    };

    globalScale = mkOption {
      type = with types; nullOr numbers.positive;
      description = "global scale setting; used for GDK_SCALE";
      default = null;
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

    monitors = mkOption {
      type = with types; nullOr (nonEmptyListOf monitorType);
      description = "default monitor configuration to use on startup";
      default = null;
    };

    additionalMonitors = mkOption {
      type = with types; nullOr (attrsOf (nonEmptyListOf monitorType));
      description = "additional monitor configurations used for hot-swapping";
      default = null;
    };
  };
}
