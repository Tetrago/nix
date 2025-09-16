{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.james.terminal = {
    enable = mkEnableOption "terminal configuration.";
  };

  config =
    let
      cfg = config.james.terminal;
    in
    mkIf cfg.enable {
      programs.ghostty = {
        enable = true;
        enableBashIntegration = true;
        clearDefaultKeybinds = true;
        package = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;

        settings = {
          theme = "dark:Chalk,light:farmhouse-light";

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

          gtk-tabs-location = "bottom";
          copy-on-select = false;
          resize-overlay = "never";
          cursor-style = "bar";
          linux-cgroup = "always";

          window-padding-x = 4;
          window-padding-y = 4;
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
    };
}
