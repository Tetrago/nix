{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
in
{
  options.tetrago.theme = {
    enable = mkEnableOption "enable default theme";
    variant = mkOption {
      type = types.enum [
        "Light"
        "Dark"
      ];
      default = "Dark";
    };
  };

  config = mkIf config.tetrago.theme.enable {
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

    gtk = {
      enable = true;

      font = {
        name = "Ubuntu Nerd Font";
        package = pkgs.nerd-fonts.ubuntu;
        size = 11;
      };

      theme = {
        name = "Colloid-${config.tetrago.theme.variant}";
        package = pkgs.colloid-gtk-theme;
      };

      iconTheme = {
        name = "Colloid-${config.tetrago.theme.variant}";
        package = pkgs.colloid-icon-theme;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk";
    };
  };
}
