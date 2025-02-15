{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.tetrago.steam = {
    enable = mkEnableOption "steam compatibility tools";
  };

  config =
    let
      cfg = config.tetrago.steam;
    in
    mkIf cfg.enable {
      home = {
        sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
        packages = [ pkgs.protonup ];
      };
    };
}
