{ config, lib, ... }:

let
  inherit (builtins) isString;
  inherit (lib) mkIf mkOption types;
  inherit (lib.attrsets) filterAttrs mapAttrs mapAttrsToList;
  inherit (lib.strings) concatStringsSep optionalString;

  options = with types; {
    enable = mkOption {
      type = types.bool;
      default = true;
    };

    size = mkOption {
      type =
        either
          (enum [
            "preferred"
            "highres"
          ])
          (submodule {
            options = {
              width = mkOption { type = ints.positive; };
              height = mkOption { type = ints.positive; };
            };
          });
      default = "preferred";
    };

    refreshRate = mkOption {
      type = nullOr (either (enum [ "highrr" ]) ints.positive);
      default = null;
    };

    position = mkOption {
      type = nullOr (
        either
          (enum [
            "left"
            "right"
            "up"
            "down"
          ])
          (submodule {
            options = {
              x = mkOption { type = int; };
              y = mkOption { type = int; };
            };
          })
      );
      default = null;
    };

    scale = mkOption {
      type = nullOr numbers.positive;
      default = null;
    };

    workspace = mkOption {
      type = nullOr ints.positive;
      default = null;
    };

    extra = mkOption {
      type = listOf str;
      default = [ ];
    };
  };

  writeResolution =
    monitor:
    if isString monitor.size then
      monitor.size
    else
      "${toString monitor.size.width}x${toString monitor.size.height}";

  writeDisplay =
    monitor:
    "${writeResolution monitor}${
      optionalString (monitor.refreshRate != null) "@${toString monitor.refreshRate}"
    }";

  writePosition =
    monitor:
    if isNull monitor.position then
      "auto"
    else if isString monitor.position then
      "auto-${monitor.position}"
    else
      "${toString monitor.position.x}x${toString monitor.position.y}";

  writeScale = monitor: if isNull monitor.scale then "1" else toString monitor.scale;

  writeMonitor =
    monitor:
    if monitor.enable then
      concatStringsSep "," (
        [
          (writeDisplay monitor)
          (writePosition monitor)
          (writeScale monitor)
        ]
        ++ monitor.extra
      )
    else
      "disable";

  writeWorkspaceRule = name: monitor: {
    workspace = toString monitor.workspace;
    rules = "monitor:${name}";
  };
in
{
  options.nixland = {
    monitor = mkOption {
      type = types.attrsOf (
        types.submodule {
          inherit options;
        }
      );
      example = {
        "" = { };
        "eDP-1" = {
          size = {
            width = 1920;
            height = 1080;
          };
        };
      };
    };

    monitorRules = mkOption {
      type = types.attrsOf types.str;
      internal = true;
    };
  };

  config =
    let
      cfg = config.nixland;
    in
    mkIf cfg.enable {
      nixland = {
        monitorRules = mapAttrs (n: v: "${n},${writeMonitor v}") cfg.monitor;

        workspaceRules = mapAttrsToList writeWorkspaceRule (
          filterAttrs (_: v: v.enable && v.workspace != null) cfg.monitor
        );
      };

      wayland.windowManager.hyprland.settings.monitor = mapAttrsToList (_: v: v) cfg.monitorRules;
    };
}
