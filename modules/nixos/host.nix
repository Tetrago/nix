{ lib, ... }:

let
  inherit (lib) mkOption types;
in
let
  configurationType = types.listOf (types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      name = mkOption {
        type = types.str;
        example = "DP-1";
      };
      width = mkOption {
        type = with types; nullOr ints.positive;
        example = 1920;
      };
      height = mkOption {
        type = with types; nullOr ints.positive;
        example = 1080;
      };
      refreshRate = mkOption {
        type = with types; nullOr ints.positive;
        example = 60;
        default = null;
      };
      position = mkOption {
        type = with types; nullOr (submodule {
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
        });
        default = null;
      };
      scale = mkOption {
        type = with types; nullOr numbers.positive;
        default = null;
      };
    };
  });
in
{
  options.host = {
    bluetooth = mkOption {
      type = types.bool;
      default = false;
    };
    configurations = {
      default = mkOption {
        type = configurationType;
        default = [];
        description = "default configuration";
      };
      others = mkOption {
        type = types.listOf (types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "name of configuration";
            };
            configuration = mkOption {
              type = configurationType;
            };
          };
        });
        default = [];
        description = "other configurations";
      };
    };
  };
}
