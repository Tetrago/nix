{ config, lib, ... }:

{
  imports = [
    ./bluetooth.nix
    ./fonts.nix
    ./gdm.nix
    ./gnome.nix
    ./net.nix
    ./pipewire.nix
    ./plymouth.nix
    ./secureboot.nix
    ./system.nix
  ];

  config = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    time.timeZone = "America/New_York";
    i18n.defaultLocale = "en_US.UTF-8";
  };
}
