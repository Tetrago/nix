{ config, lib, outputs, ... }:

{
  imports = [
    ./bluetooth.nix
    ./fonts.nix
    ./gdm.nix
    ./gnome.nix
    ./host.nix
    ./net.nix
    ./pipewire.nix
    ./plymouth.nix
    ./secureboot.nix
    ./usrs.nix
  ];

  config = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nixpkgs = {
      overlays = [ outputs.overlays.default ];
      config.allowUnfree = true;
    };

    time.timeZone = "America/New_York";
    i18n.defaultLocale = "en_US.UTF-8";
  };
}
