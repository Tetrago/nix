{ config, lib, ... }:

let
  inherit (lib) mkOption mkIf types;
  inherit (lib.lists) flatten optional;
  inherit (lib.strings) concatStringsSep;

  options = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };

    class = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    title = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    rules = mkOption {
      type = types.coercedTo types.str (x: [ x ]) (types.listOf types.str);
    };
  };

  writeWindow =
    rule:
    concatStringsSep "," (
      optional (rule.class != null) "class:${rule.class}"
      ++ optional (rule.title != null) "title:${rule.title}"
    );

  mapRule = rule: map (v: "${v},${writeWindow rule}") rule.rules;
in
{
  options.nixland = {
    windowRules = mkOption {
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
      wayland.windowManager.hyprland.settings.windowrulev2 = flatten (map mapRule cfg.windowRules);
    };
}
