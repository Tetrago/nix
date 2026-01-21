{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13th-gen-intel

    ./hardware-configuration.nix
    ../desktop
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;

  tetrago = {
    bluetooth.enable = true;
    virtualization.enable = true;

    boot = {
      secureboot = {
        enable = true;
        tpm2.enable = true;
      };
    };

    graphics = {
      enable = true;
      intel.enable = true;
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
    hostName = "lithium";
    nftables.enable = false; # libvirt issue with nftables
  };

  programs = {
    gamemode.enable = true;
    nix-ld.enable = true;
    virt-manager.enable = true;
  };

  services = {
    fprintd.enable = true;
    hardware.bolt.enable = true;
    thermald.enable = true;
    upower.enable = true;
  };

  security = {
    pam.services = {
      su.fprintAuth = false;
      sudo.fprintAuth = false;
    };
  };

  environment.etc.hosts.mode = "0644";

  virtualisation.docker.enable = true;

  home-manager.users = import ./homes.nix;

  system.stateVersion = "23.11";
}
