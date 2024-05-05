{ config, inputs, lib, pkgs, ... }:

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

  bluetooth.enable = true;
  fonts.enable = true;
  hyprland.enable = true;
  pipewire.enable = true;
  virt.enable = true;

  programs = {
    command-not-found.enable = false;
    dconf.enable = true;
    gamemode.enable = true;
    nix-index-database.comma.enable = true;
    steam.enable = true;
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

    logind.killUserProcesses = true;

    greetd = {
      enable = true;
      restart = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${inputs.hyprland.packages.${pkgs.system}.hyprland}/bin/Hyprland";
          user = "greeter";
        };
      };
    };
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
              refreshRate = 144;
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

