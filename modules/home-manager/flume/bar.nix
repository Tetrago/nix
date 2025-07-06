{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;

  confirm = pkgs.writeShellScript "waybar-confirm" ''
    ${lib.getExe pkgs.zenity} \
      --question \
      --title="Confirmation" \
      --text="Are you sure you want to $1?" \
      --ok-label="Yes" \
      --cancel-label="No"

    [ $? -eq 0 ] && shift && exec "$@"
  '';
in
{
  config =
    let
      cfg = config.flume;
    in
    mkIf cfg.enable {
      home.packages = with pkgs; [
        adwaita-nerdfont
        networkmanagerapplet
      ];

      services = {
        blueman-applet.enable = true;
        mpris-proxy.enable = true;
        network-manager-applet.enable = true;

        udiskie = {
          enable = true;
          automount = true;
          notify = true;
        };
      };

      programs.waybar = {
        enable = true;
        systemd.enable = true;

        settings.mainBar = {
          layer = "top";
          position = "top";
          reload_style_on_change = true;

          output = [ "eDP-1" ];

          modules-left = [
            "group/clock"
          ];

          modules-right = [
            "tray"
            "battery"
            "group/menu"
          ];

          "group/clock" = {
            orientation = "horizontal";
            modules = [
              "custom/time"
              "custom/date"
              "group/system"
            ];
            drawer.transition-duration = 500;
          };

          "group/system" = {
            orientation = "horizontal";
            modules = [
              "cpu"
              "memory"
              "temperature"
            ];
          };

          cpu = {
            states = {
              warning = 60;
              critical = 90;
            };
            format = "{icon}";
            format-icons = [
              "󰪞"
              "󰪟"
              "󰪠"
              "󰪡"
              "󰪢"
              "󰪣"
              "󰪤"
              "󰪥"
            ];
          };

          memory = {
            format = "{icon}";
            format-icons = [
              "󰪞"
              "󰪟"
              "󰪠"
              "󰪡"
              "󰪢"
              "󰪣"
              "󰪤"
              "󰪥"
            ];
          };

          temperature = {
            states = {
              warning = 60;
              critical = 80;
            };
            format = "{icon}";
            format-icons = [
              "󰪞"
              "󰪟"
              "󰪠"
              "󰪡"
              "󰪢"
              "󰪣"
              "󰪤"
              "󰪥"
            ];
          };

          "custom/date" = {
            exec = pkgs.writeShellScript "waybar-date" ''
              day="$(date +%-d)"

              case "$day" in
              11 | 12 | 13) suffix="th" ;;
              *1)           suffix="st" ;;
              *2)           suffix="nd" ;;
              *3)           suffix="rd" ;;
              *)            suffix="th" ;;
              esac

              echo "$(date +%B) ''${day}''${suffix}, $(date +%Y)"
            '';
            interval = 1;
            tooltip = false;
          };

          "custom/time" = {
            exec = "date +'%-I:%M %p'";
            interval = 1;
            tooltip = false;
          };

          battery = {
            states = {
              good = 85;
              warning = 30;
              critical = 20;
            };
            format = "{icon}";
            format-charging = "󰂄";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
            tooltip-format = "{capacity}% {timeTo}";
          };

          "group/menu" = {
            orientation = "horizontal";
            modules = [
              "custom/menu"
              "custom/sleep"
              "custom/logout"
              "custom/reboot"
              "custom/poweroff"
            ];
            drawer = {
              transition-duration = 500;
              transition-left-to-right = false;
            };
          };

          "custom/menu" = {
            format = "󰒓";
            tooltip = false;
          };

          "custom/sleep" = {
            format = "󰤄";
            tooltip = false;
            on-click = "${confirm} suspend systemctl suspend";
          };

          "custom/logout" = {
            format = "󰍃";
            tooltip = false;
            on-click = "${confirm} \"log out\" loginctl kill-user $USER --signal=SIGINT";
          };

          "custom/reboot" = {
            format = "󰜉";
            tooltip = false;
            on-click = "${confirm} reboot systemctl -i reboot";
          };

          "custom/poweroff" = {
            format = "󰐥";
            tooltip = false;
            on-click = "${confirm} shutdown systemctl -i poweroff";
          };
        };

        style = ''
          * {
            font-size: 16px;
            font-family: "AdwaitaSans Nerd Font";
          }

          window#waybar {
            all: unset;
          }

          #custom-time, #custom-date, #system {
            margin: 8px 0 0 8px;
            padding: 5px 8px;
            border-radius: 16px;
            color: @theme_fg_color;
            background-color: alpha(@theme_bg_color, 0.3);
            border: 1px solid alpha(@theme_fg_color, 0.1);
            background-image: linear-gradient(to bottom, alpha(@theme_bg_color, 0.2), alpha(@theme_bg_color, 0.4));
          }

          #system, #menu {
            padding: 1px 8px;
          }

          #cpu, #memory, #temperature {
            font-size: 26px;
            padding: 0 4px;
          }

          #custom-sleep, #custom-logout, #custom-reboot, #custom-poweroff {
            font-size: 20px;
            padding: 0 4px;
          }

          #tray, #battery, #menu {
            margin: 8px 8px 0 0;
            padding: 5px 8px;
            border-radius: 16px;
            color: @theme_fg_color;
            background-color: alpha(@theme_bg_color, 0.3);
            border: 1px solid alpha(@theme_fg_color, 0.1);
            background-image: linear-gradient(to bottom, alpha(@theme_bg_color, 0.2), alpha(@theme_bg_color, 0.4));
          }

          #custom-date {
            padding-left: 12px;
          }

          #battery.charging {
            color: @success_color;
          }

          #battery.warning:not(.charging) {
            color: @warning_color;
          }

          #battery.critical:not(.charging) {
            color: @error_color;
          }

          #cpu.warning, #temperature.warning {
            color: @warning_color;
          }

          #cpu.critical, #temperature.critical {
            color: @error_color;
          }
        '';
      };
    };
}
