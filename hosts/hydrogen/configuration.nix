{
  inputs,
  outputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.solaar.nixosModules.default

    outputs.nixosModules.default
    outputs.nixosModules.home-manager

    ./hardware-configuration.nix
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  programs = {
    command-not-found.enable = false;
    nix-index-database.comma.enable = true;

    nh = {
      enable = true;
      flake = "/etc/nixos";
    };
  };

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  boot = {
    blacklistedKernelModules = [ "mt76x2u" ];
    kernelPackages = pkgs.linuxPackages_zen;
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    graphics.extraPackages = with pkgs; [
      vpl-gpu-rt
      intel-compute-runtime
    ];
  };

  programs = {
    nix-ld.enable = true;
    virt-manager.enable = true;
  };

  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    fwupd.enable = true;
    gnome.core-developer-tools.enable = false;
    ollama.enable = true;
    solaar.enable = true;
    sysprof.enable = true;
    upower.enable = true;
  };

  systemd.network.wait-online.enable = false;

  networking = {
    hostName = "hydrogen";
    nftables.enable = false; # libvirt issue with nftables
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  systemd.services.nvme-rebind =
    let
      script = pkgs.writeShellScript "nvme-rebind" ''
        set -euxo pipefail

        disk="/dev/disk/by-label/Games"

        if [ ! -b "$disk" ]; then
          echo "Storage device not mounted"
          exit 0
        fi

        dev="$(readlink -f "$disk")"
        addr="$(udevadm info --query=path "$dev" | grep -oP '\d{4}:[0-9a-f]{2}:[0-9a-f]{2}\.[0-9a-f]' | tail -n 1)"

        if [ -z "$addr" ]; then
          echo "Failed to find PCI address for disk"
          exit 1
        fi

        echo "$addr" > "/sys/bus/pci/devices/$addr/driver/unbind" || true
        echo "vfio-pci" > "/sys/bus/pci/devices/$addr/driver_override"
        echo "$addr" > "/sys/bus/pci/drivers_probe"
      '';
    in
    {
      after = [ "systemd-udevd.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = script;
      };
    };

  tetrago = {
    printing.enable = true;

    audio = {
      enable = true;
      samplingRate = 96000;
    };

    boot = {
      enable = true;
      loader = "grub";
      skipBootMenu = false;
    };

    graphics = {
      enable = true;
      intel.enable = true;
      nvidia.blacklist = true;
    };

    plymouth = {
      enable = true;
      theme = "red_loader";
    };

    users.james = {
      name = "James";
      groups = [
        "wheel"
        "docker"
        "libvirtd"
        "kvm"
        "networkmanager"
        "lpadmin"
      ];
    };

    virtualization = {
      enable = true;
      cpu = "intel";
      devices.enable = true;

      passthrough = [
        # GPU
        "10de:2705"
        "10de:22bb"

        # USB
        "1b21:0612"
        "1b21:2142"
      ];

      kvmfr = {
        enable = true;
        sizes = [
          {
            width = 2560;
            height = 1440;
          }
        ];
      };
    };
  };

  environment = {
    etc.hosts.mode = "0644";

    gnome.excludePackages = with pkgs; [
      baobab
      cheese
      epiphany
      geary
      gnome-contacts
      gnome-maps
      gnome-music
      gnome-photos
      gnome-tour
      gnome-user-docs
      seahorse
      simple-scan
      yelp
    ];

    systemPackages = with pkgs.gnomeExtensions; [
      auto-accent-colour
      bluetooth-battery-meter
      blur-my-shell
      caffeine
      clipboard-indicator
      fuzzy-app-search
      just-perfection
      launch-new-instance
      night-theme-switcher
      paperwm
      search-light
    ];
  };

  home-manager.users = import ./homes.nix;

  system.stateVersion = "23.11";
}
