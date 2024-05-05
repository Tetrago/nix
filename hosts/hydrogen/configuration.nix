{ config, inputs, lib, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nix-index-database.nixosModules.nix-index

    ./hardware-configuration.nix
    ../../modules/nixos/home-manager
    ../../modules/nixos
  ];

  hyprland = {
    enable = true;
    enableNvidiaPatches = true;
  };

  net = {
    enable = true;
    hostname = "hydrogen";
  };

  nvidia = {
    enable = true;
    enableModesetting = true;
  };

  bluetooth.enable = true;
  fonts.enable = true;
  opengl.enable = true;
  pipewire.enable = true;
  plymouth.enable = true;
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

  security.polkit.enable = true;
  virtualisation.docker.enable = true;

  host = {
    bluetooth = true;
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

