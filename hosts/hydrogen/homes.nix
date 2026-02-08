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
        orca-slicer
      ];
    };
}
