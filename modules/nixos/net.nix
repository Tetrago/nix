{ lib, config, ... }:

{
  options = {
    net.enable = lib.mkEnableOption "enable default networking options";

    net.hostname = lib.mkOption {
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
  };
}
