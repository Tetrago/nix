{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
in
{
  config =
    let
      cfg = config.flume;
    in
    mkIf cfg.enable {
      services.swayidle = {
        enable = true;

        timeouts = [
          {
            timeout = 300;
            command = "loginctl lock-session";
          }
          {
            timeout = 360;
            command = "niri msg output eDP-1 off";
            resumeCommand = "niri msg output eDP-1 on";
          }
        ];

        events = [
          {
            event = "before-sleep";
            command = "loginctl lock-session";
          }
          {
            event = "lock";
            command = lib.getExe pkgs.gtklock;
          }
        ];
      };
    };
}
