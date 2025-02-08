{ inputs, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nix-index-database.nixosModules.nix-index

    ./hardware-configuration.nix
    ../../modules/nixos/home-manager
    ../../modules/nixos/hyprworld
    ../../modules/nixos
  ];

  boot = {
    blacklistedKernelModules = [ "mt76x2u" ];
    kernelPackages = pkgs.linuxPackages_6_12;
  };

  hardware = {
    graphics.extraPackages = [ pkgs.vpl-gpu-rt ];
  };

  programs = {
    command-not-found.enable = false;
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
    ollama.enable = true;
    upower.enable = true;
  };

  networking = {
    nftables.enable = false; # libvirt issue with nftables
    firewall.extraCommands = ''
      iptables -A OUTPUT -d _gateway -j ACCEPT
      iptables -A OUTPUT -d 10.136.0.0/16 -j REJECT --reject-with icmp-net-prohibited
      iptables -A INPUT -s 10.10.14.0/23 -j ACCEPT
    '';
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

    networking = {
      enable = true;
      hostname = "hydrogen";
    };

    plymouth = {
      enable = true;
      theme = "red_loader";
    };

    sddm = {
      enable = true;
      package = pkgs.kdePackages.sddm;
      theme = {
        name = "sddm-astronaut-theme";
        package = pkgs.sddm-astronaut.override {
          themeConfig = {
            Font = "Ubuntu Sans";
            HourFormat = "hh:mm AP";
            DateFormat = "dddd, MMMM d";
            Background = pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/vinceliuice/WhiteSur-wallpapers/3a24624d04aedc638e042a1de81238b95b46a342/Wallpaper-nord/WhiteSur-nord-light.png";
              sha256 = "sha256-jcX00tiPje0YGe38y0Vr0FA5Mg21XpHYp4m6ptx2iAw=";
            };
            DimBackground = "0.3";
            PartialBlur = "false";
          };
        };
        extraPackages = with pkgs.kdePackages; [
          qtmultimedia
          qtsvg
          qtvirtualkeyboard
        ];
      };
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
    { outputs, ... }:
    {
      imports = [ outputs.homeManagerModules.james ];

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

        wallpaper.transition = {
          step = 5;
          fps = 144;
        };
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

  environment = {
    etc.hosts.mode = "0644";
  };

  system.stateVersion = "23.11";
}
