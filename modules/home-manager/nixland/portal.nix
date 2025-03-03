{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins) isString;
  inherit (lib)
    mkAfter
    mkIf
    mkOption
    types
    ;
  inherit (lib.attrsets) attrValues mapAttrs mapAttrs';
  inherit (lib.lists) findFirst flatten;

  portalType =
    let
      type =
        with types;
        either str (submodule {
          options = {
            package = mkOption {
              type = package;
            };

            name = mkOption {
              type = str;
            };
          };
        });
    in
    types.coercedTo type (x: [ x ]) (types.listOf type);

  resolvePortalPackage =
    sources: name:
    let
      source = findFirst (v: v ? "xdg-desktop-portal-${name}") null sources;
    in
    assert source != null || throw "Could not find portal `${name}` in sources";
    source."xdg-desktop-portal-${name}";

  collectPortalPackages =
    sources: portal: map (v: if isString v then resolvePortalPackage sources v else v.package) portal;

  collectPortalNames = portal: map (v: if isString v then v else v.name) portal;
in
{
  options.nixland = {
    portal = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };

      sources = mkOption {
        type = types.listOf types.attrs;
      };

      default = mkOption {
        type = portalType;
        default = [
          "hyprland"
          "gtk"
        ];
      };

      portals = mkOption {
        type = types.attrsOf portalType;
      };

      extraPortals = mkOption {
        type = types.attrsOf portalType;
        default = { };
      };
    };
  };

  config =
    let
      cfg = config.nixland;
    in
    mkIf (cfg.enable && cfg.portal.enable) {
      nixland.portal.sources = mkAfter [ pkgs ];

      xdg.portal =
        let
          all =
            mapAttrs' (n: value: {
              name = "org.freedesktop.impl.portal.${n}";
              inherit value;
            }) cfg.portal.portals
            // cfg.portal.extraPortals
            // {
              inherit (cfg.portal) default;
            };
        in
        {
          enable = true;
          config.hyprland = mapAttrs (_: collectPortalNames) all;
          extraPortals = flatten (map (collectPortalPackages cfg.portal.sources) (attrValues all));
        };
    };
}
