{ inputs, lib, pkgs, ... }:

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

  net = {
    enable = true;
    enableNftables = false;
    hostname = "hydrogen";
  };

  plymouth = {
    enable = true;
    theme = "red_loader";
  };

  bluetooth.enable = true;
  fonts.enable = true;
  greetd.enable = true;
  hyprland.enable = true;
  opengl.enable = true;
  pipewire.enable = true;
  virt.enable = true;

  boot = {
    extraModulePackages = with pkgs.linuxPackages; [
      kvmfr
    ];

    kernelModules = [
      "kvmfr"
    ];

    blacklistedKernelModules = [
      "nvidia"
    ];

    initrd = {
      kernelModules = [
        "vfio"
        "vfio_pci"
        "vfio_iommu_type1"
      ];

      systemd.enable = true;
    };

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };

      systemd-boot = {
        enable = true;
        configurationLimit = 15;
      };

      timeout = 0;
    };

    kernelParams = [
      "kvmfr.static_size_mb=32"
      "intel_iommu=on"
      "iommu=pt"
      "vfio-pci.ids=10de:1e87,10de:10f8,10de:1ad8,10de:1ad9,144d:a80c"
    ];
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
        extraArgs = "--keep-since 4d --keep 3";
      };
      flake = "/etc/nixos";
    };
  };

  services = {
    gvfs.enable = true;
    ollama.enable = true;
    thermald.enable = true;
    udisks2.enable = true;
    upower.enable = true;

    udev.extraRules = ''
      SUBSYSTEM=="kvmfr", OWNER="james", GROUP="kvm", MODE="0660"
    '';
  };

  networking.firewall.allowedTCPPorts = [ 22 80 ];
  security.polkit.enable = true;
  time.hardwareClockInLocalTime = true;
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
      extraVolumeKeys = true;
      lockscreen = "${../../homes/james/wallpaper.png}";

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

    steam.enable = lib.mkForce false;

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

  environment = {
    systemPackages = with pkgs; [
      curl
      git
      neovim
      unzip
    ];
  };

  virtualisation.libvirtd.qemuVerbatimConfig = let
    inherit (lib.strings) concatStringsSep;

    devices = [
      "null"
      "full"
      "zero"
      "random"
      "urandom"
      "ptmx"
      "kvm"
      "kqemu"
      "rtc"
      "hpet"
      "vfio"
      "kvmfr0"
    ];
  in ''
    cgroup_device_acl = [${concatStringsSep "," (map (v: "\"/dev/${v}\"") devices)}]
  '';

  system.stateVersion = "23.11";
}
