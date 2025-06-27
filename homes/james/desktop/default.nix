{
  outputs,
  pkgs,
  ...
}:

{
  imports = [
    outputs.homeManagerModules.default
    outputs.homeManagerModules.james
    outputs.homeManagerModules.hyprworld

    ./rules.nix
  ];

  hyprworld = {
    enable = true;
    wallpaper = {
      dark = "${./dark.png}";
      light = "${./light.png}";
    };
  };

  home = {
    username = "james";

    packages = with pkgs; [
      bottles
      qemu
      turtle
    ];

    sessionVariables = {
      TERMINAL = "ghostty";
    };

    stateVersion = "23.11";
  };

  programs.obs-studio.enable = true;
  services.easyeffects.enable = true;

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
  };

  james = {
    bash.enable = true;
    directories.enable = true;
    fonts.enable = true;
    neovide.enable = true;
    speech.enable = true;
    terminal.enable = true;
    theme.enable = true;

    binja = {
      enable = true;
      themes = "${
        pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "binary-ninja";
          rev = "0cb1eae43c6cd615eafe74db923259e4f683ac04";
          hash = "sha256-uFw098Z0D7lZTfl+QolX/JgRGKfE0FCsm6f7vNfzJUo=";
        }
      }/themes";
    };

    discord = {
      enable = true;
      enableNixlandIntegration = true;
    };

    firefox = {
      enable = true;
      theme.enable = true;
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

    podman = {
      enable = true;
      enableGui = true;
    };

    programs = {
      enable = true;
      cli.enable = true;
      direnv.enable = true;
      development.enable = true;
      games.enable = true;
      media.enable = true;
      renderdoc.enable = true;
      ssh.enable = true;
      system.enable = true;
      utility.enable = true;
    };
  };
}
