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
    ./firefox.nix
    ./git.nix
    ./ghostty.nix
    ./media.nix
    ./nixvim.nix
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

  wayland.windowManager.hyprland.settings.windowrulev2 = [
    "stayfocused,class:^(com.vector35.binaryninja)$,title:^([^B])(.*)$"
    "size 0 0,class:^(ghidra-Ghidra)$,title:^(Ghidra)$"
    "tile,class:^(ghidra-Ghidra)$,title:^(Ghidra:)(.*)$"
    "tile,class:^(ghidra-Ghidra)$,title:^(CodeBrowser)$"
    "tile,title:^(OpenTTD)(.*)$"
    "tile,class:^(Aseprite)$"
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
      store

      # Media
      aseprite
      inkscape
      blender
      gimp
      handbrake
      davinci-resolve
      parabolic # Video downloader
      vesktop

      # System
      bottles
      qemu
      remmina
      inspector # System info
      resources # Resource viewier
      snoop # File search

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
      kiwix
      mousam # Weather
      alpaca # Ollama chat
      gnome-graphs
      key-rack # Secrets tracker
      gnome-characters

      # Games
      gnome-mines
      gnome-sudoku
    ];

    stateVersion = "23.11";
  };

  programs = {
    btop = {
      enable = true;
      settings.color_theme = "TTY";
    };

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

    configFile."pwn.conf".text = ''
      [update]
      interval=never

      [context]
      terminal=["ghostty", "-e", "sh", "-c"]
    '';

    userDirs = {
      enable = true;
      createDirectories = false;
      desktop = null;
      publicShare = null;
      templates = null;
    };
  };
}
