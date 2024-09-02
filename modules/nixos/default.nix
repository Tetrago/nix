{ outputs, ... }:

{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./boot.nix
    ./fonts.nix
    ./graphics.nix
    ./greetd.nix
    ./hyprland.nix
    ./networking.nix
    ./plymouth.nix
    ./printing.nix
    ./steam.nix
    ./users.nix
    ./virtualization.nix
  ];

  config = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    nixpkgs = {
      overlays = [ outputs.overlays.default ];
      config.allowUnfree = true;
    };

    i18n.defaultLocale = "en_US.UTF-8";
  };
}
