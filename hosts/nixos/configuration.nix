{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default

    ./hardware-configuration.nix
    ../../modules/home-manager
    ../../modules/nixos
    ../../homes/james
  ];

  nixpkgs.config.allowUnfree = true;

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

  programs.dconf.enable = true;

  system.monitors = [
    {
      name = "Virtual-1";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      x = 0;
      y = 0;
    }
  ];

  environment.systemPackages = with pkgs; [
    comma
    curl
    git
    neovim
    unzip
  ];

  system.stateVersion = "23.11";
}

