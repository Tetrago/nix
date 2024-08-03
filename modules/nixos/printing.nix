{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.tetrago.printing = {
    enable = mkEnableOption "enable printing services";
  };

  config = mkIf config.tetrago.printing.enable {
    services = {
      avahi = {
        enable = true;
        nssmdns = true;
        openFirewall = true;
      };

      printing.enable = true;
    };
  };
}
