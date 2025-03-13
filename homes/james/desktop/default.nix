{
  inputs,
  lib,
  outputs,
  pkgs,
  ...
}:

let
  store = pkgs.writeShellScriptBin "store" ''
    if dir=$(ls -d /nix/store/*/ | sed 's|^/nix/store/||' | ${lib.getExe pkgs.fzf} --height 40% --layout=reverse); then
      ${lib.getExe pkgs.xplr} "/nix/store/$dir"
    fi
  '';
in
{
  imports = [
    outputs.homeManagerModules.james
    outputs.homeManagerModules.hyprworld
  ];

  hyprworld = {
    enable = true;

    wallpaper = {
      dark = "${./files/dark.png}";
      light = "${./files/light.png}";
    };
  };

  nixland.windowRules =
    let
      mkFloat =
        name:
        {
          width ? 350,
          height ? 500,
        }:
        [
          {
            class = name;
            rules = [
              "float"
              "size ${toString width} ${toString height}"
            ];
          }
        ];
    in
    [
      {
        class = "ghidra-Ghidra";
        title = "Ghidra";
        rules = "size 0 0";
      }
      {
        class = "ghidra-Ghidra";
        title = "Ghidra:.*";
        rules = "tile";
      }
      {
        class = "ghidra-Ghidra";
        title = "CodeBrowser";
        rules = "tile";
      }
      {
        title = "OpenTTD.*";
        rules = "tile";
      }
      {
        class = "Aseprite";
        rules = "tile";
      }
    ]
    ++ mkFloat "io.github.fizzyizzy05.binary" { height = 350; }
    ++ mkFloat "org.gnome.gitlab.cheywood.Buffer" { width = 600; }
    ++ mkFloat "dev.geopjr.Collision" { }
    ++ mkFloat "com.github.huluti.Curtail" { }
    ++ mkFloat "io.gitlab.adhami3310.Impression" { }
    ++ mkFloat "io.github.zefr0x.hashes" { };

  home = {
    username = "james";
    homeDirectory = "/home/james";

    file = {
      ".gdbinit".text = ''
        alias -a disas = disassemble
      '';

      ".binaryninja/themes".source = "${
        pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "binary-ninja";
          rev = "0cb1eae43c6cd615eafe74db923259e4f683ac04";
          hash = "sha256-uFw098Z0D7lZTfl+QolX/JgRGKfE0FCsm6f7vNfzJUo=";
        }
      }/themes";

      ".sdk/jdk-21".source = "${pkgs.jdk21_headless.home}";
      ".clang-format".source = ./files/clang-format;
    };

    packages = with pkgs; [
      # CLI
      p7zip
      fzf
      fd
      nix-output-monitor
      ctop
      file
      jq
      store

      # Media
      aseprite
      inkscape
      blender
      gimp
      handbrake
      davinci-resolve
      parabolic # Video downloader
      reco # Sound recorder
      mousai # Song identifier
      switcheroo # Image converter

      # System
      bottles
      qemu
      remmina
      inspector # System info
      resources # Resource viewier
      snoop # File search
      gnome-system-monitor

      # Development
      meld
      turtle
      renderdoc-x11
      jetbrains.idea-community
      blockbench
      zeal
      ghex
      inputs.pwndbg.packages.${stdenv.hostPlatform.system}.pwndbg

      # Tools
      binaryninja
      cartero # HTTP toolkit
      drawio
      bustle # DBus log

      # Utility
      obsidian
      gnome-calendar
      gnome-clocks
      chromium
      mousam # Weather
      alpaca # Ollama chat
      gnome-graphs
      key-rack # Secrets tracker
      gnome-characters
      sysprof
      binary # Base converter
      buffer # Volatile scratchpad
      collision # Hash calculator
      curtail # Image compressor
      impression # Removable media writer
      gnome-frog # OCR
      hashes # Hash identifier

      # Games
      gnome-mines
      gnome-sudoku
    ];

    stateVersion = "23.11";
  };

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      enableBashIntegration = true;
      config.global.warn_timeout = "0";
      nix-direnv.enable = true;
    };

    obs-studio = {
      enable = true;
      plugins = [ pkgs.obs-studio-plugins.looking-glass-obs ];
    };

    ssh = {
      enable = true;
      addKeysToAgent = "yes";
      matchBlocks."*".setEnv.TERM = "xterm-256color";
    };
  };

  services = {
    easyeffects.enable = true;
  };

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

    userDirs = {
      enable = true;
      createDirectories = false;
      desktop = null;
      publicShare = null;
      templates = null;
    };
  };

  james = {
    bash.enable = true;
    emacs.enable = true;
    firefox.enable = true;
    speech.enable = true;
    terminal.enable = true;
    theme.enable = true;

    discord = {
      enable = true;
      enableNixlandIntegration = true;
    };

    git = {
      enable = true;
      enableLibsecretIntegration = true;
    };

    media = {
      enable = true;
      enableNixlandIntegration = true;
    };

    neovim = {
      enable = true;
      transparent = true;
      enableDarkmanIntegration = true;
    };
  };
}
