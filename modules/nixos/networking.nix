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
    enable = mkEnableOption "enable default networking options";

    hostname = mkOption {
      type = types.str;
      description = "hostname";
    };
  };

  config =
    with config.tetrago.networking;
    mkIf enable {
      networking = {
        hostName = "${hostname}";
        networkmanager.enable = true;
        firewall.enable = true;
      };

      services.automatic-timezoned.enable = true;
    };
}
