{ config, pkgs, ... }:

let
  palette = import ./palette.nix { inherit config pkgs; };
in
{
  home.file.".config/hypr/hyprlock.conf".text = ''
    background {
      monitor =
      path = screenshot
      blur_passes = 3
      contrast = 0.8916
      brightness = 0.6172
      vibrancy = 0.1696
      vibrancy_darkness = 0.0
    }

    label {
      monitor =
      text = cmd[update:1000] echo "$(date +"%-I:%M %p")"
      color = rgb(#${palette.fg})
      font_size = 120
      position = 0, 100
      halign = center
      valign = center
    }

    input-field {
      monitor = 
      size = 300, 50
      outline_thickness = 3
      dots_size = 0.33
      dots_spacing = 0.15
      dots_center = false
      dots_rounding = -1
      outer_color = rgb(${palette.fg})
      inner_color = rgb(${palette.bg})
      font_color = rgb(${palette.fg})
      fade_on_empty = true
      fade_timeout = 1000
      placeholder_text =
      hide_input = false
      rounding = -1
      check_color = rgb(${palette.light-bg})
      fail_color = rgb(${palette.dark-bg})
      fail_text =
      fail_transition = 300

      position = 0, -50
      halign = center
      valign = center
    }
  '';
}