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
  inherit (lib.strings) concatLines;
  inherit (lib.lists) optional;

  cfg = config.hyprworld.theme;
in
{
  config = mkIf (cfg != null) (
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
        theme: [ "[Settings]" ] ++ (mapAttrsToList (k: v: "${k}=${toString v}") (mapTheme theme));

      makeGtk2Config = theme: pkgs.writeText ".gtkrc-2.0" (concatLines (mapToGtk2Theme theme));
      makeGtk3Config = theme: pkgs.writeText "settings.ini" (concatLines (mapToGtk3Theme theme));

      makeDconfScript =
        theme:
        pkgs.writeShellScript "update-dconf" (
          concatLines (
            mapAttrsToList (
              k: v: ''${pkgs.glib.bin}/bin/gsettings set org.gnome.desktop.interface ${k} "${toString v}"''
            ) (mapToDconf theme)
          )
        );

      set-mode =
        theme:
        pkgs.writeShellScript "set-dark-mode" ''
          GSETTINGS_SCHEMA_DIR="$(realpath ${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/*/*/schemas)" ${makeDconfScript theme}

          cp -f ${makeGtk2Config theme} $HOME/.gtkrc-2.0
          cp -f ${makeGtk3Config theme} $HOME/.config/gtk-3.0/settings.ini
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
      ];

      xdg.dataFile = {
        "dark-mode.d/update-theme".source = set-dark-mode;
        "light-mode.d/update-theme".source = set-light-mode;
      };

      home.packages =
        optional (config.gtk.font.package or null != null) config.gtk.font.package
        ++ optional (config.gtk.iconTheme.package or null != null) config.gtk.iconTheme.package
        ++ optional (config.gtk.theme.package or null != null) config.gtk.theme.package
        ++ optional (config.gtk.cursorTheme.package or null != null) config.gtk.cursorTheme.package;

      wayland.windowManager.hyprland.settings.exec =
        let
          update-theme = pkgs.writeShellScript "update-theme" ''
            if [ "$(darkman get)" = "light" ]; then
              ${set-light-mode}
            elif [ "$(darkman get)" = "dark" ]; then
              ${set-dark-mode}
            fi
          '';
        in
        [
          "${update-theme}"
        ];
    }
  );
}
