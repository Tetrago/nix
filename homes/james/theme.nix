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
      home.packages = with pkgs; [
        gnome-themes-extra
      ];

      polymorph.theme = {
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
              ];
            })
            adwaita-nerdfont
            phinger-cursors
            papirus-icon-theme
          ];
        };

        dark = {
          cursorTheme = {
            name = "phinger-cursors-dark";
            size = 24;
          };

          iconTheme.name = "Papirus-Dark";
          theme.name = "Colloid-Dark";
        };

        light = {
          cursorTheme = {
            name = "phinger-cursors-light";
            size = 24;
          };

          iconTheme.name = "Papirus-Light";
          theme.name = "Colloid-Light";
        };
      };
    };
}
