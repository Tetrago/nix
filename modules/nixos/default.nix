{
  outputs,
  pkgs,
  ...
}:

{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./boot.nix
    ./fonts.nix
    ./graphics.nix
    ./hyprland.nix
    ./networking.nix
    ./plymouth.nix
    ./printing.nix
    ./sddm.nix
    ./steam.nix
    ./users.nix
    ./virtualization.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.default
    ];
    config.allowUnfree = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  programs = {
    git.enable = true;
    nano.enable = false;
    neovim.enable = true;
  };

  environment.systemPackages = with pkgs; [
    curl
    unzip
    man-pages
    man-pages-posix
  ];
}
