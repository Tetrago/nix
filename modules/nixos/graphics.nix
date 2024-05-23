{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption mkForce mkMerge mkIf types;
in
{
  options.tetrago.graphics = {
    nvidia = {
      enable = mkEnableOption "enable Nvidia support";

      modesetting = mkOption {
        type = types.bool;
        default = true;
      };
    };

    opengl = {
      enable = mkEnableOption "enable OpenGL";
    };
  };

  config = with config.tetrago.graphics; mkMerge [
    (mkIf nvidia.enable {
      hardware.nvidia = {
        nvidiaSettings = true;
        modesetting.enable = nvidia.modesetting;
        open = false;
        package = config.boot.kernelPackages.nvidiaPackages.beta;
      };

      services.xserver.videoDrivers = mkForce [ "nvidia" ];
    })

    (mkIf opengl.enable {
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };
    })
  ];
}
