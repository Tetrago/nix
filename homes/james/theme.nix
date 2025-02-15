{
  pkgs,
  outputs,
  ...
}:

{
  imports = [ outputs.homeManagerModules.lemur ];

  home = {
    pointerCursor = {
      name = "phinger-cursors-light";
      size = 24;
      package = pkgs.phinger-cursors;
    };

    packages = with pkgs; [
      gnome-themes-extra
    ];
  };

  lemur = {
    enable = true;
    darkman.enable = true;

    variant = {
      default = {
        font = {
          name = "Ubuntu Nerd Font";
          size = 11;
        };

        packages = with pkgs; [
          colloid-gtk-theme
          nerd-fonts.ubuntu
          phinger-cursors
          whitesur-icon-theme
        ];
      };

      dark = {
        cursorTheme = {
          name = "phinger-cursors-dark";
          size = 24;
        };

        iconTheme.name = "WhiteSur-dark";
        theme.name = "Colloid-Dark";

        scripts = ''
          hyprctl setcursor phinger-cursors-dark 24
        '';
      };

      light = {
        cursorTheme = {
          name = "phinger-cursors-light";
          size = 24;
        };

        iconTheme.name = "WhiteSur-light";
        theme.name = "Colloid-Light";

        scripts = ''
          hyprctl setcursor phinger-cursors-light 24
        '';
      };
    };
  };
}
