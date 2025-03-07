{
  inputs,
  lib,
  outputs,
  pkgs,
  ...
}:

let
  inherit (lib) getExe;

  store = pkgs.writeShellScriptBin "store" ''
    if dir=$(ls -d /nix/store/*/ | sed 's|^/nix/store/||' | ${getExe pkgs.fzf} --height 40% --layout=reverse); then
      ${getExe pkgs.xplr} "/nix/store/$dir"
    fi
  '';
in
{
  imports = [
    inputs.nix-colors.homeManagerModules.default

    outputs.homeManagerModules.default
    outputs.homeManagerModules.hyprworld

    ./bash.nix
    ./colors.nix
    ./discord.nix
    ./firefox.nix
    ./git.nix
    ./ghostty.nix
    ./media.nix
    ./nixvim.nix
    ./speech.nix
    ./theme.nix
    ./toolbox.nix
  ];

  hyprworld = {
    enable = true;

    wallpaper = {
      dark = "${./files/dark.png}";
      light = "${./files/light.png}";
    };
  };

  nixland.windowRules = [
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
  ];

  home = {
    username = "james";
    homeDirectory = "/home/james";

    file = {
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

      # Games
      gnome-mines
      gnome-sudoku
    ];

    stateVersion = "23.11";
  };

  programs = {
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

    home-manager.enable = true;
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
}
