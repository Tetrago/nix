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

      lock = pkgs.writeShellScript "flume-lock" ''
        if ! pidof gtklock > /dev/null; then
          ${lib.getExe pkgs.gtklock} -m ${pkgs.gtklock-userinfo-module}/lib/gtklock/userinfo-module.so &
          PID=$!

          sleep 1

          if kill -0 "$PID" 2>/dev/null; then
            dbus-send --session --dest=org.freedesktop.secrets \
              --type=method_call  \
              /org/freedesktop/secrets \
              org.freedesktop.Secret.Service.Lock \
              array:objpath:/org/freedesktop/secrets/collection/login
          fi
        fi
      '';
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
            command = "${lock}";
          }
          {
            event = "lock";
            command = "${lock}";
          }
        ];
      };
    };
}
