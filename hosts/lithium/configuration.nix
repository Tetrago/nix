{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13th-gen-intel
    inputs.nix-index-database.nixosModules.nix-index

    ./hardware-configuration.nix
    ../../modules/home-manager
    ../../modules/home-manager/gdm.nix
    ../../modules/nixos
    ../../homes/james
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.timeout = 0;
  
  gdm = {
    enable = true;
    enablePolkit = true;
  };

  net = {
    enable = true;
    hostname = "lithium";
  };

  plymouth = {
    enable = true;
    scale = 1.3;
  };

  secureboot = {
    enable = true;
    enableTpm2 = true;
  };

  fonts.enable = true;
  pipewire.enable = true;

  programs = {
    command-not-found.enable = false;
    nix-index-database.comma.enable = true;
    dconf.enable = true;
    hyprland.enable = true;
  };

  services = {
    blueman.enable = true;
    fprintd.enable = true;
    fwupd.enable = true;
    ntp.enable = true;
    thermald.enable = true;
    udisks2.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  networking.firewall.enable = true;
  security.polkit.enable = true;

  system.monitors = [
    {
      name = "eDP-1";
      width = 2256;
      height = 1504;
      refreshRate = 60;
      x = 0;
      y = 0;
      dpi = 1.3333;
    }
  ];

  environment.systemPackages = with pkgs; [
    curl
    git
    neovim
    unzip
  ];

  system.stateVersion = "23.11";
}

