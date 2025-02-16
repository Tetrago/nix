{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options.tetrago.bluetooth = {
    enable = mkEnableOption "default bluetooth configuration.";
  };

  config =
    let
      cfg = config.tetrago.bluetooth;
    in
    mkIf cfg.enable {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

      services.blueman.enable = true;
    };
}
