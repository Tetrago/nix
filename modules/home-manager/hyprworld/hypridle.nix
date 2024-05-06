{ config, lib, pkgs, ... }:

let
  inherit (config.hyprworld) time;

  iff = value: content: lib.strings.optionalString (value != 0) content;
in
{
  home.file.".config/hypr/hypridle.conf".text = ''
    general {
      lock_cmd = pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock
      before_sleep_cmd = loginctl lock-session
      after_sleep_cmd = hyprctl dispatch dpms on
      ignore_dbus_inhibit = false
    }

    ${iff time.lock ''
    listener {
      timeout = ${toString (time.lock * 60)}
      on-timeout = loginctl lock-session
    }
    ''}

    ${iff time.screen ''
    listener {
      timeout = ${toString (time.screen * 60)}
      on-timeout = hyprctl dispatch dpms off
      on-resume = hyprctl dispatch dpms on
    }
    ''}

    ${iff time.sleep ''
    listener {
      timeout = ${toString (time.sleep * 60)}
      on-timeout = systemctl suspend
    }
    ''}
  '';

  systemd.user.services.hypridle = import ./service.nix pkgs "${pkgs.hypridle}/bin/hypridle";
}