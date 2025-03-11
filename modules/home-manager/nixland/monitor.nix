{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins) attrValues isString;
  inherit (lib)
    getExe
    mkIf
    mkOption
    types
    ;
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

    switch = mkOption {
      type =
        with types;
        coercedTo str (x: { name = x; }) (submodule {
          options = {
            enable = mkOption {
              type = bool;
              default = true;
            };

            name = mkOption {
              type = str;
            };

            invert = mkOption {
              type = bool;
              default = false;
            };
          };
        });
      default = {
        enable = false;
      };
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
    autoConnect = mkOption {
      type = types.bool;
      description = "Whether or not to connect attached monitors";
      default = false;
    };

    monitor = mkOption {
      type = types.attrsOf (
        types.submodule {
          inherit options;
        }
      );
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
        binds =
          let
            monitors = filterAttrs (_: v: v.enable && v.switch.enable) cfg.monitor;
          in
          mapAttrsToList (n: v: {
            super = false;
            trigger = "switch:${if v.switch.invert then "no" else "yes"}:${v.switch.name}";
            flags = "locked";
            action.exec = ''["$(hyprctl monitors -j | ${getExe pkgs.jq} 'length')" -gt 1 ] && hyprctl keyword monitor "${n},disable"'';
          }) monitors
          ++ mapAttrsToList (n: v: {
            super = false;
            trigger = "switch:${if v.switch.invert then "yes" else "no"}:${v.switch.name}";
            flags = "locked";
            action.exec = ''hyprctl keyword monitor "${n},${config.nixland.monitorRules.${n}}"'';
          }) monitors;

        monitor = mkIf cfg.autoConnect {
          "" = { };
        };

        monitorRules = mapAttrs (n: v: "${n},${writeMonitor v}") cfg.monitor;

        workspaceRules = mapAttrsToList writeWorkspaceRule (
          filterAttrs (_: v: v.enable && v.workspace != null) cfg.monitor
        );
      };

      wayland.windowManager.hyprland.settings.monitor = attrValues cfg.monitorRules;
    };
}
