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

  positionType =
    with types;
    submodule {
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
