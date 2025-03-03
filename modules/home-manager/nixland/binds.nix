{ config, lib, ... }:

let
  inherit (builtins)
    attrNames
    filter
    isAttrs
    isList
    isString
    length
    head
    map
    ;
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    ;
  inherit (lib.attrsets) genAttrs mapAttrs;
  inherit (lib.strings)
    concatStrings
    concatStringsSep
    optionalString
    toUpper
    ;

  flags = {
    locked = "l";
    release = "r";
    long = "o";
    repeat = "e";
    non-consuming = "n";
    mouse = "m";
    transparent = "t";
    ignore = "i";
    separate = "s";
    bypass = "p";
  };

  modifiers = [
    "super"
    "ctrl"
    "alt"
    "shift"
  ];

  options =
    {
      enable = mkOption {
        type = types.bool;
        default = true;
      };

      action = mkOption {
        type = types.anything;
        description = "Evaluates attrset names and lists into comma separated values";
      };

      trigger = mkOption {
        type = with types; coercedTo anything toString str;
        default = "";
      };

      flags = mkOption {
        type =
          let
            enum = types.enum (attrNames flags);
          in
          types.nullOr (types.either enum (types.listOf enum));
        default = null;
      };
    }
    // genAttrs modifiers (
      n:
      mkOption {
        type = types.bool;
        default = n == "super";
      }
    );

  writeAction =
    action:
    if isList action then
      concatStringsSep "," (map writeAction action)
    else if isAttrs action && length (attrNames action) == 1 then
      let
        n = head (attrNames action);
      in
      "${n},${writeAction action.${n}}"
    else
      toString action;

  writeFlags =
    field:
    if isNull field then
      ""
    else if isList field then
      concatStrings (map writeFlags field)
    else
      flags.${field};

  writeBind =
    bind:
    "${
      concatStringsSep " " (map (n: optionalString bind.${n} " ${toUpper n}") modifiers)
    },${bind.trigger}, ${writeAction bind.action}";
in
{
  options.nixland = {
    mod = mkOption {
      description = "mod key combination bind";
      type = types.str;
      default = "SUPER";
    };

    binds = mkOption {
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
      wayland.windowManager.hyprland.settings = mkMerge (
        map (v: {
          "bind${writeFlags v.flags}" = [
            (writeBind v)
          ];
        }) (filter (v: v.enable) cfg.binds)
      );
    };
}
