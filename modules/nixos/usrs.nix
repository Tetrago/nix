{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkOption types;
in
{
  options.usrs = mkOption {
    type = with types; attrsOf (submodule {
      options = {
        username = mkOption {
          type = types.str;
          example = "james";
        };
        name = mkOption {
          type = with types; nullOr str;
          example = "James";
          default = null;
        };
        groups = mkOption {
          type = with types; listOf str;
          default = [];
          example = [ "wheel" ];
        };
        shell = mkOption {
          type = types.package;
          default = pkgs.bashInteractive;
        };
      };
    });
  };

  config.users.users = lib.attrsets.mapAttrs (name: value: {
    isNormalUser = true;
    description = mkIf (!(isNull value.name)) value.name;

    createHome = true;
    home = "/home/${value.username}";

    shell = value.shell;
    extraGroups = value.groups;
  }) config.usrs;
}