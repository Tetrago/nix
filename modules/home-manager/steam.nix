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
  options.steam = {
    enable = mkEnableOption "enable steam compatibility tools";
  };

  config = mkIf config.steam.enable {
    home = {
      sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
      packages = [ pkgs.protonup ];
    };
  };
}
