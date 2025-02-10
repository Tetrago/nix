{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf getExe;

  bundle = pkgs.callPackage ./ags { inherit (inputs) ags; };
in
{
  config =
    let
      cfg = config.hyprworld;
    in
    mkIf cfg.enable {
      systemd.user.services.ags = {
        Unit = {
          ConditionEnvironment = "WAYLAND_DISPLAY";
          PartOf = [ config.wayland.systemd.target ];
          After = [ config.wayland.systemd.target ];
        };

        Service = {
          ExecStart = getExe bundle;
          Restart = "on-failure";
          RestartSec = "10";
        };

        Install = {
          WantedBy = [ config.wayland.systemd.target ];
        };
      };
    };
}
