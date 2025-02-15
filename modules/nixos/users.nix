{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption types;
  inherit (lib.attrsets) mapAttrs;
in
{
  options.tetrago.users = mkOption {
    type =
      with types;
      attrsOf (submodule {
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
            default = [ ];
            example = [ "wheel" ];
          };

          shell = mkOption {
            type = types.package;
            default = pkgs.bashInteractive;
          };
        };
      });
  };

  config.users.users =
    let
      cfg = config.tetrago.users;
    in
    mapAttrs (name: value: {
      isNormalUser = true;
      description = mkIf (value.name != null) value.name;

      createHome = true;
      home = "/home/${value.username}";

      shell = value.shell;
      extraGroups = value.groups;
    }) cfg;
}
