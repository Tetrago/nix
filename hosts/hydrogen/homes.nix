{
  james =
    {
      config,
      outputs,
      pkgs,
      ...
    }:
    {
      imports = [ (import ../../homes/james/desktop) ];

      home.packages =
        let
          openttd = (
            import (builtins.fetchTarball {
              url = "https://github.com/NixOS/nixpkgs/archive/18e3cb306213bf2d58e28515624d2f5cf3740ea8.tar.gz";
              sha256 = "sha256:18z9f1r05dfr2i4lvm58dnhfqqm27zhrbh0imjcsj92xkvc9hrjh";
            }) { inherit (pkgs) system; }
          );
        in
        [
          openttd.openttd-jgrpp
        ];

      xdg.configFile."solaar/rules.yaml".text = ''
        %YAML 1.3
        ---
        - Rule:
          - Setting: [9DBC514C, scroll-ratchet, 1]
          - Execute: ['${config.wayland.windowManager.hyprland.package}/bin/hyprctl', keyword, 'input:scroll_factor', '0.05']
          - Execute: ['${config.wayland.windowManager.hyprland.package}/bin/hyprctl', keyword, 'input:emulate_discrete_scroll', '0']
          - Set: [9DBC514C, hires-smooth-resolution, true]
        - Rule:
          - Setting: [9DBC514C, scroll-ratchet, 2]
          - Execute: ['${config.wayland.windowManager.hyprland.package}/bin/hyprctl', keyword, 'input:scroll_factor', '1.0']
          - Execute: ['${config.wayland.windowManager.hyprland.package}/bin/hyprctl', keyword, 'input:emulate_discrete_scroll', '1']
          - Set: [9DBC514C, hires-smooth-resolution, false]
        ...
      '';

      nixland = {
        windowRules = [
          {
            class = "looking-glass-client";
            rules = "idleinhibit fullscreen";
          }
        ];

        autoConnect = true;
        monitor = {
          "HDMI-A-1" = {
            size = {
              width = 2560;
              height = 1440;
            };
            refreshRate = 144;
            position = {
              x = 0;
              y = 0;
            };
            workspace = 1;
          };
          "HDMI-A-3" = {
            size = {
              width = 2560;
              height = 1440;
            };
            refreshRate = 144;
            position = {
              x = 2560;
              y = 0;
            };
            workspace = 2;
          };
          # "DP-4" = {
          #   size = {
          #     width = 2560;
          #     height = 1440;
          #   };
          #   refreshRate = 144;
          #   position = {
          #     x = -2560;
          #     y = 200;
          #   };
          #   workspace = 2;
          # };
          # "HDMI-A-1" = {
          #   size = {
          #     width = 2560;
          #     height = 1440;
          #   };
          #   position = {
          #     x = 0;
          #     y = 0;
          #   };
          #   refreshRate = 144;
          #   workspace = 1;
          # };
          # "DP-3" = {
          #   size = {
          #     width = 2560;
          #     height = 1440;
          #   };
          #   refreshRate = 144;
          #   position = {
          #     x = 2560;
          #     y = 0;
          #   };
          #   workspace = 3;
          # };
        };
      };

      hyprworld = {
        bluetooth.enable = true;
        extraVolumeKeys = true;

        idle = {
          screen = null;
          sleep = null;
        };

        wallpaper.transition = {
          step = 5;
          fps = 144;
        };
      };

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

        obs-studio.plugins = [
          pkgs.obs-studio-plugins.looking-glass-obs
        ];
      };
    };
}
