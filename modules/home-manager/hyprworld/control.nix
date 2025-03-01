{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;

  dim = pkgs.chayang.overrideAttrs (
    final: prev: {
      patches = prev.patches or [ ] ++ [ ./remove-cancel.patch ];
    }
  );

  wrap =
    name: command:
    pkgs.writeShellScriptBin "hyprworld-${name}" ''
      ${command}
      ${lib.getExe dim}
      hyprctl dispatch dpms off
    '';
in
{
  config =
    let
      cfg = config.hyprworld;
    in
    mkIf cfg.enable {
      home.packages = [
        (wrap "shutdown" "systemctl -i poweroff")
        (wrap "reboot" "systemctl -i reboot")
      ];
    };
}
