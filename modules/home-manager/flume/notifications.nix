{ config, lib, ... }:

let
  inherit (lib) mkIf;
in
{
  config =
    let
      cfg = config.flume;
    in
    mkIf cfg.enable {
      polymorph = {
        file = [ "${config.xdg.configHome}/dunst/dunstrc" ];

        morph = {
          dark.extraScripts = "systemctl --user restart dunst.service";
          light.extraScripts = "systemctl --user restart dunst.service";

          dark.context.dunst = {
            foreground = "#e0e0e0";
            frame_color = "#1e1e1e";
            highlight = "#ffffff, #bbbbbb";

            critical = {
              low = "#1e1e1ef0";
              normal = "#1e1e1ef0";
              high = "#5c2e2ef0";
              frame_color = "#5c3a3a";
              highlight = "#d75c5c";
            };
          };

          light.context.dunst = {
            foreground = "#1e1e1e";
            frame_color = "#f5f5f5";
            highlight = "#000000, #555555";

            critical = {
              low = "#f4f4f4f0";
              normal = "#f4f4f4f0";
              high = "#f3c7c7f0";
              frame_color = "#e8cfcf";
              highlight = "#b03030";
            };
          };
        };
      };

      services.dunst = {
        enable = true;
        settings = {
          global = {
            follow = "mouse";
            width = 350;
            height = "0x300";
            origin = "top-right";
            offset = "35x35";
            indicate_hidden = "yes";
            notification_limit = 5;
            gap_size = 12;
            padding = 12;
            horizontal_padding = 20;
            frame_width = 1;
            sort = "no";

            progress_bar_frame_width = 0;
            progress_bar_corner_radius = 3;

            foreground = "{{ .dunst.foreground }}";
            frame_color = "{{ .dunst.frame_color }}";
            highlight = "{{ .dunst.highlight }}";

            font = "AdwaitaSans Nerd Font 10";
            markup = "full";
            format = "<small>%a</small>\n<b>%s</b>\n%b";
            alignment = "left";
            vertical_alignment = "center";
            show_age_threshold = -1;
            hide_duplicate_count = false;

            icon_position = "left";
            min_icon_size = 54;
            max_icon_size = 80;
            icon_corner_radius = 4;

            dmenu = "sherlock"; # NOTE: No idea if this works, nor do I care.
            corner_radius = 10;

            mouse_left_click = "close_current";
            mouse_middle_click = "do_action, close_current";
            mouse_right_click = "close_all";
          };

          urgency_low = {
            background = "{{ .dunst.critical.low }}";
            timeout = 3;
          };

          urgency_normal = {
            background = "{{ .dunst.critical.normal }}";
            timeout = 8;
          };

          urgency_critical = {
            background = "{{ .dunst.critical.high }}";
            frame_color = "{{ .dunst.critical.frame_color }}";
            highlight = "{{ .dunst.critical.highlight }}";
            timeout = 0;
          };

          fullscreen_delay_everything = {
            fullscreen = "delay";
          };

          fullscreen_show_critical = {
            msg_urgency = "critical";
            fullscreen = "show";
          };
        };
      };
    };
}
