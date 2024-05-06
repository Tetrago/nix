{ config, lib, ... }:

{
  options.nvidia = {
    enable = lib.mkEnableOption "enable Nvidia support";
  };

  config = lib.mkIf config.nvidia.enable {
    hardware.nvidia = {
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
  };
}
