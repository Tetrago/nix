{ inputs, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nix-index-database.nixosModules.nix-index

    ./hardware-configuration.nix
    ../../modules/nixos/home-manager
    ../../modules/nixos
  ];
  
  boot = {
    blacklistedKernelModules = [ "mt76x2u" ];
    kernelPackages = pkgs.linuxKernel.packages.linux_6_9;
  };

  networking = {
    defaultGateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" ];

    bridges.br0.interfaces = [ "enp5s0" ];

    interfaces.br0.ipv4.addresses = [
      {
        address = "192.168.1.111";
        prefixLength = 24;
      }
    ];
  };

  programs = {
    command-not-found.enable = false;
    dconf.enable = true;
    nix-index-database.comma.enable = true;
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

  security.polkit.enable = true;

  services = {
    gvfs.enable = true;
    hardware.openrgb.enable = true;
    ollama.enable = true;
    udisks2.enable = true;
    upower.enable = true;
  };

  virtualisation.docker.enable = true;

  tetrago = {
    audio.enable = true;
    bluetooth.enable = true;
    fonts.enable = true;
    greetd.enable = true;
    hyprland.enable = true;

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
      nftables = false;
      hostname = "hydrogen";
    };

    plymouth = {
      enable = true;
      theme = "red_loader";
    };

    users.james = {
      username = "james";
      name = "James";
      groups = [ "wheel" "docker" "libvirtd" "kvm" ];
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

  home-manager.users.james = { ... }: {
    imports = [ ../../homes/james ];

    wayland.windowManager.hyprland.settings.windowrulev2 = [
      "idleinhibit fullscreen,class:^(looking-glass-client)$"
    ];

    home.packages = with pkgs; [
      blender
    ];

    hyprworld = {
      bluetooth = true;
      extraVolumeKeys = true;

      time = {
        screen = 15;
        sleep = 0;
      };

      monitors = [
        {
          name = "HDMI-A-1";
          resolution = {
            width = 2560;
            height = 1440;
            refreshRate = 144;
          };
          position.x = 1920;
          workspace = 1;
        }
        {
          name = "DP-3";
          resolution = {
            width = 1920;
            height = 1080;
            refreshRate = 60;
          };
          position.x = 0;
          workspace = 2;
        }
        {
          name = "DP-4";
          resolution = {
            width = 1920;
            height = 1080;
            refreshRate = 60;
          };
          position = {
            x = 1920 + 2560;
            y = 480;
          };
          workspace = 3;
        }
      ];
    };

    programs = {
      looking-glass-client = {
        enable = true;
        settings = {
          app = {
            shmFile = "/dev/kvmfr0";
          };
        };
      };
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
