{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkOption types;
  inherit (lib.lists) optional;

  mkListener =
    time: attrs:
    optional (time != null) (
      {
        timeout = time * 60;
      }
      // attrs
    );
in
{
  options.hyprworld = {
    idle = {
      lock = mkOption {
        type = with types; nullOr ints.positive;
        description = "minutes of inactivity until the screen locks.";
        default = 5;
      };

      screen = mkOption {
        type = with types; nullOr ints.positive;
        description = "minutes of inactivity until the screen turns off.";
        default = 10;
      };

      sleep = mkOption {
        type = with types; nullOr ints.positive;
        description = "minutes of inactivity until the system suspend.";
        default = 15;
      };
    };
  };

  config =
    let
      cfg = config.hyprworld;
    in
    mkIf cfg.enable {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
            ignore_dbus_inhibit = false;
          };

          listener =
            mkListener cfg.idle.lock {
              on-timeout = "loginctl lock-session";
            }
            ++ mkListener cfg.idle.screen {
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
            ++ mkListener cfg.idle.sleep {
              on-timeout = "systemctl suspend";
            };
        };
      };
    };
}
