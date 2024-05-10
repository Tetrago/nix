{ inputs, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nix-index-database.nixosModules.nix-index
    inputs.grub2-themes.nixosModules.default

    ./hardware-configuration.nix
    ../../modules/nixos/home-manager
    ../../modules/nixos
  ];

  net = {
    enable = true;
    hostname = "hydrogen";
  };

  nvidia = {
    enable = true;
    enableModesetting = true;
  };

  plymouth = {
    enable = true;
    theme = "red_loader";
  };

  steam = {
    enable = true;
    users = [ "james" ];
  };

  bluetooth.enable = true;
  fonts.enable = true;
  hyprland.enable = true;
  opengl.enable = true;
  pipewire.enable = true;
  virt.enable = true;

  boot = {
    initrd.systemd.enable = true;

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };

      grub = {
        enable = true;
        configurationLimit = 5;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };

      grub2-theme = {
        enable = true;
        screen = "2k";
      };
    };

    supportedFilesystems = [ "ntfs3" ];
  };

  hardware = {
    steam-hardware.enable = true;
    xone.enable = true;
  };

  networking = {
    defaultGateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" ];

    interfaces.enp6s0.ipv4.addresses = [
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
    logind.killUserProcesses = true;
    ollama.enable = true;
    thermald.enable = true;
    udisks2.enable = true;
    upower.enable = true;

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
          name = "DP-1";
          resolution = {
            width = 2560;
            height = 1440;
            refreshRate = 144;
          };
          position.x = 1920;
          workspace = 1;
        }
        {
          name = "DP-2";
          resolution = {
            width = 1920;
            height = 1080;
            refreshRate = 60;
          };
          position.x = 0;
          workspace = 2;
        }
        {
          name = "HDMI-A-1";
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
  };

  environment = {
    sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    systemPackages = with pkgs; [
      curl
      git
      neovim
      unzip
    ];
  };

  system.stateVersion = "23.11";
}