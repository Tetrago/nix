{
  pkgs,
  outputs,
  ...
}:

{
  imports = [ outputs.homeManagerModules.lemur ];

  home = {
    packages = with pkgs; [
      gnome-themes-extra
    ];
  };

  lemur = {
    enable = true;

    darkman.enable = true;
    default.name = "dark";

    variant = {
      default = {
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

        scripts = ''
          hyprctl setcursor phinger-cursors-dark 24
        '';
      };

      light = {
        cursorTheme = {
          name = "phinger-cursors-light";
          size = 24;
        };

        iconTheme.name = "Colloid-Light";
        theme.name = "Colloid-Light-Catppuccin";

        scripts = ''
          hyprctl setcursor phinger-cursors-light 24
        '';
      };
    };
  };
}
