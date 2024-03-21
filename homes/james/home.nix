{ config, inputs, pkgs, ... }:

{
  imports = [
    inputs.nix-colors.homeManagerModules.default
    inputs.hyprland.homeManagerModules.default

    ../../modules/home-manager/hyprworld
    ../../modules/home-manager/neovim.nix
  ];

  config = {
    hyprworld.background = {
      enable = true;
      wallpaper = "~/.wallpaper.jpg";
    };

    colorScheme = let lb = inputs.nix-colors.lib.contrib { inherit pkgs; }; in lb.colorSchemeFromPicture {
      path = ./wallpaper.jpg;
      variant = "dark";
    };

    gtk = {
      enable = true;
      theme = {
        name = "base16-flat-${config.colorScheme.slug}-gtk";
        package = import ../../pkgs/base16-flat-gtk.nix {
          theme = config.colorScheme.slug;
          colors = config.colorScheme.palette;
          inherit pkgs;
        };
      };
      iconTheme = {
        name = "kora-pgrey";
        package = pkgs.kora-icon-theme;
      };
    };

    qt = {
      enable = true;
      platformTheme = "gtk";
    };

    home = {
      username = "james";
      homeDirectory = "/home/james";

      pointerCursor = {
        name = "capitaine-cursors";
        package = pkgs.capitaine-cursors;
        gtk.enable = true;
      };

      file.".wallpaper.jpg".source = ./wallpaper.jpg;

      packages = with pkgs; [
        p7zip
        fd
        hexyl
        tre
        scc
        burpsuite
        openvpn
        cyberchef
        gtk-engine-murrine
        discord
      ];

      sessionVariables = {
        TERMINAL = "alacritty";
        EDITOR = "nvim";
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
      };

      stateVersion = "23.11";
    };

    programs = {
      bat.enable = true;
      btop = {
        enable = true;
        settings.color_theme = "TTY";
      };
      eza.enable = true;
      ripgrep.enable = true;
      xplr.enable = true;
      zoxide = {
        enable = true;
        enableBashIntegration = true;
      };
      alacritty = {
        enable = true;
        settings = {
          shell = {
            program = "/usr/bin/env";
            args = [ "bash" "-l" ];
          };

          font = {
            size = 11;

            bold = {
              family = "Fira Code";
              style = "Bold";
            };

            normal = {
              family = "Fira Code";
              style = "Regular";
            };
          };

          keyboard.bindings = [
            {
              action = "SpawnNewInstance";
              key = "N";
              mods = "Control";
            }
          ];

          window = {
            opacity = 0.9;
            padding = {
              x = 5;
              y = 5;
            };
          };

          colors = let c = config.colorScheme.palette; f = col: "0x${col}"; in {
            primary = {
              background = f c.base00;
              foreground = f c.base05;
            };

            cursor = {
              text = f c.base00;
              cursor = f c.base05;
            };

            normal = {
              black = f c.base00;
              red = f c.base08;
              green = f c.base0B;
              yellow = f c.base0A;
              blue = f c.base0D;
              magenta = f c.base0E;
              cyan = f c.base0C;
              white = f c.base05;
            };

            bright = {
              black = f c.base03;
              red = f c.base08;
              green = f c.base0B;
              yellow = f c.base0A;
              blue = f c.base0D;
              magenta = f c.base0E;
              cyan = f c.base0C;
              white = f c.base07;
            };
          };
        };
      };
      bash = {
        enable = true;
        enableCompletion = true;
        shellAliases = let
          ne = pkgs.writeShellScriptBin "nixDevelopEnvScript" ''
            env="$1"
            nix develop /etc/nixos#$env
          '';
          nx = pkgs.writeShellScriptBin "nixDevelopExecScript" ''
            env="$1"
            shift
            nix develop /etc/nixos#$env -c "$@"
          '';
        in {
          ls = "eza";
          ll = "eza -lh";
          la = "eza -alh";
          grep = "grep --color=auto";
          ip = "ip -color=auto";
          cat = "bat -Pu";
          hx = "hexyl";
          cp = "cp -i";
          mv = "mv -i";
          tree = "tre";
          nnn = "xplr";
          ranger = "xplr";
          cloc = "scc";
          ne = "${ne}/bin/nixDevelopEnvScript";
          nx = "${nx}/bin/nixDevelopExecScript";
        };
      };
      firefox = let
        userChrome = builtins.readFile(builtins.fetchurl {
          url = "https://raw.githubusercontent.com/crambaud/waterfall/main/userChrome.css";
          sha256 = "62008a97381cf0b8b57e5a0b39cf13305903f3b32e3b31fe209182bfe317affa";
        });
      in {
        enable = true;
        profiles.default = {
          userChrome = userChrome;
          settings = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "layers.acceleration.force-enabled" = true;
            "gfx.webrender.all" = true;
            "svg.context-properties.content.enabled" = true;
          };
        };
      };
      git = {
        enable = true;
        userName = "James";
        userEmail = "tetrago@allriagon.com";
      };
      starship = {
        enable = true;
        settings = {
          add_newline = false;
          right_format = "$time";
          time = {
            disabled = false;
            style = "bold bright-black";
            format = "[$time]($style)";
          };
        };
      };
      vscode = {
        enable = true;
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        mutableExtensionsDir = false;
        userSettings = {
          "window.titleBarStyle" = "custom";
          "workbench.startupEditor" = "none";
          "editor.minimap.enabled" = false;
          "editor.fontLigatures" = true;
          "editor.fontFamily" = "'FiraCode Nerd Font', 'Droid Sans Mono', 'monospace', monospace";
          "workbench.layoutControl.enabled" = false;
        };
        extensions = with pkgs.vscode-extensions; [
          bbenoist.nix
          vscodevim.vim
          mkhl.direnv
          svelte.svelte-vscode
          golang.go
        ];
      };
      home-manager.enable = true;
    };

    services = {
      easyeffects.enable = true;
    };
    
    xdg = {
      enable = true;
      desktopEntries = {
        ghidra = let
          icon = builtins.fetchurl {
            url = "https://raw.githubusercontent.com/NationalSecurityAgency/ghidra/master/Ghidra/RuntimeScripts/Windows/support/ghidra.ico";
            sha256 = "sha256-AG23WMrARvbFcvZIdGOBUeNmp1aQKnuiRYf8kNJLL2c=";
          };
        in {
          exec = ''"nix develop /etc/nixos#cyber -c ghidra"'';
          categories = [ "Application" "Development" ];
          genericName = "Ghidra Software Reverse Engineering Suite";
          icon = icon;
          name = "Ghidra";
          type = "Application";
        };
      };
    };
  };
}
