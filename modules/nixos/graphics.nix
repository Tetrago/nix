{
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    mkForce
    mkMerge
    mkIf
    types
    ;
in
{
  options.tetrago.graphics = {
    enable = mkEnableOption "graphics configuration.";
    nvidia = {
      enable = mkEnableOption "NVIDIA graphics support.";

      modesetting = mkOption {
        type = types.bool;
        default = true;
      };

      blacklist = mkOption {
        type = types.bool;
        default = false;
        description = "Blacklist NVIDIA drivers.";
      };
    };

    intel = {
      enable = mkEnableOption "Intel graphics support.";
    };
  };

  config =
    let
      cfg = config.tetrago.graphics;
    in
    mkIf cfg.enable (mkMerge [
      {
        assertions = [
          {
            assertion = cfg.nvidia.enable != cfg.intel.enable;
            message = "Cannot enable multiple drivers";
          }
          {
            assertion = !(cfg.nvidia.enable && cfg.nvidia.blacklist);
            message = "Cannot both enable and blacklist NVIDA drivers";
          }
        ];
      }
      (mkIf cfg.nvidia.enable {
        hardware.nvidia = {
          nvidiaSettings = true;
          modesetting.enable = cfg.nvidia.modesetting;
          open = false;
          package = config.boot.kernelPackages.nvidiaPackages.beta;
        };

        services.xserver.videoDrivers = mkForce [ "nvidia" ];
      })

      (mkIf cfg.nvidia.blacklist {
        boot.blacklistedKernelModules = [
          "nouveau"
          "nvidia"
        ];
      })

      (mkIf (cfg.intel.enable || cfg.nvidia.enable) {
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };
      })
    ]);
}
