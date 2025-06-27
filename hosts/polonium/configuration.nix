{
  config,
  inputs,
  lib,
  outputs,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix

    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
    inputs.home-manager.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index

    outputs.nixosModules.default
    outputs.nixosModules.home-manager
  ];

  boot.extraModprobeConfig = ''
    options hid_apple swap_opt_cmd=1 swap_fn_leftctrl=1
  '';

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

  security.polkit.enable = true;

  services = {
    speechd.enable = true;
    sysprof.enable = true;
    upower.enable = true;

    xserver.displayManager.gdm.enable = true;
    xserver.desktopManager.gnome.enable = true;

    geoclue2 = {
      enable = true;
      geoProviderUrl = "https://beacondb.net/v1/geolocate";
    };
  };

  tetrago = {
    audio.enable = true;
    bluetooth.enable = true;
    fonts.enable = true;
    printing.enable = true;

    users.james = {
      username = "james";
      name = "James";
      groups = [ "wheel" ];
    };
  };

  services.automatic-timezoned.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.systemd-boot.configurationLimit = 15;
  boot.loader.timeout = 0;

  networking.hostName = "polonium";
  networking.firewall.enable = true;
  networking.nftables.enable = true;
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  virtualisation.docker.enable = true;

  hardware.asahi.peripheralFirmwareDirectory =
    let
      firmware = pkgs.requireFile {
        name = "mac14g-firmware.tar.gz";
        hash = "sha256-ARVPjv62wUGPQSdSA/cdLHeErVLm/PGO8xw3MCfOisU=";
        message = "This firmware is redistributable only by Apple. Run the fetch-apple-firmware.sh script.";
      };
    in
    pkgs.runCommand "firmware" { inherit firmware; } ''
      mkdir -p $out
      tar -xzf $firmware -C $out
    '';

  hardware.asahi.useExperimentalGPUDriver = true;

  home-manager.users.james =
    { outputs, ... }:
    {
      imports = [ outputs.homeManagerModules.james ];

      home.username = "james";
      home.homeDirectory = "/home/james";
      home.stateVersion = "25.11";

      programs.home-manager.enable = true;

      james.git.enable = true;
      james.neovim.enable = true;
    };

  system.stateVersion = "25.11";
}
