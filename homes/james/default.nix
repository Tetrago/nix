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
    ./nixvim.nix
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
    
    file = {
      ".jdk".source = "${pkgs.jdk}/lib/openjdk";
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

      discord
      bottles
      spotify-adblock
      obsidian
      imhex
      aseprite
      jetbrains.idea-community
      godot_4
      gnome.file-roller
      gnome.gnome-calendar
      gnome.gnome-clocks

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

    feh = {
      enable = true;

      buttons = {
        prev_img = "";
        next_img = "";
        zoom_in = 4;
        zoom_out = 5;
      };
    };

    mpv = {
      enable = true;

      config = {
        osd-bar = "no";
        border = "no";
      };

      scripts  = with pkgs.mpvScripts; [
        mpris
        uosc
        thumbfast
      ];
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
    zathura.enable = true;
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
