{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.james.theme = {
    enable = mkEnableOption "polymorph theme configuration.";
  };

  config =
    let
      cfg = config.james.theme;
    in
    mkIf cfg.enable {
      home = {
        packages = with pkgs; [
          gnome-themes-extra
        ];
      };

      polymorph = {
        darkman.enable = true;

        morph =
          let
            hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
          in
          {
            dark = {
              follows = "common";
              extraScripts = "${hyprctl} setcursor phinger-cursors-dark 24";
            };

            light = {
              follows = "common";
              extraScripts = "${hyprctl} setcursor phinger-cursors-light 24";
            };
          };

        theme = {
          common = {
            font = {
              name = "AdwaitaSans Nerd Font";
              size = 11;
            };

            packages = with pkgs; [
              (colloid-gtk-theme.override {
                tweaks = [
                  "normal"
                  "rimless"
                  "catppuccin"
                ];
              })
              adwaita-nerdfont
              phinger-cursors
              tela-icon-theme
            ];
          };

          dark = {
            cursorTheme = {
              name = "phinger-cursors-dark";
              size = 24;
            };

            iconTheme.name = "Tela-dark";
            theme.name = "Colloid-Dark-Catppuccin";
          };

          light = {
            cursorTheme = {
              name = "phinger-cursors-light";
              size = 24;
            };

            iconTheme.name = "Tela";
            theme.name = "Colloid-Light-Catppuccin";
          };
        };
      };
    };
}
