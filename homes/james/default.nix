{
  inputs,
  outputs,
  pkgs,
  ...
}:

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
      aseprite
      inkscape
      godot_4
      gnome-calendar
      gnome-clocks
      gnome-mines
      gnome-sudoku
      collision # Hash calculator
      impression # Removable media writer
      apostrophe # Markdown editor
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
      kiwix
      zeal

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
      documents = null;
      publicShare = null;
      templates = null;
    };
  };
}
