{ lib, config, ... }:

let
  inherit (lib) mkEnableOption mkOption types;
in
{
  options.net = {
    enable = mkEnableOption "enable default networking options";
    enableNftables = mkOption {
      type = types.bool;
      default = true;
    };
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
      nftables.enable = config.net.enableNftables;
    };

    services.automatic-timezoned.enable = true;
  };
}
