{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.nixos-hardware.nixosModules.framework-13th-gen-intel
    inputs.nix-index-database.nixosModules.nix-index

    ./hardware-configuration.nix
    ../../modules/nixos/home-manager.nix
    ../../modules/nixos
  ];

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

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
    dconf.enable = true;
    hyprland.enable = true;
    nix-index-database.comma.enable = true;
    steam.enable = true;
    virt-manager.enable = true;
  };

  services = {
    blueman.enable = true;
    fprintd.enable = true;
    fwupd.enable = true;
    hardware.bolt.enable = true;
    ntp.enable = true;
    thermald.enable = true;
    udisks2.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  security = {
    polkit.enable = true;
    pam.services.hyprlock.fprintAuth = false;
  };

  networking.firewall.enable = true;

  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [(pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd];
        };
      };
    };
  };

  host = {
    bluetooth = true;
    configurations = {
      default = [
        {
          name = "eDP-1";
          width = 2256;
          height = 1504;
          scale = 1.3333;
        }
      ];
      others = [
        {
          name = "docked";
          configuration = [
            {
              enable = false;
              name = "eDP-1";
            }
            {
              name = "DP-5";
              width = 2560;
              height = 1440;
              refreshRate = 60;
              position.x = 0;
            }
            {
              name = "DP-7";
              width = 2560;
              height = 1440;
              refreshRate = 60;
              position.x = 2560;
            }
          ];
        }
      ];
    };
  };

  usrs.james = {
    username = "james";
    name = "James";
    groups = [ "wheel" "docker" "libvirtd" ];
  };

  home-manager.users.james = import ../../homes/james;

  environment.systemPackages = with pkgs; [
    curl
    git
    neovim
    unzip
  ];

  system.stateVersion = "23.11";
}

