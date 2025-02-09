{
  config,
  inputs,
  pkgs,
  ...
}:

let
  makeTheme = colors: {
    background = colors.base00;
    foreground = colors.base05;

    selection-background = colors.base02;
    selection-foreground = colors.base00;

    palette = [
      "0=#${colors.base00}"
      "1=#${colors.base08}"
      "2=#${colors.base0B}"
      "3=#${colors.base0A}"
      "4=#${colors.base0D}"
      "5=#${colors.base0E}"
      "6=#${colors.base0C}"
      "7=#${colors.base05}"
      "8=#${colors.base03}"
      "9=#${colors.base08}"
      "10=#${colors.base0B}"
      "11=#${colors.base0A}"
      "12=#${colors.base0D}"
      "13=#${colors.base0E}"
      "14=#${colors.base0C}"
      "15=#${colors.base07}"
      "16=#${colors.base09}"
      "17=#${colors.base0F}"
      "18=#${colors.base01}"
      "19=#${colors.base02}"
      "20=#${colors.base04}"
      "21=#${colors.base06}"
    ];
  };
in
{
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    clearDefaultKeybinds = true;
    package = inputs.ghostty.packages.${pkgs.system}.default;

    themes = {
      base16-dark = makeTheme config.colors.dark;
      base16-light = makeTheme config.colors.light;
    };

    settings = {
      theme = "dark:base16-dark,light:base16-light";

      font-family = "Monaspace Neon";
      font-family-italic = "Monaspace Radon";
      font-family-bold-italic = "Monaspace Radon";
      font-style = "Regular";
      font-style-bold = "Bold";
      font-style-italic = "Regular";
      font-style-bold-italic = "Bold";
      font-synthetic-style = false;
      font-feature = "calt, liga, ss01, ss02, ss03, ss04, ss07, ss08, ss09, ss10, cv01=2, cv10, cv11, cv30, cv31";

      background-opacity = 0.9;
      background-blur = true;

      linux-cgroup = "always";
      gtk-tabs-location = "bottom";
      copy-on-select = false;
      resize-overlay = "never";
      cursor-style = "bar";

      window-padding-x = 2;
      window-padding-y = 2;
      window-padding-balance = true;
      window-new-tab-position = "end";
      window-theme = "system";

      keybind = [
        "ctrl+shift+enter=new_tab"
        "ctrl+backslash=next_tab"
        "ctrl+shift+backslash=previous_tab"
        "alt+backslash=toggle_tab_overview"
        "ctrl+shift+alt+w=close_tab"

        "ctrl+shift+five=new_split:right"
        "ctrl+shift+apostrophe=new_split:down"
        "ctrl+shift+k=goto_split:up"
        "ctrl+shift+j=goto_split:down"
        "ctrl+shift+l=goto_split:right"
        "ctrl+shift+h=goto_split:left"
        "ctrl+shift+z=toggle_split_zoom"
        "ctrl+shift+plus=equalize_splits"
        "ctrl+shift+alt+x=close_surface"

        "performable:ctrl+shift+left=adjust_selection:left"
        "performable:ctrl+shift+right=adjust_selection:right"
        "performable:ctrl+shift+up=adjust_selection:up"
        "performable:ctrl+shift+down=adjust_selection:down"

        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"

        "ctrl+equal=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+zero=reset_font_size"
      ];
    };
  };

  home.packages = with pkgs; [
    monaspace
  ];
}
