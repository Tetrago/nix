{ inputs, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nix-index-database.nixosModules.nix-index

    ./hardware-configuration.nix
    ../../modules/nixos/home-manager
    ../../modules/nixos
  ];

  boot = {
    blacklistedKernelModules = [ "mt76x2u" ];
    kernelPackages = pkgs.linuxPackages_6_6;
  };

  programs = {
    command-not-found.enable = false;
    dconf.enable = true;
    nix-index-database.comma.enable = true;
    nix-ld.enable = true;
    virt-manager.enable = true;

    nh = {
      enable = true;
      flake = "/etc/nixos";
    };
  };

  security.polkit.enable = true;

  services = {
    gvfs.enable = true;
    ollama.enable = true;
    udisks2.enable = true;
    upower.enable = true;
  };

  networking = {
    nftables.enable = false; # libvirt issue with nftables
  };

  power.ups = {
    enable = true;
    ups."cp1500pfclcd" = {
      driver = "usbhid-ups";
      port = "auto";
    };

    users.upsmon = {
      passwordFile = "${pkgs.writeText "upsmon-pw.txt" "upsmon"}";
    };

    upsmon.monitor.cp1500pfclcd.user = "upsmon";
  };

  virtualisation.docker.enable = true;

  tetrago = {
    audio.enable = true;
    bluetooth.enable = true;
    fonts.enable = true;
    hyprland.enable = true;
    printing.enable = true;

    boot = {
      enable = true;
      loader = "grub";
      skipBootMenu = false;
    };

    graphics = {
      intel.enable = true;
      nvidia.blacklist = true;
    };

    greetd = {
      enable = true;
      theme = {
        prompt = "green";
        time = "red";
        input = "red";
        text = "cyan";
        border = "magenta";
        button = "yellow";
        action = "blue";
        container = "black";
      };
    };

    networking = {
      enable = true;
      hostname = "hydrogen";
    };

    plymouth = {
      enable = true;
      theme = "red_loader";
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

    virtualization = {
      enable = true;
      cpu = "intel";
      devices.enable = true;

      passthrough = [
        "10de:2705"
        "10de:22bb"
        "144d:a80c"
        "1b21:2142"
      ];

      kvmfr = {
        enable = true;
        sizes = [ 32 ];
      };
    };
  };

  home-manager.users.james =
    { ... }:
    {
      imports = [ ../../homes/james ];

      home.packages =
        let
          openttd = (
            import (builtins.fetchTarball {
              url = "https://github.com/NixOS/nixpkgs/archive/18e3cb306213bf2d58e28515624d2f5cf3740ea8.tar.gz";
              sha256 = "sha256:18z9f1r05dfr2i4lvm58dnhfqqm27zhrbh0imjcsj92xkvc9hrjh";
            }) { inherit (pkgs) system; }
          );
        in
        [
          openttd.openttd-jgrpp
        ];

      wayland.windowManager.hyprland.settings.windowrulev2 = [
        "idleinhibit fullscreen,class:^(looking-glass-client)$"
      ];

      hyprworld = {
        bluetooth = true;
        extraVolumeKeys = true;

        time = {
          screen = 0;
          sleep = 0;
        };

        monitors = [
          {
            name = "DP-1";
            resolution = {
              width = 2560;
              height = 1440;
              refreshRate = 144;
            };
            position.x = 2560;
            workspace = 1;
          }
          {
            name = "HDMI-A-1";
            resolution = {
              width = 2560;
              height = 1440;
              refreshRate = 144;
            };
            position.x = 0;
            workspace = 2;
          }
        ];

        #monitors = [
        #  {
        #    name = "HDMI-A-1";
        #    resolution = {
        #      width = 2560;
        #      height = 1440;
        #      refreshRate = 144;
        #    };
        #    position.x = 1920;
        #    workspace = 1;
        #  }
        #  {
        #    name = "DP-3";
        #    resolution = {
        #      width = 1920;
        #      height = 1080;
        #      refreshRate = 60;
        #    };
        #    position.x = 0;
        #    workspace = 2;
        #  }
        #  {
        #    name = "DP-4";
        #    resolution = {
        #      width = 1920;
        #      height = 1080;
        #      refreshRate = 60;
        #    };
        #    position = {
        #      x = 1920 + 2560;
        #      y = 480;
        #    };
        #    workspace = 3;
        #  }
        #];
      };

      programs = {
        looking-glass-client = {
          enable = true;
          settings = {
            app = {
              shmFile = "/dev/kvmfr0";
            };

            input = {
              escapeKey = 104;
            };
          };
        };
      };
    };

  system.stateVersion = "23.11";
}
