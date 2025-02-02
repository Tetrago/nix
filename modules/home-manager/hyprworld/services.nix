{
  config,
  lib,
  ...
}:

let
  inherit (builtins) mapAttrs;
  inherit (lib)
    types
    mkOption
    isDerivation
    getExe
    ;
in
{
  options.hyprworld = {
    services = mkOption {
      type = with types; attrsOf (either package str);
      description = "commands or packages to run for services";
      default = { };
    };
  };

  config.systemd.user.services = mapAttrs (_: atom: {
    Unit = {
      ConditionEnvironment = "WAYLAND_DISPLAY";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
    };

    Service = {
      ExecStart = if (isDerivation atom) then "${getExe atom}" else atom;
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  }) config.hyprworld.services;
}
