{ config, lib, ... }:

let
  inherit (lib) mkIf;
in
{
  config =
    let
      cfg = config.hyprworld;
    in
    mkIf cfg.enable {
      polymorph.file = [ "${config.xdg.configHome}/swaync/style.css" ];

      services.swaync = {
        enable = true;

        settings = {
          control-center-height = 2;
          control-center-layer = "overlay";
          control-center-margin-bottom = 20;
          control-center-margin-left = 0;
          control-center-margin-right = 10;
          control-center-margin-top = 20;
          control-center-width = 500;
          cssPriority = "application";
          control-center-positionX = "right";
          control-center-positionY = "center";
          fit-to-screen = true;
          hide-on-action = false;
          hide-on-clear = true;
          image-visibility = "when-available";
          keyboard-shortcuts = true;
          layer = "layer";
          notification-body-image-height = 100;
          notification-body-image-width = 200;
          notification-icon-size = 40;
          notification-inline-replies = true;
          notification-visibility = { };
          notification-window-width = 400;
          positionX = "right";
          positionY = "top";
          script-fail-notify = true;
          scripts = { };
          timeout = 10;
          timeout-critical = 0;
          timeout-low = 5;
          transition-time = 100;
          widget-config = {
            mpris = {
              image-radius = 12;
              image-size = 96;
            };
            title = {
              text = "Notifications";
              button-text = "󰎟 Clear";
              clear-all-button = true;
            };
          };

          widgets = [
            "title"
            "notifications"
            "mpris"
          ];
        };

        style = ''
          * {
            font-size: 14px;
            font-family: "Noto Sans";
            transition: 100ms;
            box-shadow: unset;
          }

          .control-center .notification-row {
            background-color: unset;
          }

          .control-center .notification-row .notification-background .notification,
          .control-center .notification-row .notification-background .notification .notification-content,
          .floating-notifications .notification-row .notification-background .notification,
          .floating-notifications.background .notification-background .notification .notification-content {
            margin-bottom: unset;
          }

          .control-center .notification-row .notification-background .notification {
            margin-top: 0.150rem;
          }

          .control-center .notification-row .notification-background .notification box,
          .control-center .notification-row .notification-background .notification widget,
          .control-center .notification-row .notification-background .notification .notification-content,
          .floating-notifications .notification-row .notification-background .notification box,
          .floating-notifications .notification-row .notification-background .notification widget,
          .floating-notifications.background .notification-background .notification .notification-content {
            border: unset;
            border-radius: 1.159rem;
            -gtk-outline-radius: 1.159rem;
            
          }

          .floating-notifications.background .notification-background .notification .notification-content,
          .control-center .notification-background .notification .notification-content {
          /*  border-top: 1px solid rgba(164, 162, 167, 0.15);
            border-left: 1px solid rgba(164, 162, 167, 0.15);
            border-right: 1px solid rgba(128, 127, 132, 0.15);
            border-bottom: 1px solid rgba(128, 127, 132, 0.15);*/
            background-color: @theme_bg_color;
            padding: 0.818rem;
            padding-right: unset;
            margin-right: unset;
          }

          .control-center .notification-row .notification-background .notification.low .notification-content label,
          .control-center .notification-row .notification-background .notification.normal .notification-content label,
          .floating-notifications.background .notification-background .notification.low .notification-content label,
          .floating-notifications.background .notification-background .notification.normal .notification-content label {
            color: @theme_fg_color;
          }

          .control-center .notification-row .notification-background .notification..notification-content image,
          .control-center .notification-row .notification-background .notification.normal .notification-content image,
          .floating-notifications.background .notification-background .notification.low .notification-content image,
          .floating-notifications.background .notification-background .notification.normal .notification-content image {
            background-color: unset;
            color: @theme_text_color;
          }

          .control-center .notification-row .notification-background .notification.low .notification-content .body,
          .control-center .notification-row .notification-background .notification.normal .notification-content .body,
          .floating-notifications.background .notification-background .notification.low .notification-content .body,
          .floating-notifications.background .notification-background .notification.normal .notification-content .body {
            color: @theme_unfocused_fg_color;
          }

          .control-center .notification-row .notification-background .notification.critical .notification-content,
          .floating-notifications.background .notification-background .notification.critical .notification-content {
            background-color: @error_color;
          }

          .control-center .notification-row .notification-background .notification.critical .notification-content image,
          .floating-notifications.background .notification-background .notification.critical .notification-content image{
            background-color: unset;
            color: @error_color;
          }

          .control-center .notification-row .notification-background .notification.critical .notification-content label,
          .floating-notifications.background .notification-background .notification.critical .notification-content label {
            color: @theme_base_color;
          }

          .control-center .notification-row .notification-background .notification .notification-content .summary,
          .floating-notifications.background .notification-background .notification .notification-content .summary {
            font-family: 'Gabarito', 'Lexend', sans-serif;
            font-size: 0.9909rem;
            font-weight: 500;
          }

          .control-center .notification-row .notification-background .notification .notification-content .time,
          .floating-notifications.background .notification-background .notification .notification-content .time {
            font-family: 'Geist', 'AR One Sans', 'Inter', 'Roboto', 'Noto Sans', 'Ubuntu', sans-serif;
            font-size: 0.8291rem;
            font-weight: 500;
            margin-right: 1rem;
            padding-right: unset;
          }

          .control-center .notification-row .notification-background .notification .notification-content .body,
          .floating-notifications.background .notification-background .notification .notification-content .body {
            font-family: 'Noto Sans', sans-serif;
            font-size: 0.8891rem;
            font-weight: 400;
            margin-top: 0.310rem;
            padding-right: unset;
            margin-right: unset;
          }

          .control-center .notification-row .close-button,
          .floating-notifications.background .close-button {
            background-color: unset;
            border-radius: 100%;
            border: none;
            box-shadow: none;
            margin-right: 13px;
            margin-top: 6px;
            margin-bottom: unset;
            padding-bottom: unset;
            min-height: 20px;
            min-width: 20px;
            text-shadow: none;
          }

          .control-center .notification-row .close-button:hover,
          .floating-notifications.background .close-button:hover {
            background-color: @theme_selected_bg_color;
          }

          .control-center {
            border-radius: 1.705rem;
            -gtk-outline-radius: 1.705rem;
            border-top: 1px solid alpha(@theme_fg_color, 0.19);
            border-left: 1px solid alpha(@theme_fg_color, 0.19);
            border-right: 1px solid alpha(@theme_unfocused_fg_color, 0.145);
            border-bottom: 1px solid alpha(@theme_unfocused_fg_color, 0.145);
            box-shadow: 0px 2px 3px rgba(0, 0, 0, 0.45);
            margin: 7px;
            background-color: @theme_base_color;
            padding: 1.023rem;
          }

          .control-center trough {
            background-color: @insensitive_bg_color;
            border-radius: 9999px;
            -gtk-outline-radius: 9999px;
            min-width: 0.545rem;
            background-color: transparent;  
          }

          .control-center slider {
            border-radius: 9999px;
            -gtk-outline-radius: 9999px;
            min-width: 0.273rem;
            min-height: 2.045rem;
            background-color: alpha(@theme_selected_bg_color, 0.31);
          }

          .control-center slider:hover {
            background-color: alpha(@theme_selected_bg_color, 0.448);
          }

          .control-center slider:active {
            background-color: @theme_selected_bg_color;
          }

          /* title widget */

          .widget-title {
            padding: 0.341rem;
            margin: unset;
          }

          .widget-title label {
            font-family: 'Gabarito', 'Lexend', sans-serif;
            font-size: 1.364rem;
            color: @theme_fg_color;
            margin-left: 0.941rem;
          }

          .widget-title button {
            border: unset;
            background-color: unset;
            border-radius: 1.159rem;
            -gtk-outline-radius: 1.159rem;
            padding: 0.141rem 0.141rem;
            margin-right: 0.841rem;
          }

          .widget-title button label {
            font-family: 'Gabarito', sans-serif;
            font-size: 1.0409rem;
            color: @theme_fg_color;
            margin-right: 0.841rem;
          }

          .widget-title button:hover {
            background-color: alpha(@theme_selected_bg_color, 0.3);
          }

          .widget-title button:active {
            background-color: alpha(@theme_selected_bg_color, 0.7);
          }


          /* Volume widget */

          .widget-volume {
            background-color: alpha(@theme_bg_color, 0.35);
            padding: 8px;
            margin: 8px;
            border-radius: 1.159rem;
            -gtk-outline-radius: 1.159rem;
          }

          .widget-volume trough {
            border: unset;
            background-color: alpha(@insensitive_bg_color, 0.4);
          }


          .widget-volume trough slider {
            color: unset;
            background-color: @warning_color;
            border-radius: 100%;
            min-height: 1.25rem;
          }


          /* Mpris widget */

          .widget-mpris {
            background-color: alpha(@theme_bg_color, 0.35);
            padding: 8px;
            margin: 8px;  
            border-radius: 1.159rem;
            -gtk-outline-radius: 1.159rem;  
          }

          .widget-mpris-player {
            padding: 8px;
            margin: 8px;
          }

          .widget-mpris-title {
            font-weight: bold;
            font-size: 1.25rem;
          }

          .widget-mpris-subtitle {
            font-size: 1.1rem;
          }
        '';
      };
    };
}
