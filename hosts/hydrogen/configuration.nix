{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.solaar.nixosModules.default

    ./hardware-configuration.nix
    ../desktop
  ];

  boot = {
    blacklistedKernelModules = [ "mt76x2u" ];
    kernelPackages = pkgs.linuxPackages_zen;
  };

  hardware = {
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
    solaar.enable = true;
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
    audio.samplingRate = 96000;
    bluetooth.enable = true;

    boot = {
      loader = "grub";
      skipBootMenu = false;
    };

    graphics = {
      enable = true;
      intel.enable = true;
      nvidia.blacklist = true;
    };

    plymouth = {
      theme = "red_loader";
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

  environment.etc.hosts.mode = "0644";

  home-manager.users = import ./homes.nix;

  system.stateVersion = "23.11";
}
