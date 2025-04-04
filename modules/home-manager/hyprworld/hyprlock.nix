{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption types;
in
{
  options.hyprworld = {
    lockscreen.background = mkOption {
      type = with types; nullOr path;
      description = "background image for lockscreen or null for screenshot.";
      default = null;
    };
  };

  config =
    let
      cfg = config.hyprworld;
    in
    mkIf cfg.enable {
      polymorph.file = [ "${config.xdg.configHome}/hypr/hyprlock.conf" ];

      home.packages = with pkgs; [
        adwaita-fonts
      ];

      programs.hyprlock = {
        enable = true;
        settings = {
          background = [
            {
              path = if (cfg.lockscreen.background) != null then "${cfg.lockscreen.background}" else "screenshot";
              blur_passes = 3;
              contrast = 0.8916;
              brightness = 0.6172;
              vibrancy = 0.1696;
              vibrancy_darkness = 0.0;
            }
          ];

          label = [
            {
              text = ''cmd[update:1000] echo "$(date +"%-I:%M %p")"'';
              color = "rgb(#{{ .colors.base05 }})";
              font_size = 120;
              font_family = "Adwaita Sans";
              position = "0, 100";
              halign = "center";
              valign = "center";
            }
          ];

          input-field = [
            {
              size = "300, 50";
              outline_thickness = 3;
              dots_size = 0.33;
              dots_spacing = 0.15;
              dots_center = false;
              dots_rounding = -1;
              outer_color = "rgb(#{{ .colors.base05 }})";
              inner_color = "rgb(#{{ .colors.base00 }})";
              font_color = "rgb(#{{ .colors.base05 }})";
              fade_on_empty = true;
              fade_timeout = 1000;
              placeholder_text = "";
              hide_input = false;
              rounding = -1;
              check_color = "rgb(#{{ .colors.base07 }})";
              fail_color = "rgb(#{{ .colors.base06 }})";
              fail_text = "";
              fail_transition = 300;

              position = "0, -50";
              halign = "center";
              valign = "center";
            }
          ];
        };
      };
    };
}
