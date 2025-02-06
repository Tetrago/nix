{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (builtins) isString;
  inherit (lib) mkIf;
  inherit (lib.attrsets) optionalAttrs mapAttrsToList;
  inherit (lib.strings) concatLines optionalString;
  inherit (lib.lists) optional;

  cfg = config.hyprworld.theme;
in
{
  config = mkIf (cfg != null) (
    let
      inherit (pkgs) writeShellScript writeText;

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
        ++ optional (cfg.extraSettings != null) cfg.extraSettings;

      makeGtk2Config = theme: writeText ".gtkrc-2.0" (concatLines (mapToGtk2Theme theme));
      makeGtk3Config = theme: writeText "settings.ini" (concatLines (mapToGtk3Theme theme));

      makeDconfScript =
        theme:
        writeShellScript "update-dconf" (
          concatLines (
            mapAttrsToList (
              k: v: ''${pkgs.glib.bin}/bin/gsettings set org.gnome.desktop.interface ${k} "${toString v}"''
            ) (mapToDconf theme)
          )
        );

      set-mode =
        theme:
        writeShellScript "set-dark-mode" ''
          GSETTINGS_SCHEMA_DIR="$(realpath ${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/*/*/schemas)" ${makeDconfScript theme}

          cp -f ${makeGtk2Config theme} $HOME/.gtkrc-2.0
          cp -f ${makeGtk3Config theme} $HOME/.config/gtk-3.0/settings.ini

          ${optionalString (
            theme.cursorTheme != null
          ) "hyprctl setcursor ${theme.cursorTheme.name} ${toString theme.cursorTheme.size}"}
        '';

      set-dark-mode = set-mode cfg.dark;
      set-light-mode = set-mode cfg.light;
    in
    {
      assertions = [
        {
          assertion = !config.gtk.enable;
          message = "hyprworld.theme conflicts with gtk.enable";
        }
        {
          assertion =
            (cfg.light.theme != null && cfg.dark.theme != null) || (cfg.light.theme == cfg.dark.theme);
          message = "theme should be specified for both light and dark variants";
        }
        {
          assertion =
            (cfg.light.iconTheme != null && cfg.dark.iconTheme != null)
            || (cfg.light.iconTheme == cfg.dark.iconTheme);
          message = "icon theme should be specified for both light and dark variants";
        }
        {
          assertion =
            (cfg.light.cursorTheme != null && cfg.dark.cursorTheme != null)
            || (cfg.light.cursorTheme == cfg.dark.cursorTheme);
          message = "icon theme should be specified for both light and dark variants";
        }
        {
          assertion = (cfg.light.font != null && cfg.dark.font != null) || (cfg.light.font == cfg.dark.font);
          message = "font should be specified for both light and dark variants";
        }
      ];

      xdg.dataFile = {
        "dark-mode.d/update-theme".source = set-dark-mode;
        "light-mode.d/update-theme".source = set-light-mode;
      };

      home = {
        packages =
          optional (config.gtk.font.package or null != null) config.gtk.font.package
          ++ optional (config.gtk.iconTheme.package or null != null) config.gtk.iconTheme.package
          ++ optional (config.gtk.theme.package or null != null) config.gtk.theme.package
          ++ optional (config.gtk.cursorTheme.package or null != null) config.gtk.cursorTheme.package;
      };

      wayland.windowManager.hyprland.settings.exec =
        let
          update-theme = pkgs.writeShellScript "update-theme" ''
            mode="$(darkman get)"

            if [ "$mode" = "dark" ]; then
              ${set-dark-mode}
            elif [ "$mode" = "light" ]; then
              ${set-light-mode}
            fi
          '';
        in
        [
          "${update-theme}"
        ];
    }
  );
}
