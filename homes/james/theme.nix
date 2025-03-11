{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [ inputs.polymorph.homeManagerModules.theme ];

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
          name = "Ubuntu Nerd Font";
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
          nerd-fonts.ubuntu
          phinger-cursors
          colloid-icon-theme
        ];
      };

      dark = {
        cursorTheme = {
          name = "phinger-cursors-dark";
          size = 24;
        };

        iconTheme.name = "Colloid-Dark";
        theme.name = "Colloid-Dark-Catppuccin";
      };

      light = {
        cursorTheme = {
          name = "phinger-cursors-light";
          size = 24;
        };

        iconTheme.name = "Colloid-Light";
        theme.name = "Colloid-Light-Catppuccin";
      };
    };
  };
}
