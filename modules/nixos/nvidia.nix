{ config, lib, ... }:

{
  options.nvidia = {
    enable = lib.mkEnableOption "enable Nvidia support";
    enableModesetting = lib.mkEnableOption "enable modesetting";
  };

  config = lib.mkIf config.nvidia.enable {
    hardware.nvidia = {
      modesetting.enable = config.nvidia.enableModesetting;
      nvidiaSettings = true;
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };

    services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
  };
}
