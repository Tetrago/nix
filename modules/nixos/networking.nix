{ lib, config, ... }:

let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
in
{
  options.tetrago.networking = {
    enable = mkEnableOption "default networking configuration";

    hostname = mkOption {
      type = types.str;
      description = "hostname";
    };
  };

  config =
    let
      cfg = config.tetrago.networking;
    in
    mkIf cfg.enable {
      networking = {
        hostName = "${cfg.hostname}";
        networkmanager.enable = true;
        firewall.enable = true;
      };

      services.automatic-timezoned.enable = true;
    };
}
