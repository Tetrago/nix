{ config, lib, ... }:

let inherit (lib) mkEnableOption mkIf;
in {
  options.tetrago.bluetooth = { enable = mkEnableOption "enable bluetooth"; };

  config = mkIf config.tetrago.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = true;
  };
}
