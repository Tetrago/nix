{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13th-gen-intel

    ./hardware-configuration.nix
    ../desktop
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_6_12;
  };

  tetrago = {
    bluetooth.enable = true;
    graphics.intel.enable = true;
    virtualization.enable = true;

    boot = {
      secureboot = {
        enable = true;
        tpm2.enable = true;
      };
    };

    networking = {
      hostname = "lithium";
    };

    plymouth = {
      scale = 1.3;
    };

    steam = {
      enable = true;
      users = [ "james" ];
    };
  };

  networking = {
    nftables.enable = false; # libvirt issue with nftables
  };

  programs = {
    gamemode.enable = true;
    nix-ld.enable = true;
    virt-manager.enable = true;
  };

  services = {
    fprintd.enable = true;
    fwupd.enable = true;
    hardware.bolt.enable = true;
    thermald.enable = true;
    upower.enable = true;
  };

  security = {
    pam.services = {
      hyprlock.fprintAuth = false;
      su.fprintAuth = false;
      sudo.fprintAuth = false;
    };
  };

  environment.etc.hosts.mode = "0644";

  virtualisation.docker.enable = true;

  home-manager.users.james =
    { config, outputs, ... }:
    {
      imports = [ outputs.homeManagerModules.james ];

      tetrago = {
        steam.enable = true;
      };

      nixland = {
        binds = [
          {
            super = false;
            flags = "locked";
            trigger = "switch:on:Lid Switch";
            action.exec = ''hyprctl keyword monitor "${config.nixland.monitorRules."eDP-1"}"'';
          }
          {
            super = false;
            flags = "locked";
            trigger = "switch:off:Lid Switch";
            action.exec = ''hyprctl keyword monitor "eDP-1, disable"'';
          }
        ];

        monitor = {
          "" = { };
          "eDP-1" = {
            size = {
              width = 2256;
              height = 1504;
            };
            scale = 1.3333;
          };
        };
      };

      hyprworld = {
        bluetooth.enable = true;
        globalScale = 1.5;

        idle = {
          sleep = null;
        };

        wallpaper.transition = {
          step = 10;
          fps = 60;
        };
      };
    };

  system.stateVersion = "23.11";
}
