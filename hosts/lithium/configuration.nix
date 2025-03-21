{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkForce;
in
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13th-gen-intel

    ./hardware-configuration.nix
    ../desktop
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;

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
      imports = [ (import ../../homes/james/desktop) ];

      nixland = {
        #autoConnect = true;

        monitor = {
          "eDP-1" = {
            size = {
              width = 2256;
              height = 1504;
            };

            scale = 1.3333;
            switch = "Lid Switch";
          };

          "DP-7" = {
            size = {
              width = 2560;
              height = 1440;
            };

            refreshRate = 120;

            position = {
              x = 0;
              y = 0;
            };
          };

          "DP-6" = {
            size = {
              width = 1920;
              height = 1080;
            };

            position = {
              x = 2560;
              y = 0;
            };
          };

          "DP-5" = {
            size = {
              width = 1920;
              height = 1080;
            };

            position = {
              x = -1920;
              y = 0;
            };
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

      wayland.windowManager.hyprland.settings.decoration = {
        blur.enabled = mkForce false;
        shadow.enabled = mkForce false;
      };
    };

  system.stateVersion = "23.11";
}
