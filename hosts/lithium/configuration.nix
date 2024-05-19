{ inputs, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.nixos-hardware.nixosModules.framework-13th-gen-intel
    inputs.nix-index-database.nixosModules.nix-index

    ./hardware-configuration.nix
    ../../modules/nixos/home-manager
    ../../modules/nixos
  ];

  boot.loader.timeout = 0;

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

  steam = {
    enable = true;
    users = [ "james" ];
  };

  bluetooth.enable = true;
  fonts.enable = true;
  greetd.enable = true;
  hyprland.enable = true;
  opengl.enable = true;
  pipewire.enable = true;
  virt.enable = true;

  programs = {
    command-not-found.enable = false;
    dconf.enable = true;
    gamemode.enable = true;
    nix-index-database.comma.enable = true;
    virt-manager.enable = true;

    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      flake = "/etc/nixos";
    };
  };

  services = {
    fprintd.enable = true;
    fwupd.enable = true;
    gvfs.enable = true;
    hardware.bolt.enable = true;
    ollama.enable = true;
    thermald.enable = true;
    udisks2.enable = true;
    upower.enable = true;
  };

  security = {
    polkit.enable = true;

    pam.services = {
      hyprlock.fprintAuth = false;
      su.fprintAuth = false;
      sudo.fprintAuth = false;
    };
  };

  virtualisation.docker.enable = true;

  usrs.james = {
    username = "james";
    name = "James";
    groups = [ "wheel" "docker" "libvirtd" ];
  };

  home-manager.users.james = { ... }: {
    imports = [ ../../homes/james ];

    hyprworld = {
      bluetooth = true;

      monitors = [
        {
          name = "eDP-1";
          resolution = {
            width = 2256;
            height = 1504;
          };
          scale = 1.3333;
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    neovim
    unzip
  ];

  system.stateVersion = "23.11";
}
