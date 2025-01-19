{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    inputs.nix-colors.homeManagerModules.default

    ../../modules/home-manager/hyprworld
    ../../modules/home-manager/theme
    ../../modules/home-manager

    ./bash.nix
    ./firefox.nix
    ./git.nix
    ./kitty.nix
    ./media.nix
    ./nixvim.nix
  ];

  hyprworld = {
    wallpaper = "${./files/wallpaper.png}";
  };

  wayland.windowManager.hyprland.settings.windowrulev2 = [
    "stayfocused,class:^(com.vector35.binaryninja)$,title:^([^B])(.*)$"
    "size 0 0,class:^(ghidra-Ghidra)$,title:^(Ghidra)$"
    "tile,class:^(ghidra-Ghidra)$,title:^(Ghidra:)(.*)$"
    "tile,class:^(ghidra-Ghidra)$,title:^(CodeBrowser)$"
    "tile,title:^(OpenTTD)(.*)$"
    "tile,class:^(Aseprite)$"
  ];

  colorScheme =
    let
      lb = inputs.nix-colors.lib.contrib { inherit pkgs; };
    in
    lb.colorSchemeFromPicture {
      path = ./files/wallpaper.png;
      variant = "dark";
    };

  home = {
    username = "james";
    homeDirectory = "/home/james";

    file = {
      ".sdk/jdk-21".source = "${pkgs.jdk21_headless.home}";

      ".clang-format".source = ./files/clang-format;

      ".gdbinit".text = "source ${pkgs.gef}/share/gef/gef.py";
      ".config/pwn.conf".text = ''
        [update]
        interval=never

        [context]
        terminal=["${config.programs.kitty.package}/bin/kitty", "sh", "-c"]
      '';
    };

    packages = with pkgs; [
      p7zip
      fzf
      fd
      httpie
      nix-output-monitor
      nvd
      ctop
      below
      file

      bottles
      meld
      obsidian
      imhex
      aseprite
      inkscape
      godot_4
      kdePackages.ark
      gnome-calendar
      gnome-clocks
      gnome-mines
      gnome-sudoku
      qemu
      blender
      gimp
      renderdoc-x11
      drawio
      remmina
      binaryninja
      chromium
      jetbrains.idea-community
      blockbench

      kdenlive
      handbrake
      libreoffice-qt
      hunspell
      hunspellDicts.en_US
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
      matchBlocks."*".setEnv.TERM = "xterm-256color";
    };

    home-manager.enable = true;
  };

  services = {
    easyeffects.enable = true;
  };
}
