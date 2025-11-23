{
  config,
  inputs,
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
      polymorph = {
        file = [ "${config.xdg.configHome}/hypr/hyprlock.conf" ];
        morph.common.extraScripts = "swaync-client --reload-css";
      };

      home.packages = with pkgs; [
        adwaita-fonts
      ];

      programs.hyprlock = {
        enable = true;
        package = inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;
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
              text = ''cmd[update:1000] echo "$(date +"%A, %B, %d")"'';
              color = "rgb({{ .colors.base04 }})";
              font_size = 20;
              font_family = "Adwaita Sans";
              position = "0, 405";
              halign = "center";
              valign = "center";
            }
            {
              text = ''cmd[update:1000] echo "$(date +"%-I:%M %p")"'';
              color = "rgb({{ .colors.base06 }})";
              font_size = 93;
              font_family = "Adwaita Sans";
              position = "0, 310";
              halign = "center";
              valign = "center";
            }
          ];

          input-field = [
            {
              size = "300, 50";
              outline_thickness = 0;
              dots_size = 0.25;
              dots_spacing = 0.55;
              dots_center = true;
              dots_rounding = -1;
              outer_color = "rgb({{ .colors.base03 }})";
              inner_color = "rgb({{ .colors.base00 }})";
              font_color = "rgb({{ .colors.base07 }})";
              fade_on_empty = true;
              placeholder_text = "";
              hide_input = false;
              check_color = "rgb({{ .colors.base0B }})";
              fail_color = "rgb({{ .colors.base08 }})";
              fail_text = "$FAIL <b>($ATTEMPTS)</b>";
              capslock_color = -1;
              numlock_color = -1;
              bothlock_color = -1;
              invert_numlock = false;
              swap_font_color = false;
              position = "0, -468";
              halign = "center";
              valign = "center";
            }
          ];
        };
      };
    };
}
