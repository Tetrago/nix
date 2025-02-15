{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins) isString;
  inherit (lib)
    mkIf
    mkOption
    mkEnableOption
    types
    ;
  inherit (lib.attrsets) optionalAttrs mapAttrsToList;
  inherit (lib.strings) concatLines optionalString;
  inherit (lib.lists) optional;
  inherit (pkgs) writeShellScript writeText;

  cfg = config.hyprworld;

  mkThemeOption =
    description:
    mkOption {
      inherit description;
      type =
        with types;
        nullOr (submodule {
          options = {
            font = mkOption {
              type = nullOr (submodule {
                options = {
                  name = mkOption {
                    type = str;
                  };
                  size = mkOption {
                    type = positive;
                  };
                };
              });
              default = null;
            };

            cursorTheme = mkOption {
              type = nullOr (submodule {
                options = {
                  name = mkOption {
                    type = str;
                  };
                  size = mkOption {
                    type = ints.positive;
                  };
                };
              });
              default = null;
            };

            theme = mkOption {
              type = nullOr str;
              default = null;
            };

            iconTheme = mkOption {
              type = nullOr str;
              default = null;
            };
          };
        });
    };
in
{
  options.hyprworld = {
    theme = {
      enable = mkEnableOption "enable hyprworld theme handler";

      dark = mkThemeOption "dark theme";
      light = mkThemeOption "light theme";

      extraSettings = mkOption {
        type = with types; nullOr lines;
        description = "extra gtk3 settings";
        default = null;
        example = "gtk-decoration-layout=appmenu:none";
      };
    };
  };

  config = mkIf (cfg.enable && cfg.theme.enable) (
    let
      coalesceAttrs = attrs: {
        cursorTheme = if (attrs.cursorTheme != null) then attrs.cursorTheme else config.gtk.cursorTheme;
        font = if (attrs.font != null) then attrs.font else config.gtk.font;
        theme = if (attrs.theme != null) then attrs.theme else config.gtk.theme.name or null;
        iconTheme =
          if (attrs.iconTheme != null) then attrs.iconTheme else config.gtk.iconTheme.name or null;
      };

      mapTheme =
        attrs:
        let
          inherit (coalesceAttrs attrs)
            cursorTheme
            font
            theme
            iconTheme
            ;
        in
        optionalAttrs (cursorTheme != null) {
          gtk-cursor-theme-name = cursorTheme.name;
          gtk-cursor-theme-size = cursorTheme.size;
        }
        // optionalAttrs (font != null) {
          gtk-font-name = "${font.name} ${toString font.size}";
        }
        // optionalAttrs (theme != null) { gtk-theme-name = theme; }
        // optionalAttrs (iconTheme != null) { gtk-icon-theme-name = iconTheme; };

      mapToDconf =
        attrs:
        let
          inherit (coalesceAttrs attrs)
            cursorTheme
            font
            theme
            iconTheme
            ;
        in
        optionalAttrs (cursorTheme != null) {
          cursor-theme = cursorTheme.name;
          cursor-size = cursorTheme.size;
        }
        // optionalAttrs (font != null) { font-name = "${font.name} ${toString font.size}"; }
        // optionalAttrs (theme != null) { gtk-theme = theme; }
        // optionalAttrs (iconTheme != null) { icon-theme = iconTheme; };

      mapToGtk2Theme =
        theme:
        mapAttrsToList (
          k: v:
          let
            v' = if isString v then ''"${v}"'' else "${toString v}";
          in
          "${k} = ${v'}"
        ) (mapTheme theme);

      mapToGtk3Theme =
        theme:
        [ "[Settings]" ]
        ++ (mapAttrsToList (k: v: "${k}=${toString v}") (mapTheme theme))
        ++ optional (cfg.theme.extraSettings != null) cfg.theme.extraSettings;

      mkGtk2Config = theme: writeText ".gtkrc-2.0" (concatLines (mapToGtk2Theme theme));
      mkGtk3Config = theme: writeText "settings.ini" (concatLines (mapToGtk3Theme theme));

      mkDconfScript =
        theme:
        writeShellScript "update-dconf" (
          concatLines (
            mapAttrsToList (
              k: v: ''${pkgs.glib.bin}/bin/gsettings set org.gnome.desktop.interface ${k} "${toString v}"''
            ) (mapToDconf theme)
          )
        );

      setMode =
        theme:
        writeShellScript "setMode" ''
          GSETTINGS_SCHEMA_DIR="$(realpath ${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/*/*/schemas)" ${mkDconfScript theme}

          cp -f ${mkGtk2Config theme} $HOME/.gtkrc-2.0
          cp -f ${mkGtk3Config theme} $HOME/.config/gtk-3.0/settings.ini

          ${optionalString (
            theme.cursorTheme != null
          ) "hyprctl setcursor ${theme.cursorTheme.name} ${toString theme.cursorTheme.size}"}
        '';

      setDarkMode = setMode cfg.theme.dark;
      setLightMode = setMode cfg.theme.light;
    in
    {
      assertions = [
        {
          assertion = cfg.theme.dark != null && cfg.theme.light != null;
          message = "both theme variants must be set";
        }
        {
          assertion = !config.gtk.enable;
          message = "hyprworld.theme conflicts with gtk.enable";
        }
        {
          assertion =
            (cfg.theme.light.theme != null && cfg.theme.dark.theme != null)
            || (cfg.theme.light.theme == cfg.theme.dark.theme);
          message = "theme should be specified for both light and dark variants";
        }
        {
          assertion =
            (cfg.theme.light.iconTheme != null && cfg.theme.dark.iconTheme != null)
            || (cfg.theme.light.iconTheme == cfg.theme.dark.iconTheme);
          message = "icon theme should be specified for both light and dark variants";
        }
        {
          assertion =
            (cfg.theme.light.cursorTheme != null && cfg.theme.dark.cursorTheme != null)
            || (cfg.theme.light.cursorTheme == cfg.theme.dark.cursorTheme);
          message = "cursor theme should be specified for both light and dark variants";
        }
        {
          assertion =
            (cfg.theme.light.font != null && cfg.theme.dark.font != null)
            || (cfg.theme.light.font == cfg.theme.dark.font);
          message = "font should be specified for both light and dark variants";
        }
      ];

      hyprworld.scripts = {
        dark.updateTheme = setDarkMode;
        light.updateTheme = setLightMode;
      };

      home = {
        packages =
          optional (config.gtk.font.package or null != null) config.gtk.font.package
          ++ optional (config.gtk.iconTheme.package or null != null) config.gtk.iconTheme.package
          ++ optional (config.gtk.theme.package or null != null) config.gtk.theme.package
          ++ optional (config.gtk.cursorTheme.package or null != null) config.gtk.cursorTheme.package;
      };

      wayland.windowManager.hyprland.settings.exec = toString (
        writeShellScript "updateTheme" ''
          mode="$(darkman get)"

          if [ "$mode" = "dark" ]; then
            ${setDarkMode}
          elif [ "$mode" = "light" ]; then
            ${setLightMode}
          fi
        ''
      );
    }
  );
}
