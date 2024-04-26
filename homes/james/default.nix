{ config, inputs, pkgs, ... }:

{
  imports = [
    inputs.nix-colors.homeManagerModules.default

    ../../modules/home-manager/hyprworld
    ../../modules/home-manager/theme

    ./bash.nix
    ./cyber.nix
    ./firefox.nix
    ./git.nix
    ./kitty.nix
    ./nixvim.nix
    ./vscode.nix
  ];

  hyprworld = {
    wallpaper = "${./wallpaper.png}";
  };

  colorScheme = let lb = inputs.nix-colors.lib.contrib { inherit pkgs; }; in lb.colorSchemeFromPicture {
    path = ./wallpaper.png;
    variant = "dark";
  };

  home = {
    username = "james";
    homeDirectory = "/home/james";

    packages = with pkgs; [
      powertop
      nurl
      p7zip
      fzf
      fd
      httpie
      eva
      nix-output-monitor
      nvd

      discord
      bottles
      spotify-adblock
      obs-studio
      obsidian
      imhex
      gnome.gnome-weather
      vlc
      ungoogled-chromium
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
      nix-direnv.enable = true;
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
