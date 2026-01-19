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
      imports = [ ../../homes/james ];

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
        beets = {
          enable = true;
          settings = {
            library = "${config.xdg.userDirs.music}/.library.db";

            paths = {
              default = "$album/$title";
              comp = "$album/$title";
              singleton = "$title/$title";
            };

            plugins = [
              "duplicates"
              "fetchart"
              "thumbnails"
            ];
          };
        };

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

      services.easyeffects.enable = true;

      xdg = {
        enable = true;
        configFile = {
          "pwn.conf".text = ''
            [update]
            interval=never

            [context]
            terminal=["ghostty", "-e", "sh", "-c"]
          '';
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
        };
      };

      dconf = {
        enable = true;
        settings = {
          "com/github/neithern/g4music" = {
            audio-sink = "pulsesink";
            music-dir = "file://${config.xdg.userDirs.music}";
            peak-characters = "•";
          };

          "org/gnome/TextEditor" = {
            highlight-current-line = true;
            restore-session = false;
            keybindings = "vim";
          };

          "org/gnome/papers/default" = {
            show-sidebar = false;
            window-maximized = false;
          };

          "org/gnome/desktop/background".picture-url = "file://${../../homes/james/desktop/light.png}";
          "org/gnome/desktop/background".picture-url-dark = "file://${../../homes/james/desktop/dark.png}";
          "org/gnome/desktop/datetime/automatic-timezone".enable = true;
          "org/gnome/desktop/input-sources".xkb-options = [ "ctrl:nocaps" ];
          "org/gnome/desktop/session".idle-delay = 600;
          "org/gnome/shell/keybindings".focus-active-notification = [ ];
          "org/gnome/shell/weather".automatic-location = true;
          "org/gnome/system/location".enabled = true;
          "org/gtk/settings/file-chooser".clock-format = "12h";

          "org/gnome/desktop/wm/keybindings" = {
            switch-input-soruce = [ ];
            switch-input-soruce-backward = [ ];
          };

          "org/gnome/settings-daemon/plugins/media-keys" = {
            custom-keybindings = [
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
            ];
            help = [ ];
          };

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            binding = "<Super>N";
            command = "firefox";
            name = "Firefox";
          };

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
            binding = "<Super>Return";
            command = "ghostty";
            name = "Terminal";
          };

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
            binding = "<Super>E";
            command = "nautilus";
            name = "Explorer";
          };

          "org/gnome/desktop/interface" = {
            clock-format = "12h";
            clock-show-date = false;
            enable-hot-corners = false;
          };

          "org/gnome/desktop/screen-time-limits" = {
            history-enabled = false;
            daily-limit-enabled = false;
          };

          "org/gnome/desktop/peripherals/mouse" = {
            speed = 0.5;
            accel-profile = "flat";
          };

          "org/gnome/settings-daemon/plugins/power" = {
            sleep-inactive-ac-type = "suspend";
            sleep-inactive-ac-timeout = 1800;
          };

          "org/gnome/shell".enabled-extensions = map (x: x.extensionUuid) (
            with pkgs.gnomeExtensions;
            [
              auto-accent-colour
              bluetooth-battery-meter
              blur-my-shell
              caffeine
              clipboard-indicator
              fuzzy-app-search
              just-perfection
              launch-new-instance
              night-theme-switcher
              paperwm
              search-light
            ]
          );

          "org/gnome/mutter" = {
            experimental-features = [
              "autoclose-xwayland"
              "variable-refresh-rate"
            ];
            workspaces-only-on-primary = false;
          };

          "org/gnome/shell/extensions/just-perfection" = {
            quick-settings-dark-mode = false;
            quick-settings-night-light = false;
            startup-status = 0;
            support-notifier-showed-version = 34;
            support-notifier-type = 0;
            world-clock = false;
          };

          "org/gnome/shell/extensions/caffeine" = {
            enable-fullscreen = true;
            enable-mpris = true;
            show-notifications = false;
          };

          "org/gnome/shell/extensions/blur-my-shell/panel".blur = false;
          "org/gnome/shell/extensions/nightthemeswitcher/time".manual-schedule = false;
          "org/gnome/shell/extensions/workspace-indicator".embed-previews = false;

          "org/gnome/shell/extensions/paperwm" = {
            minimap-scale = 0.0;
            open-window-position-option-left = false;
            selection-border-radius-bottom = 12;
            show-focus-mode-icon = false;
            show-workspace-indicator = false;
            winprops = [
              ''{"wm_class":"*", "preferredWidth":"50%"}''
            ];
          };

          "org/gnome/shell/extensions/paperwm/keybindings" = {
            close-window = [ "<Super>w" ];
            live-alt-tab = [ "<Super>Tab" ];
            new-window = [ "" ];
            toggle-maximize-width = [ "<Super>p" ];
            toggle-scratch = [ "<Shift><Super>z" ];
            toggle-scratch-layer = [ "<Super>z" ];
          };

          "org/gnome/shell/extensions/search-light" = {
            border-radius = 7.0;
            popup-at-cursor-monitor = true;
            scale-height = 0.3;
            scale-width = 0.5;
            shortcut-search = [ "<Super>space" ];
          };
        };
      };

      home = {
        username = "james";

        packages = with pkgs; [
          qemu
          onshape
          orca-slicer
          gapless
          binary # Base converter
          buffer # Volatile scratchpad
          collision # Hash calculator
          curtail # Image compressor
          ghex
          gnome-sound-recorder
          gnome-tweaks
          impression # Removable media writer
          key-rack # Secrets tracker
          kooha
          meld
          mousai # Song identifier
          snoop # File search
          switcheroo # Image converter
          warp
          rose-pine-cursor
        ];

        sessionVariables = {
          TERMINAL = "ghostty";
          EDITOR = "nvim";
        };

        stateVersion = "23.11";
      };
    };
}
