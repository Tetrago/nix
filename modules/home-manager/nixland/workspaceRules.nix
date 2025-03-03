{ config, lib, ... }:

let
  inherit (lib) mkOption mkIf types;
  inherit (lib.strings) concatStringsSep;

  options = with types; {
    workspace = mkOption {
      type = str;
    };

    rules = mkOption {
      type = types.coercedTo types.str (x: [ x ]) (types.listOf types.str);
    };
  };

  writeRule = rule: concatStringsSep "," ([ rule.workspace ] ++ rule.rules);
in
{
  options.nixland = {
    workspaceRules = mkOption {
      type = types.listOf (
        types.submodule {
          inherit options;
        }
      );
      default = [ ];
    };
  };

  config =
    let
      cfg = config.nixland;
    in
    mkIf cfg.enable {
      wayland.windowManager.hyprland.settings.workspace = map writeRule cfg.workspaceRules;
    };
}
