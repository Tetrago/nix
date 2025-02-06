{ pkgs, ... }:

{
  home = {
    pointerCursor = {
      name = "capitaine-cursors";
      package = pkgs.capitaine-cursors;
      gtk.enable = true;
    };

    packages = with pkgs; [
      gnome-themes-extra
    ];
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  services = {
    xsettingsd.enable = true;
  };

  gtk = {
    font = {
      name = "Ubuntu Nerd Font";
      size = 11;
      package = pkgs.nerd-fonts.ubuntu;
    };

    iconTheme = {
      package = pkgs.whitesur-icon-theme;
    };

    theme = {
      package = pkgs.colloid-gtk-theme;
    };
  };

  hyprworld.theme = {
    dark = {
      theme = "Colloid-Dark";
      iconTheme = "WhiteSur-dark";
      cursorTheme.name = "capitaine-cursors";
    };

    light = {
      theme = "Colloid-Light";
      iconTheme = "WhiteSur-light";
      cursorTheme.name = "capitaine-cursors-white";
    };

    extraSettings = ''
      gtk-decoration-layout=appmenu:none
    '';
  };
}
