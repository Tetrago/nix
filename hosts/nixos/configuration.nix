{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default

    ./hardware-configuration.nix
    ../../modules/home-manager
    ../../modules/nixos
    ../../home/james
  ];

  fonts.enable = true;
  gdm.enable = true;
  net.enable = true;
  net.hostname = "nixos";
  pipewire.enable = true;
  plymouth.enable = true;
  secureboot.enable = true;
  secureboot.enableTpm2 = true;

  security.polkit.enable = true;
  programs.hyprland.enable = true;
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 8080 ];

  system.monitors = [
    {
      name = "Virtual-1";
      width = 1280;
      height = 720;
      refreshRate = 60;
      x = 0;
      y = 0;
    }
  ];

  environment.systemPackages = with pkgs; [
    curl
    git
    comma
  ];

  system.stateVersion = "23.11";
}

