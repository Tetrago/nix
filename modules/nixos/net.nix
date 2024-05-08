{ lib, config, ... }:

let
  inherit (lib) mkEnableOption mkOption types;
in
{
  options.net = {
    enable = mkEnableOption "enable default networking options";
    hostname = mkOption {
      type = types.str;
      description = "hostname";
    };
  };
  
  config = lib.mkIf config.net.enable {
    networking = {
      hostName = "${config.net.hostname}";
      networkmanager.enable = true;
      firewall.enable = true;
      nftables.enable = true;
    };

    services.automatic-timezoned.enable = true;
  };
}
