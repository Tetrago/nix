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
      enable = true;

      secureboot = {
        enable = true;
        tpm2.enable = true;
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
  };

  networking = {
    nftables.enable = false; # libvirt issue with nftables
    firewall.extraCommands = ''
      iptables -A OUTPUT -d _gateway -j ACCEPT
      iptables -A OUTPUT -d 10.138.0.0/16 -j REJECT --reject-with icmp-net-prohibited
      iptables -A INPUT -s 10.10.14.0/23 -j ACCEPT
    '';
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
    { outputs, ... }:
    {
      imports = [ outputs.homeManagerModules.james ];

      tetrago = {
        steam.enable = true;
      };

      hyprworld = {
        bluetooth.enable = true;
        globalScale = 1.5;

        idle = {
          sleep = null;
        };

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

        additionalMonitors = {
          home = [
            {
              name = "eDP-1";
              enable = false;
            }
            {
              name = "DP-5";
              resolution = {
                width = 1920;
                height = 1080;
              };
              position.x = 0;
              workspace = 2;
            }
            {
              name = "DP-6";
              resolution = {
                width = 1920;
                height = 1080;
              };
              position.x = 2560 + 1920;
              workspace = 3;
            }
            {
              name = "DP-7";
              resolution = {
                width = 2560;
                height = 1440;
                refreshRate = 144;
              };
              position.x = 1920;
              workspace = 1;
            }
          ];
        };

        wallpaper.transition = {
          step = 10;
          fps = 60;
        };
      };
    };

  system.stateVersion = "23.11";
}
