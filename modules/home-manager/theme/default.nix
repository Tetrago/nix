{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.theme = {
    variant = lib.mkOption {
      type = lib.types.enum [
        "light"
        "dark"
      ];
      default = "dark";
    };
  };

  config = {
    home = {
      pointerCursor = {
        name = "capitaine-cursors";
        package = pkgs.capitaine-cursors;
        gtk.enable = true;
      };
    };

    gtk = {
      enable = true;

      font = {
        name = "Ubuntu Nerd Font";
        package = pkgs.nerdfonts.override { fonts = [ "Ubuntu" ]; };
        size = 11;
      };

      theme = {
        name = "flat-remix-gtk-variant-${config.theme.variant}";
        package = pkgs.flat-remix-gtk-variant.override {
          highlight-color = config.colorScheme.palette.base01;
          highlight-text-color = config.colorScheme.palette.base06;
        };
      };

      iconTheme = {
        name = "Flat-Remix-Grey-Light";
        package = pkgs.flat-remix-icon-theme;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk";
    };
  };
}
