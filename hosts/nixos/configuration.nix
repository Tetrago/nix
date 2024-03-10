{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default

    ./hardware-configuration.nix
    ../../home
    ../../modules/nixos
  ];

  documentation.nixos.enable = false;

  fonts.enable = true;
  gdm.enable = true;
  net.enable = true;
  net.hostname = "nixos";
  pipewire.enable = true;
  plymouth.enable = true;
  secureboot.enable = true;
  secureboot.enableTpm2 = true;

  security.polkit.enable = true;
  hardware.bluetooth.enable = true;
  programs.hyprland.enable = true;

  users.users.james = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  home-manager.users.james = import ../../home/james;

  services = {
    openssh.enable = true;
  };

  environment.systemPackages = with pkgs; [
    neovim
    curl
    git
    comma
  ];

  system.stateVersion = "23.11";
}

