{ inputs, pkgs, ... }:

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

  hyprworld = { wallpaper = "${./files/wallpaper.png}"; };

  colorScheme = let lb = inputs.nix-colors.lib.contrib { inherit pkgs; };
  in lb.colorSchemeFromPicture {
    path = ./files/wallpaper.png;
    variant = "dark";
  };

  home = {
    username = "james";
    homeDirectory = "/home/james";

    file = {
      ".jdk".source = "${pkgs.jdk}/lib/openjdk";
      ".clang-format".source = ./files/clang-format;
      ".cmake-format".source = ./files/cmake-format;
    };

    packages = with pkgs; [
      p7zip
      fzf
      fd
      httpie
      eva
      nix-output-monitor
      nvd
      ctop
      below

      bottles
      meld
      obsidian
      imhex
      aseprite
      inkscape
      jetbrains.idea-community
      godot_4
      gnome.file-roller
      gnome.gnome-calendar
      gnome.gnome-clocks
      qemu
      blender
      gimp
      renderdoc-x11
      ghidra
      drawio

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

  services = { easyeffects.enable = true; };
}
