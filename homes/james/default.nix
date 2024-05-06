{ config, inputs, pkgs, ... }:

{
  imports = [
    inputs.nix-colors.homeManagerModules.default

    ../../modules/home-manager/hyprworld
    ../../modules/home-manager/theme

    ./bash.nix
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
      protonup

      discord
      bottles
      spotify-adblock
      obs-studio
      obsidian
      imhex
      vlc
      ungoogled-chromium

      libreoffice-qt
      hunspell
      hunspellDicts.en_US
    ];

    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };

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

  xdg = {
    mime.enable = true;
    mimeApps.defaultApplications = {
      "application/pdf" = "zathura.desktop";
    };
  };

  services = {
    easyeffects.enable = true;
  };
}
