{ config, lib, pkgs, ... }:

let
  inherit (builtins) mapAttrs;
  inherit (lib) types mkOption isDerivation;
in
{
  options.hyprworld = {
    services = mkOption {
      type = with types; attrsOf (either package str);
      description = "commands or packages to run for services";
      default = {};
    };
  };

  config.systemd.user.services = mapAttrs (_: atom: {
    Unit = {
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
    };

    Service = {
      ExecStart = if (isDerivation atom)
        then "${atom}/bin/${atom.pname}"
        else atom;
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
      Restart = "on-failure";
      KillMode = "mixed";
    };

    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  }) config.hyprworld.services;
}