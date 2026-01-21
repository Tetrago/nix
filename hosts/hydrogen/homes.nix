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

      james = {
        bash.enable = true;
        directories.enable = true;
        neovide.enable = true;
        terminal.enable = true;

        binja = {
          enable = true;
          themes = "${
            pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "binary-ninja";
              rev = "0cb1eae43c6cd615eafe74db923259e4f683ac04";
              hash = "sha256-uFw098Z0D7lZTfl+QolX/JgRGKfE0FCsm6f7vNfzJUo=";
            }
          }/themes";
        };

        firefox = {
          enable = true;
          theme.enable = true;
        };

        git = {
          enable = true;
          enableLibsecretIntegration = true;
        };

        neovim = {
          enable = true;
          transparent = true;
        };

        podman = {
          enable = true;
          enableGui = true;
        };

        programs = {
          enable = true;
          cli.enable = true;
          direnv.enable = true;
          development.enable = true;
          media.enable = true;
          office.enable = true;
          renderdoc.enable = true;
          ssh.enable = true;
          system.enable = true;
          utility.enable = true;
        };
      };

      home = {
        username = "james";

        packages = with pkgs; [
          onshape
          orca-slicer
        ];
      };
    };
}
