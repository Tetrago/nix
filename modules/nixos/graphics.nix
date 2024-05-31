{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption mkForce mkMerge mkIf types;
in
{
  options.tetrago.graphics = {
    nvidia = {
      enable = mkEnableOption "enable NVIDIA support";

      modesetting = mkOption {
        type = types.bool;
        default = true;
      };

      blacklist = mkOption {
        type = types.bool;
        default = false;
        description = "blacklist NVIDIA drivers";
      };
    };

    intel = {
      enable = mkEnableOption "enable Intel support";
    };
  };

  config = with config.tetrago.graphics; mkMerge [
    ({
      assertions = [
        {
          assertion = nvidia.enable != intel.enable;
          message = "cannot enable multiple drivers";
        }
        {
          assertion = !(nvidia.enable && nvidia.blacklist);
          message = "cannot both enable and blacklist NVIDA drivers";
        }
      ];
    })

    (mkIf nvidia.enable {
      hardware.nvidia = {
        nvidiaSettings = true;
        modesetting.enable = nvidia.modesetting;
        open = false;
        package = config.boot.kernelPackages.nvidiaPackages.beta;
      };

      services.xserver.videoDrivers = mkForce [ "nvidia" ];
    })

    (mkIf nvidia.blacklist {
      boot.blacklistedKernelModules = [ "nouveau" "nvidia" ];
    })

    (mkIf intel.enable {
      hardware.opengl.extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
      ];
    })

    (mkIf (intel.enable || nvidia.enable) {
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };
    })
  ];
}
