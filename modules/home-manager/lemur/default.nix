{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins)
    isString
    toString
    ;

  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;

  inherit (lib.attrsets)
    mapAttrs
    mapAttrsToList
    optionalAttrs
    recursiveUpdate
    ;

  inherit (lib.lists)
    flatten
    unique
    ;

  inherit (lib.strings) concatLines escape;

  inherit (pkgs) writeShellScript writeText;
in
{
  options.lemur =
    let
      mkNullable =
        options:
        mkOption {
          type = types.nullOr (
            types.submodule {
              inherit options;
            }
          );
          default = null;
        };

      options = {
        cursorTheme = mkNullable {
          name = mkOption { type = types.str; };
          size = mkOption { type = types.ints.positive; };
        };

        font = mkNullable {
          name = mkOption { type = types.str; };
          size = mkOption { type = types.int.positive; };
        };

        iconTheme = mkNullable {
          name = mkOption { type = types.str; };
        };

        theme = mkNullable {
          name = mkOption { type = types.str; };
        };

        packages = mkOption {
          type = types.listOf types.package;
          description = "Packages required for this variant (themes, icons, cursors, ...)";
          default = [ ];
        };

        scripts = mkOption {
          type = types.lines;
          description = "Scripts to run when activating this variant";
          default = "";
        };
      };
    in
    {
      enable = mkEnableOption "lemur theme engine";

      qt.enable = mkEnableOption "gtk qt backend";
      xwayland.enable = mkEnableOption "XWayland requirements";

      darkman = {
        enable = mkEnableOption "darkman integration";

        darkVariant = mkOption {
          type = types.str;
          description = "Name of variant to use for dark mode";
          default = "dark";
        };

        lightVariant = mkOption {
          type = types.str;
          description = "Name of variant to use for light mode";
          default = "light";
        };
      };

      variant = mkOption {
        type = types.attrsOf (types.submodule { inherit options; });
        default = { };
      };

      apply = mkOption {
        type = types.attrsOf types.path;
        internal = true;
      };
    };

  config =
    let
      cfg = config.lemur;

      mapVariant =
        variant:
        let
          hasCursorTheme = variant.cursorTheme != null;
          hasFont = variant.font != null;
          hasIconTheme = variant.iconTheme != null;
          hasTheme = variant.theme != null;

          gtkValues =
            optionalAttrs hasCursorTheme {
              gtk-cursor-theme-name = variant.cursorTheme.name;
              gtk-cursor-theme-size = variant.cursorTheme.size;
            }
            // optionalAttrs hasFont {
              gtk-font-name = "${variant.font.name} ${toString variant.font.size}";
            }
            // optionalAttrs hasIconTheme {
              gtk-icon-theme-name = variant.iconTheme.name;
            }
            // optionalAttrs hasTheme {
              gtk-theme-name = variant.theme.name;
            };

          dconfValues =
            optionalAttrs hasCursorTheme {
              cursor-size = variant.cursorTheme.size;
              cursor-theme = variant.cursorTheme.name;
            }
            // optionalAttrs hasFont {
              font-name = "${variant.font.name} ${toString variant.font.size}";
            }
            // optionalAttrs hasIconTheme {
              icon-theme = variant.iconTheme.name;
            }
            // optionalAttrs hasTheme {
              gtk-theme = variant.theme.name;
            };

          rc =
            let
              format = n: v: "${escape [ "=" ] n} = ${if isString v then ''"${v}"'' else toString v}";
            in
            writeText "gtkrc-2.0" (concatLines (mapAttrsToList format gtkValues));

          ini = lib.generators.toINI { } { Settings = gtkValues; };

          dconf =
            let
              write =
                n: v:
                ''dconf write /org/gnome/desktop/interface/${n} "${if isString v then "'${v}'" else toString v}"'';
            in
            writeShellScript "dconf" (concatLines (mapAttrsToList write dconfValues));
        in
        {
          inherit rc ini dconf;

          activate = writeShellScript "activate" ''
            cp -f ${rc} $HOME/.gtkrc-2.0

            mkdir -p $XDG_CONFIG_HOME/gtk-3.0
            cp -f ${ini} $XDG_CONFIG_HOME/gtk-3.0/settings.ini

            mkdir -p $XDG_CONFIG_HOME/gtk-4.0
            cp -f ${ini} $XDG_CONFIG_HOME/gtk-4.0/settings.ini

            ${dconf}

            ${variant.scripts}
          '';
        };

      mergedVariant =
        if (cfg.variant ? default) then
          mapAttrs (
            n: v:
            if n == "default" then v else recursiveUpdate (removeAttrs cfg.variant.default [ "scripts" ]) v
          ) cfg.variant
        else
          cfg.variant;

      variant = mapAttrs (_: mapVariant) mergedVariant;
    in
    mkIf cfg.enable {
      assertions = mkMerge [
        [
          {
            assertion = !config.gtk.enable;
            message = "Lemur conflicts with gtk module";
          }
        ]
        (mkIf cfg.darkman.enable [
          {
            assertion = cfg.variant ? "${cfg.darkman.darkVariant}";
            message = "Dark mode variant missing";
          }
          {
            assertion = cfg.variant ? "${cfg.darkman.lightVariant}";
            message = "Light mode variant missing";
          }
        ])
      ];

      home = {
        file = {
          ".gtkrc-2.0".enable = false;
        };

        packages = unique (flatten (mapAttrsToList (_: v: v.packages) cfg.variant));
      };

      xdg.configFile = {
        "gtk-3.0/settings.ini".enable = false;
        "gtk-4.0/settings.ini".enable = false;
      };

      lemur = {
        qt.enable = mkDefault true;
        xwayland.enable = mkDefault true;

        apply = mapAttrs (_: v: v.activate) variant;
      };

      services = mkMerge [
        (mkIf cfg.darkman.enable {
          darkman = {
            darkModeScripts.lemur = cfg.apply.${cfg.darkman.darkVariant};
            lightModeScripts.lemur = cfg.apply.${cfg.darkman.lightVariant};
          };
        })
        (mkIf cfg.xwayland.enable {
          xsettingsd.enable = true;
        })
      ];

      qt = mkIf cfg.qt.enable {
        enable = true;
        platformTheme.name = "gtk";
      };
    };
}
