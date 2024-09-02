{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    shellIntegration.enableBashIntegration = true;

    font = {
      package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };

    keybindings = {
      "ctrl+shift+h" = "neighboring_window left";
      "ctrl+shift+l" = "neighboring_window right";
      "ctrl+shift+k" = "neighboring_window up";
      "ctrl+shift+j" = "neighboring_window down";

      "ctrl+shift+left" = "resize_window narrower";
      "ctrl+shift+right" = "resize_window wider";
      "ctrl+shift+up" = "resize_window taller";
      "ctrl+shift+down" = "resize_window shorter";

      "ctrl+shift+w" = "move_window up";
      "ctrl+shift+a" = "move_window left";
      "ctrl+shift+s" = "move_window down";
      "ctrl+shift+d" = "move_window right";

      "ctrl+shift+5" = "launch --cwd=current --location=vsplit";
      "ctrl+shift+'" = "launch --cwd=current --location=hsplit";
      "ctrl+shift+enter" = "launch --cwd=current --type=tab";

      "ctrl+\\" = "next_tab";
      "ctrl+shift+\\" = "previous_tab";

      "ctrl+shift+n" = "new_os_window_with_cwd";
    };

    settings =
      let
        colors = config.colorScheme.palette;
      in
      {
        shell = "${pkgs.bashInteractive}/bin/bash -l";

        background_opacity = "0.9";
        window_padding_width = "0 2";
        enabled_layouts = "splits";

        background = "#${colors.base00}";
        foreground = "#${colors.base05}";
        selection_background = "#${colors.base05}";
        selection_foreground = "#${colors.base00}";
        url_color = "#${colors.base04}";
        cursor = "#${colors.base05}";
        active_border_color = "#${colors.base03}";
        inactive_border_color = "#${colors.base01}";
        active_tab_background = "#${colors.base00}";
        active_tab_foreground = "#${colors.base05}";
        inactive_tab_background = "#${colors.base01}";
        inactive_tab_foreground = "#${colors.base04}";
        tab_bar_background = "#${colors.base01}";

        color0 = "#${colors.base00}";
        color1 = "#${colors.base08}";
        color2 = "#${colors.base0B}";
        color3 = "#${colors.base0A}";
        color4 = "#${colors.base0D}";
        color5 = "#${colors.base0E}";
        color6 = "#${colors.base0C}";
        color7 = "#${colors.base05}";

        color8 = "#${colors.base03}";
        color9 = "#${colors.base08}";
        color10 = "#${colors.base0B}";
        color11 = "#${colors.base0A}";
        color12 = "#${colors.base0D}";
        color13 = "#${colors.base0E}";
        color14 = "#${colors.base0C}";
        color15 = "#${colors.base07}";

        color16 = "#${colors.base09}";
        color17 = "#${colors.base0F}";
        color18 = "#${colors.base01}";
        color19 = "#${colors.base02}";
        color20 = "#${colors.base04}";
        color21 = "#${colors.base06}";
      };
  };
}
