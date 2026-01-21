{
  james =
    {
      config,
      outputs,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib) mkForce;
    in
    {
      imports = [ ../../homes/james/desktop ];

      home.packages = with pkgs; [
        alpaca
      ];

      nixland = {
        #autoConnect = true;

        monitor = {
          "eDP-1" = {
            size = {
              width = 2256;
              height = 1504;
            };

            scale = 1.3333;
            switch = "Lid Switch";
          };

          "DP-7" = {
            size = {
              width = 2560;
              height = 1440;
            };

            refreshRate = 120;

            position = {
              x = 0;
              y = 0;
            };
          };

          "DP-6" = {
            size = {
              width = 1920;
              height = 1080;
            };

            position = {
              x = 2560;
              y = 0;
            };
          };

          "DP-5" = {
            size = {
              width = 1920;
              height = 1080;
            };

            position = {
              x = -1920;
              y = 0;
            };
          };
        };
      };

      hyprworld = {
        bluetooth.enable = true;
        globalScale = 1.5;

        idle = {
          sleep = null;
        };

        wallpaper.transition = {
          step = 10;
          fps = 60;
        };
      };

      wayland.windowManager.hyprland.settings.decoration = {
        blur.enabled = mkForce false;
        shadow.enabled = mkForce false;
      };
    };
}
