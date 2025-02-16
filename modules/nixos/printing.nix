{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.tetrago.printing = {
    enable = mkEnableOption "printing services.";
  };

  config =
    let
      cfg = config.tetrago.printing;
    in
    mkIf cfg.enable {
      services = {
        avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
        };

        printing.enable = true;
      };
    };
}
