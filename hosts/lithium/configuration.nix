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

  tetrago = {
    audio.enable = true;
    bluetooth.enable = true;
    fonts.enable = true;
    graphics.intel.enable = true;
    greetd.enable = true;
    hyprland.enable = true;
    virtualization.enable = true;

    boot = {
      enable = true;

      secureboot = {
        enable = true;
        enableTpm2 = true;
      };
    };

    networking = {
      enable = true;
      hostname = "lithium";
    };

    plymouth = {
      enable = true;
      scale = 1.3;
    };

    steam = {
      enable = true;
      users = [ "james" ];
    };

    users.james = {
      username = "james";
      name = "James";
      groups = [
        "wheel"
        "docker"
        "libvirtd"
        "kvm"
        "networkmanager"
      ];
    };
  };

  programs = {
    command-not-found.enable = false;
    dconf.enable = true;
    gamemode.enable = true;
    nix-index-database.comma.enable = true;
    nix-ld.enable = true;
    virt-manager.enable = true;

    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d";
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

  home-manager.users.james =
    { ... }:
    {
      imports = [ ../../homes/james ];

      tetrago = {
        steam.enable = true;
      };

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

  system.stateVersion = "23.11";
}
