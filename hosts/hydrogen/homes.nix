{
  james =
    {
      config,
      lib,
      outputs,
      pkgs,
      ...
    }:
    {
      imports = [ ../../homes/james/desktop ];

      programs = {
        looking-glass-client = {
          enable = true;
          settings = {
            app = {
              shmFile = "/dev/kvmfr0";
            };

            input = {
              escapeKey = 104;
            };
          };
        };

        obs-studio = {
          enable = true;
          plugins = [
            pkgs.obs-studio-plugins.looking-glass-obs
          ];
        };
      };

      home.packages = with pkgs; [
        onshape
        (
          (orca-slicer.override {
            wxGTK31 = (pkgs.wxGTK31.override { withEGL = false; }).overrideAttrs (
              final: prev: {
                buildInputs = (prev.buildInputs or [ ]) ++ [ pkgs.libsecret ];
              }
            );
          }).overrideAttrs
          (
            final: prev: {
              version = "zaa";

              src = fetchFromGitHub {
                owner = "OrcaSlicer";
                repo = "OrcaSlicer";
                rev = "4c493dd0d397ea1cecdd54eccb4e5db35c087306";
                hash = "sha256-vqxeYUOeUaR1Nir251hFPaXFrznlgMfm17dQdN1/nSo=";
              };

              buildInputs = (prev.buildInputs or [ ]) ++ [
                pkgs.draco
                pkgs.opencv
              ];

              cmakeFlags = (prev.cmakeFlags or [ ]) ++ [
                (lib.cmakeFeature "LIBNOISE_LIBRARY_RELEASE" "${pkgs.libnoise}/lib/libnoise-static.a")
              ];

              patches =
                builtins.filter (p: !(builtins.match ".*world.*" (toString p) != null)) (prev.patches or [ ])
                ++ [ ./orca-slicer.patch ];
            }
          )
        )
      ];
    };
}
